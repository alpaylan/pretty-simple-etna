module Etna.Gens.Falsify where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range as FR

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

ne :: [a] -> NonEmpty a
ne []     = error "Etna.Gens.Falsify.ne: empty list"
ne (x:xs) = x :| xs

gen_identifier_not_split :: F.Gen IdentDigitsArgs
gen_identifier_not_split = do
  let identStart = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")
      -- See QuickCheck.hs note: exclude '\'' to keep variants orthogonal.
      identInner = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")
      digitChars = ne ['0'..'9']
  startC <- F.elem identStart
  rest <- F.list (FR.between (0 :: Word, 6)) (F.elem identInner)
  digits <- F.list (FR.between (1 :: Word, 4)) (F.elem digitChars)
  pure (IdentDigitsArgs (startC : rest) digits)

gen_apostrophe_in_identifier :: F.Gen IdentApostropheArgs
gen_apostrophe_in_identifier = do
  let identStart = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")
      identInner = ne (['a'..'z'] ++ ['A'..'Z'] ++ "_")
  startC <- F.elem identStart
  rest <- F.list (FR.between (0 :: Word, 6)) (F.elem identInner)
  n <- F.inRange (FR.between (1 :: Int, 3))
  pure (IdentApostropheArgs (startC : rest) n)
