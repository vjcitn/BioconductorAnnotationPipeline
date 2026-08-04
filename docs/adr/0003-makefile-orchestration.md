# ADR 0003: Govern the pipeline with Makefiles

## Context

The current pipeline relies on a collection of shell scripts that are hard to inspect as a build graph. There is no single orchestration layer that explains which artifacts depend on which inputs.

## Decision

A top-level Makefile will orchestrate the pipeline. It will expose stage targets and package targets so that the flow is visible and incremental rebuilds are possible.

Expected target families include:

- `download`
- `model`
- `package`
- `clean`
- package-specific targets for `GO.db` and `org.Hs.eg.db`

## Consequences

- The dependency graph is encoded in one place.
- The build entry points are easier to discover.
- The pipeline can evolve from script chaining to declarative rebuilds.

## Alternatives considered

- Keep shell scripts as the only orchestration layer.
- Add a separate custom driver instead of using Make.

Make was preferred because this workflow is naturally target-and-dependency oriented.

## Affected files and docs

- `Makefile`
- stage scripts and helpers
- pipeline documentation

## Migration notes

The initial Makefile can wrap existing scripts before any deeper refactor happens.
