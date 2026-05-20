module Etna.Gens.Hedgehog where

import           Hedgehog (Gen)
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

-- An identifier "begin" character (alpha or '_'). Excludes '\'' for
-- orthogonality between variants 1 and 2 (see QuickCheck.hs).
identBeginPool :: [Char]
identBeginPool = ['a'..'z'] ++ ['A'..'Z'] ++ "_"

identInnerPool :: [Char]
identInnerPool = ['a'..'z'] ++ ['A'..'Z'] ++ "_"

-- A "really arbitrary" alpha identifier (any letter via 'Gen.alpha',
-- plus '_' for inner positions); broadens beyond the ASCII pool.
genArbitraryIdent :: Gen String
genArbitraryIdent = do
  startC <- Gen.filter (/= '\'') Gen.alpha
  rest   <- Gen.string (Range.linear 0 9)
                       (Gen.filter (/= '\'')
                          (Gen.choice [Gen.alpha, Gen.element "_"]))
  pure (startC : rest)

-- An ASCII identifier with a wider length range than the original 0-6.
genNarrowIdent :: Gen String
genNarrowIdent = do
  startC <- Gen.element identBeginPool
  rest   <- Gen.string (Range.linear 0 9) (Gen.element identInnerPool)
  pure (startC : rest)

-- | Variant 1: Identifier-not-split.
-- Mix narrow ASCII and arbitrary-alpha identifiers; widen digit
-- length. Property's `validPrefix` filter discards any non-conforming
-- shape, so the bug-trigger subset emerges naturally.
gen_identifier_not_split :: Gen IdentDigitsArgs
gen_identifier_not_split = do
  prefix <- Gen.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  digits <- Gen.frequency
              [ (3, Gen.string (Range.linear 1 4) (Gen.element ['0'..'9']))
              , (1, Gen.string (Range.linear 1 7) (Gen.element ['0'..'9']))
              ]
  pure (IdentDigitsArgs prefix digits)

-- | Variant 2: Apostrophe-in-identifier.
-- Same widening for the prefix; apostrophe count drawn from the full
-- 1-4 band the property accepts.
gen_apostrophe_in_identifier :: Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  prefix <- Gen.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  n <- Gen.frequency
         [ (3, Gen.int (Range.linear 1 2))
         , (1, Gen.int (Range.linear 1 4))
         ]
  pure (IdentApostropheArgs prefix n)
