{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

-- SmallCheck enumerates by depth. We bound prefix length and digit
-- length to keep depth budgets reasonable; the bug shows up at
-- ident "a" + digits "0", which lives well within depth 3.
series_identifier_not_split :: Monad m => SC.Series m IdentDigitsArgs
series_identifier_not_split = do
  prefixLen <- SC.generate (\d -> [1 .. min (d + 1) 3])
  digitsLen <- SC.generate (\d -> [1 .. min (d + 1) 2])
  prefix <- replicateA prefixLen (SC.generate (\_ -> ['a', 'b']))
  digits <- replicateA digitsLen (SC.generate (\_ -> ['0', '1']))
  pure (IdentDigitsArgs prefix digits)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA n f = (:) <$> f <*> replicateA (n - 1) f

series_apostrophe_in_identifier :: Monad m => SC.Series m IdentApostropheArgs
series_apostrophe_in_identifier = do
  prefixLen <- SC.generate (\d -> [1 .. min (d + 1) 3])
  prefix <- replicateA prefixLen (SC.generate (\_ -> ['a', 'b']))
  n <- SC.generate (\d -> [1 .. min (d + 1) 3])
  pure (IdentApostropheArgs prefix n)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA k f = (:) <$> f <*> replicateA (k - 1) f
