module Main where

import Etna.Result (PropertyResult(..))
import Etna.Witnesses
  ( witness_identifier_not_split_case_foo1
  , witness_identifier_not_split_case_bar123
  , witness_apostrophe_in_identifier_case_foo_prime
  , witness_apostrophe_in_identifier_case_node_double
  )
import System.Exit (exitFailure, exitSuccess)

cases :: [(String, PropertyResult)]
cases =
  [ ("witness_identifier_not_split_case_foo1",            witness_identifier_not_split_case_foo1)
  , ("witness_identifier_not_split_case_bar123",          witness_identifier_not_split_case_bar123)
  , ("witness_apostrophe_in_identifier_case_foo_prime",   witness_apostrophe_in_identifier_case_foo_prime)
  , ("witness_apostrophe_in_identifier_case_node_double", witness_apostrophe_in_identifier_case_node_double)
  ]

main :: IO ()
main = do
  let failures =
        [ (n, msg) | (n, Fail msg) <- cases ] ++
        [ (n, "discard") | (n, Discard) <- cases ]
  if null failures
    then do
      putStrLn $ "OK: all " ++ show (length cases) ++ " witnesses passed"
      exitSuccess
    else do
      mapM_ (\(n, m) -> putStrLn (n ++ ": FAIL: " ++ m)) failures
      exitFailure
