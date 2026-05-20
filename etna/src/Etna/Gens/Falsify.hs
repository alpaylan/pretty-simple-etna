module Etna.Gens.Falsify where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range as FR

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

ne :: [a] -> NonEmpty a
ne []     = error "Etna.Gens.Falsify.ne: empty list"
ne (x:xs) = x :| xs

-- An identifier "begin" character (alpha or '_'). Excludes '\'' for
-- orthogonality between variants 1 and 2 (see QuickCheck.hs).
identBegin :: NonEmpty Char
identBegin = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")

identInner :: NonEmpty Char
identInner = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")

-- Wider alpha pool: include extended ASCII letters so the distribution
-- isn't a single 53-element flat slot. Falsify doesn't ship a built-in
-- "all alphabetic" generator, so we approximate with a larger explicit
-- pool that still excludes '\''.
identInnerWide :: NonEmpty Char
identInnerWide =
  ne (['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9'] ++ "_")

digitChars :: NonEmpty Char
digitChars = ne ['0'..'9']

-- An ASCII identifier with a wider length range than the original 0-6.
genNarrowIdent :: F.Gen String
genNarrowIdent = do
  startC <- F.elem identBegin
  rest   <- F.list (FR.between (0 :: Word, 9)) (F.elem identInner)
  pure (startC : rest)

-- An "arbitrary" alpha identifier draw: any letter or digit (digits in
-- inner positions only). Property's `validPrefix` discards inputs that
-- don't conform; this widens the distribution beyond the narrow pool.
genArbitraryIdent :: F.Gen String
genArbitraryIdent = do
  startC <- F.elem identBegin
  rest   <- F.list (FR.between (0 :: Word, 9)) (F.elem identInnerWide)
  pure (startC : rest)

-- | Variant 1: Identifier-not-split.
-- Mix narrow and wider identifier shapes; widen digit length.
gen_identifier_not_split :: F.Gen IdentDigitsArgs
gen_identifier_not_split = do
  prefix <- F.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  digitsLen <- F.frequency
                 [ (3, F.inRange (FR.between (1 :: Word, 4)))
                 , (1, F.inRange (FR.between (1 :: Word, 7)))
                 ]
  digits <- F.list (FR.between (1 :: Word, digitsLen)) (F.elem digitChars)
  pure (IdentDigitsArgs prefix digits)

-- | Variant 2: Apostrophe-in-identifier.
-- Mix narrow and wider prefixes; trailing apostrophe count drawn from
-- the property's accepted 1-4 band.
gen_apostrophe_in_identifier :: F.Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  prefix <- F.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  n <- F.frequency
         [ (3, F.inRange (FR.between (1 :: Int, 2)))
         , (1, F.inRange (FR.between (1 :: Int, 4)))
         ]
  pure (IdentApostropheArgs prefix n)
