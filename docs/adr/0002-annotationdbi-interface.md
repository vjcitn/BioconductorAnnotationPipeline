# ADR 0002: Use AnnotationDbi as the supported access layer

## Context

`GO.db` and `org.Hs.eg.db` currently rely on a large number of legacy R environments. Those environments exist to satisfy historical contracts, but they are awkward to maintain and clutter the documentation.

## Decision

Package-facing operations will be centered on the `AnnotationDbi` interface:

- `select()`
- `mapIds()`
- `keys()`
- `keytypes()`

Direct environment use will be treated as legacy implementation detail and minimized in both software and docs.

## Consequences

- The supported package API becomes clearer.
- Legacy environment-based usage can be deprecated gradually.
- Examples and tests can focus on the stable accessor surface.

## Alternatives considered

- Preserve environment-based access as a first-class contract.
- Introduce a parallel API and keep both equally documented.

Both were rejected because they prolong dependence on legacy internals.

## Affected files and docs

- package build and metadata code
- package vignettes and README files
- ADR documentation

## Migration notes

Deprecation should be incremental: update examples and internal call sites first, then reduce or remove environment-oriented documentation.
