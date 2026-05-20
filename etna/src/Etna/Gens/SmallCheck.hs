{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties (IdentDigitsArgs(..), IdentApostropheArgs(..))

-- SmallCheck enumerates by depth. We expose wider per-slot pools than
-- the original two-letter pool so the bug-trigger subset emerges
-- naturally rather than being baked in as a single shape; depth bounds
-- keep enumeration tractable.

replicateA :: Applicative f => Int -> f a -> f [a]
replicateA 0 _ = pure []
replicateA n f = (:) <$> f <*> replicateA (n - 1) f

-- Wider pools than the original ['a','b'] / ['0','1'] doubletons.
-- Excludes '\'' (orthogonality between variant 1 and variant 2).
identBeginPool :: [Char]
identBeginPool = ['a', 'b', 'A', 'B', '_']

identInnerPool :: [Char]
identInnerPool = ['a', 'b', 'c', 'A', 'B', '_']

digitPool :: [Char]
digitPool = ['0', '1', '4', '9']

-- | Variant 1: Identifier-not-split.
-- Bug shows up at any `<ident-begin>(<ident-inner>*)<digit+>`. Wider
-- per-slot pools and slightly deeper enumeration give a richer
-- bug-trigger surface than the scaffolded ['a','b'] doubleton.
series_identifier_not_split :: Monad m => SC.Series m IdentDigitsArgs
series_identifier_not_split = do
  prefixLen <- SC.generate (\d -> [1 .. min (d + 1) 3])
  digitsLen <- SC.generate (\d -> [1 .. min (d + 1) 3])
  c0     <- SC.generate (\_ -> identBeginPool)
  cs     <- replicateA (prefixLen - 1) (SC.generate (\_ -> identInnerPool))
  digits <- replicateA digitsLen (SC.generate (\_ -> digitPool))
  pure (IdentDigitsArgs (c0 : cs) digits)

-- | Variant 2: Apostrophe-in-identifier.
-- Bug shows up at any `<ident>'+`. Wider per-slot pools as above; the
-- trailing apostrophe count enumerates 1..4 (matching the property's
-- accepted band).
series_apostrophe_in_identifier :: Monad m => SC.Series m IdentApostropheArgs
series_apostrophe_in_identifier = do
  prefixLen <- SC.generate (\d -> [1 .. min (d + 1) 3])
  c0     <- SC.generate (\_ -> identBeginPool)
  cs     <- replicateA (prefixLen - 1) (SC.generate (\_ -> identInnerPool))
  n      <- SC.generate (\d -> [1 .. min (d + 1) 4])
  pure (IdentApostropheArgs (c0 : cs) n)
