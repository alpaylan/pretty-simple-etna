module Etna.Properties where

import Data.Char (isAlpha, isDigit)
import Etna.Result
import Text.Pretty.Simple.Internal.Expr (Expr(..))
import Text.Pretty.Simple.Internal.ExprParser (expressionParse)

------------------------------------------------------------------------------
-- Variant 1: parse_other_greedy_3adbc187_1
-- "fix issue with 'greediness' in parsing integers"
------------------------------------------------------------------------------

-- | A Haskell-style identifier followed by trailing digits, e.g.
-- @("foo", "1")@ encodes the input @"foo1"@. The buggy 'parseOther'
-- splits this into @[Other "foo", NumberLit "1"]@; the fixed
-- 'parseOther' yields @[Other "foo1"]@.
data IdentDigitsArgs = IdentDigitsArgs
  { identPrefix :: !String
  , trailingDigits :: !String
  } deriving (Show, Eq)

-- | Property: parsing @<lower-ident><digits>@ must produce exactly one
-- 'Other' token whose payload is the full input. No 'NumberLit' may
-- appear in the result.
property_identifier_not_split :: IdentDigitsArgs -> PropertyResult
property_identifier_not_split (IdentDigitsArgs prefix digits)
  | not (validPrefix prefix) = Discard
  | not (validDigits digits) = Discard
  | otherwise =
      let input = prefix ++ digits
          result = expressionParse input
      in case result of
           [Other s] | s == input -> Pass
           _ -> Fail $
             "expressionParse " ++ show input ++ " = " ++ show result ++
             "; expected [Other " ++ show input ++ "]"

validPrefix :: String -> Bool
validPrefix [] = False
validPrefix (c:cs) = isIdentBegin c && all isIdentInner cs
  where
    isIdentBegin x = isAlpha x && not (isDigit x) || x == '_'
    isIdentInner x = isAlpha x || x == '_' || x == '\''

validDigits :: String -> Bool
validDigits [] = False
validDigits xs = all isDigit xs

------------------------------------------------------------------------------
-- Variant 2: parse_other_apostrophe_7639db45_1
-- "Fix parsing for identifiers containing \"'\""
------------------------------------------------------------------------------

-- | A Haskell identifier with one or more trailing apostrophes, e.g.
-- @("foo", 1)@ encodes the input @"foo'"@; @("Node", 2)@ encodes
-- @"Node''"@. The buggy 'parseOther' splits at the first @'@, producing
-- @[Other "foo", CharLit ""]@; the fixed 'parseOther' yields
-- @[Other "foo'"]@.
data IdentApostropheArgs = IdentApostropheArgs
  { apostIdent     :: !String
  , apostropheCount :: !Int
  } deriving (Show, Eq)

-- | Property: parsing @<lower-ident>'+@ must produce exactly one 'Other'
-- token whose payload is the full input. No 'CharLit' may appear.
property_apostrophe_in_identifier :: IdentApostropheArgs -> PropertyResult
property_apostrophe_in_identifier (IdentApostropheArgs ident n)
  | not (validIdent ident) = Discard
  | n < 1 || n > 4         = Discard
  | otherwise =
      let input = ident ++ replicate n '\''
          result = expressionParse input
      in case result of
           [Other s] | s == input -> Pass
           _ -> Fail $
             "expressionParse " ++ show input ++ " = " ++ show result ++
             "; expected [Other " ++ show input ++ "]"

validIdent :: String -> Bool
validIdent [] = False
validIdent (c:cs) =
  ((isAlpha c && not (isDigit c)) || c == '_')
    && all (\x -> isAlpha x || x == '_') cs
