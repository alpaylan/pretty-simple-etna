module Etna.Gens.Hedgehog where

import           Hedgehog (Gen)
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

gen_identifier_not_split :: Gen IdentDigitsArgs
gen_identifier_not_split = do
  startC <- Gen.element (['a'..'z'] ++ ['A'..'Z'] ++ "_")
  -- See QuickCheck.hs note: exclude '\'' to keep variants orthogonal.
  rest <- Gen.string (Range.linear 0 6)
                     (Gen.element (['a'..'z'] ++ ['A'..'Z'] ++ "_"))
  digits <- Gen.string (Range.linear 1 4) (Gen.element ['0'..'9'])
  pure (IdentDigitsArgs (startC : rest) digits)

gen_apostrophe_in_identifier :: Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  startC <- Gen.element (['a'..'z'] ++ ['A'..'Z'] ++ "_")
  rest <- Gen.string (Range.linear 0 6)
                     (Gen.element (['a'..'z'] ++ ['A'..'Z'] ++ "_"))
  n <- Gen.int (Range.linear 1 3)
  pure (IdentApostropheArgs (startC : rest) n)
