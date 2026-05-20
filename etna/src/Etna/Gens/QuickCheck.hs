module Etna.Gens.QuickCheck where

import           Data.Char (isAlpha)
import qualified Test.QuickCheck as QC

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

-- | Library-faithful generators for Haskell-Show-style identifier
-- fragments. Mostly draws structurally valid CONID/varid shapes (so the
-- property's `validPrefix`/`validIdent` filter doesn't swallow the test
-- budget) but mixes in a wider arbitrary-alpha distribution so the bug
-- subset emerges naturally rather than being hand-built.

-- An identifier "begin" character (alpha or '_'). Excludes '\'' to keep
-- the variants orthogonal: see commentary in 'gen_identifier_not_split'
-- and 'gen_apostrophe_in_identifier'.
identBeginPool :: [Char]
identBeginPool = ['a'..'z'] ++ ['A'..'Z'] ++ "_"

-- An "inner" identifier character. Excludes '\'' for the same
-- orthogonality reason; '\'' is what variant 2's bug splits on.
identInnerPool :: [Char]
identInnerPool = ['a'..'z'] ++ ['A'..'Z'] ++ "_"

-- A "really arbitrary" alpha identifier draw: any printable letter
-- prefix as recognized by 'isAlpha' (no '\''). Used in a fraction of
-- cases so the broader distribution surfaces shapes that the
-- property's filter would either reject or accept.
genArbitraryIdent :: QC.Gen String
genArbitraryIdent = do
  startC <- QC.arbitrary `QC.suchThat` (\c -> isAlpha c && c /= '\'')
  n      <- QC.choose (0, 9)
  rest   <- QC.vectorOf n (QC.arbitrary `QC.suchThat`
                             (\c -> (isAlpha c || c == '_') && c /= '\''))
  pure (startC : rest)

-- A "narrow" ASCII identifier: bag-standard `[a-zA-Z_]` but with a
-- wider length distribution than the original 0-6 cap.
genNarrowIdent :: QC.Gen String
genNarrowIdent = do
  startC <- QC.elements identBeginPool
  n      <- QC.choose (0, 9)
  rest   <- QC.vectorOf n (QC.elements identInnerPool)
  pure (startC : rest)

-- | Variant 1: Identifier-not-split.
-- Build a `<ident><digits>` pair. The bug triggers whenever the digit
-- prefix follows any valid identifier; widening the alphabet and
-- length surfaces more bug-trigger inputs while keeping the property's
-- discard rate near zero.
--
-- Note: '\'' is excluded from both prefix slots so that this generator
-- does not also catch variant 2's apostrophe bug. (Variant 2's bug
-- splits at '\''; if '\'' appeared inside the prefix here, the buggy
-- variant-2 parser would fail this property too, breaking per-variant
-- orthogonality.)
gen_identifier_not_split :: QC.Gen IdentDigitsArgs
gen_identifier_not_split = do
  prefix <- QC.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  -- Digits: bias toward short (1-4) but allow up to 7 so the broader
  -- distribution sees longer tail digits.
  digitsLen <- QC.frequency
                 [ (3, QC.choose (1, 4))
                 , (1, QC.choose (1, 7))
                 ]
  digits    <- QC.vectorOf digitsLen (QC.elements ['0'..'9'])
  pure (IdentDigitsArgs prefix digits)

-- | Variant 2: Apostrophe-in-identifier.
-- Build `<ident>'+`. Buggy variant-2 parser splits at the first '\'';
-- the fixed parser absorbs apostrophes into the surrounding ident.
-- Widening the prefix alphabet/length and the trailing apostrophe count
-- surfaces more bug shapes naturally.
gen_apostrophe_in_identifier :: QC.Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  prefix <- QC.frequency
              [ (3, genNarrowIdent)
              , (1, genArbitraryIdent)
              ]
  -- Property accepts 1..4 apostrophes (else Discard); pick from full
  -- band with light bias toward fewer.
  n <- QC.frequency
         [ (3, QC.choose (1, 2))
         , (1, QC.choose (1, 4))
         ]
  pure (IdentApostropheArgs prefix n)
