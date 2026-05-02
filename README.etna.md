# pretty-simple — ETNA workload

This is the [pretty-simple](https://github.com/cdepillabout/pretty-simple) library
forked into an ETNA workload. The upstream files are untouched; the
workload-specific additions live in:

- `etna.toml` — manifest (single source of truth).
- `patches/*.patch` — bug-injection patches. Reverse-applying any patch
  re-introduces the original bug into the otherwise-fixed base tree.
- `etna/` — runner package (cabal). Defines `property_<snake>` functions,
  per-framework generators, witnesses, and the `etna-runner` CLI.
- `BUGS.md` / `TASKS.md` — generated. Regenerate with `etna workload doc .`.

## Frameworks

Four PBT backends drive the same property:

- **QuickCheck** — random, shrinking; tier-1 reference.
- **Hedgehog** — integrated shrinking; alternative random search.
- **Falsify** — newer integrated-shrinking backend with sample-tree shrinking.
- **SmallCheck** — bounded enumeration; symbolic-style baseline.

Plus a witness-replay tool `etna` for fidelity checks.

## Quickstart

```sh
# 1. Pin a modern GHC (falsify needs base >= 4.18 = GHC >= 9.6).
ghcup install ghc 9.6.6
ghcup set ghc 9.6.6

# 2. Build the runner.
cabal build etna-runner

# 3. Witness fidelity check.
cabal test etna-witnesses

# 4. Run a property under each backend (base = fixed; expect "passed").
for tool in quickcheck hedgehog falsify smallcheck; do
  cabal run -v0 etna-runner -- "$tool" IdentifierNotSplit
done

# 5. Reverse-apply a patch (install the bug), re-run, expect "failed".
git apply -R --whitespace=nowarn patches/parse_other_greedy_3adbc187_1.patch
cabal run -v0 etna-runner -- quickcheck IdentifierNotSplit
git apply    --whitespace=nowarn patches/parse_other_greedy_3adbc187_1.patch
```

## Validating

```sh
python3 ../../../scripts/check_haskell_workload.py .
```

Runs the same invariant checks the pre-commit hook would (manifest parses,
patches reverse-apply, properties / generators / witnesses exist, runner's
`allProperties` matches the manifest, BUGS.md / TASKS.md exist).
