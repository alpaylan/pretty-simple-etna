module Etna.Witnesses where

import Etna.Properties
import Etna.Result

witness_identifier_not_split_case_foo1 :: PropertyResult
witness_identifier_not_split_case_foo1 =
  property_identifier_not_split (IdentDigitsArgs "foo" "1")

witness_identifier_not_split_case_bar123 :: PropertyResult
witness_identifier_not_split_case_bar123 =
  property_identifier_not_split (IdentDigitsArgs "bar" "123")

witness_apostrophe_in_identifier_case_foo_prime :: PropertyResult
witness_apostrophe_in_identifier_case_foo_prime =
  property_apostrophe_in_identifier (IdentApostropheArgs "foo" 1)

witness_apostrophe_in_identifier_case_node_double :: PropertyResult
witness_apostrophe_in_identifier_case_node_double =
  property_apostrophe_in_identifier (IdentApostropheArgs "Node" 2)
