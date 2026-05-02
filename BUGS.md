# pretty-simple — Injected Bugs

Pretty-printer for Haskell value strings (cdepillabout/pretty-simple). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug.

Total mutations: 2

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `parse_other_apostrophe_7639db45_1` | `parseOther_splits_at_apostrophe` | `src/Text/Pretty/Simple/Internal/ExprParser.hs:169` | `patch` | `7639db45ac76b1fdc9bd8d4a591c8699be89b4e8` |
| 2 | `parse_other_greedy_3adbc187_1` | `parseOther_greedy_on_idents` | `src/Text/Pretty/Simple/Internal/ExprParser.hs:159` | `patch` | `3adbc1874ca3a94729bc409bf4be62c8e8f5c173` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `parse_other_apostrophe_7639db45_1` | `ApostropheInIdentifier` | `witness_apostrophe_in_identifier_case_foo_prime`, `witness_apostrophe_in_identifier_case_node_double` |
| `parse_other_greedy_3adbc187_1` | `IdentifierNotSplit` | `witness_identifier_not_split_case_foo1`, `witness_identifier_not_split_case_bar123` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `ApostropheInIdentifier` | ✓ | ✓ | ✓ | ✓ |
| `IdentifierNotSplit` | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. parseOther_splits_at_apostrophe

- **Variant**: `parse_other_apostrophe_7639db45_1`
- **Location**: `src/Text/Pretty/Simple/Internal/ExprParser.hs:169` (inside `parseOther`)
- **Property**: `ApostropheInIdentifier`
- **Witness(es)**:
  - `witness_apostrophe_in_identifier_case_foo_prime` — expressionParse "foo'" must equal [Other "foo'"]
  - `witness_apostrophe_in_identifier_case_node_double` — expressionParse "Node''" must equal [Other "Node''"]
- **Source**: internal — Fix parsing for identifiers containing "'"
  > parseOther used to treat `'` as a terminator (in `"{[()]}\"'\","`) and didn't track apostrophes inside identifiers. For input `Node'` it produced `[Other "Node", CharLit ""]` instead of `[Other "Node'"]`. The fix removes `'` from the terminator set and adds `ignoreInIdent` so apostrophes are absorbed into the surrounding identifier.
- **Fix commit**: `7639db45ac76b1fdc9bd8d4a591c8699be89b4e8` — Fix parsing for identifiers containing "'"
- **Invariant violated**: expressionParse on a Haskell-style identifier followed by one-or-more apostrophes (e.g. `foo'`, `Node''`) returns exactly one Other token whose payload is the full input. No CharLit may appear in the result.
- **How the mutation triggers**: Reverse-applying the patch puts `'` back in the terminator set and removes the `ignoreInIdent` helper. Calling expressionParse "Node'" then returns [Other "Node", CharLit ""] instead of [Other "Node'"].

### 2. parseOther_greedy_on_idents

- **Variant**: `parse_other_greedy_3adbc187_1`
- **Location**: `src/Text/Pretty/Simple/Internal/ExprParser.hs:159` (inside `parseOther`)
- **Property**: `IdentifierNotSplit`
- **Witness(es)**:
  - `witness_identifier_not_split_case_foo1` — expressionParse "foo1" must equal [Other "foo1"]
  - `witness_identifier_not_split_case_bar123` — expressionParse "bar123" must equal [Other "bar123"]
- **Source**: internal — fix issue with 'greediness' in parsing integers
  > parseOther used to be `span (\c -> notElem c "{[()]}\"\"," && not (isDigit c))`, which stopped at the first digit. For input `foo1` it produced `[Other "foo", NumberLit "1"]` instead of `[Other "foo1"]`. The fix tracks identifier context, so digits inside Haskell-style identifiers are absorbed into the surrounding `Other` token.
- **Fix commit**: `3adbc1874ca3a94729bc409bf4be62c8e8f5c173` — fix issue with 'greediness' in parsing integers
- **Invariant violated**: expressionParse on a Haskell-style identifier followed by digits (e.g. `foo1`, `bar123`) returns exactly one Other token whose payload is the full input. No NumberLit may appear in the result.
- **How the mutation triggers**: Reverse-applying the patch swaps the new identifier-tracking parseOther for the simple `span` definition. Calling expressionParse "foo1" then returns [Other "foo", NumberLit "1"] instead of [Other "foo1"].
