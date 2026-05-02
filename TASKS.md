# pretty-simple — ETNA Tasks

Total tasks: 8

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `parse_other_apostrophe_7639db45_1` | quickcheck | `ApostropheInIdentifier` | `witness_apostrophe_in_identifier_case_foo_prime` |
| 002 | `parse_other_apostrophe_7639db45_1` | hedgehog | `ApostropheInIdentifier` | `witness_apostrophe_in_identifier_case_foo_prime` |
| 003 | `parse_other_apostrophe_7639db45_1` | falsify | `ApostropheInIdentifier` | `witness_apostrophe_in_identifier_case_foo_prime` |
| 004 | `parse_other_apostrophe_7639db45_1` | smallcheck | `ApostropheInIdentifier` | `witness_apostrophe_in_identifier_case_foo_prime` |
| 005 | `parse_other_greedy_3adbc187_1` | quickcheck | `IdentifierNotSplit` | `witness_identifier_not_split_case_foo1` |
| 006 | `parse_other_greedy_3adbc187_1` | hedgehog | `IdentifierNotSplit` | `witness_identifier_not_split_case_foo1` |
| 007 | `parse_other_greedy_3adbc187_1` | falsify | `IdentifierNotSplit` | `witness_identifier_not_split_case_foo1` |
| 008 | `parse_other_greedy_3adbc187_1` | smallcheck | `IdentifierNotSplit` | `witness_identifier_not_split_case_foo1` |

## Witness Catalog

- `witness_apostrophe_in_identifier_case_foo_prime` — expressionParse "foo'" must equal [Other "foo'"]
- `witness_apostrophe_in_identifier_case_node_double` — expressionParse "Node''" must equal [Other "Node''"]
- `witness_identifier_not_split_case_foo1` — expressionParse "foo1" must equal [Other "foo1"]
- `witness_identifier_not_split_case_bar123` — expressionParse "bar123" must equal [Other "bar123"]
