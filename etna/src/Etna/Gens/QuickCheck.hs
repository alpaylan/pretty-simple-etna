module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

gen_identifier_not_split :: QC.Gen IdentDigitsArgs
gen_identifier_not_split = do
  startC <- QC.elements (['a'..'z'] ++ ['A'..'Z'] ++ "_")
  restLen <- QC.choose (0, 6)
  -- Exclude '\'': otherwise this generator also catches the apostrophe
  -- variant's bug, which makes per-variant detection non-orthogonal.
  rest <- QC.vectorOf restLen (QC.elements (['a'..'z'] ++ ['A'..'Z'] ++ "_"))
  digitsLen <- QC.choose (1, 4)
  digits <- QC.vectorOf digitsLen (QC.elements ['0'..'9'])
  pure (IdentDigitsArgs (startC : rest) digits)

gen_apostrophe_in_identifier :: QC.Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  startC <- QC.elements (['a'..'z'] ++ ['A'..'Z'] ++ "_")
  restLen <- QC.choose (0, 6)
  rest <- QC.vectorOf restLen (QC.elements (['a'..'z'] ++ ['A'..'Z'] ++ "_"))
  n <- QC.choose (1, 3)
  pure (IdentApostropheArgs (startC : rest) n)
