# ADR 0001: Separate download, model, and package stages

## Context

The current annotation pipeline mixes acquisition, transformation, and packaging across shell scripts and package-building helpers. That makes the process hard to reason about, hard to rebuild selectively, and hard to document.

## Decision

The pipeline will be organized into three explicit stages:

1. **Download** — fetch upstream resources into a stable raw-data area.
2. **Model** — transform raw resources into reusable canonical intermediates.
3. **Package** — build Bioconductor packages from modeled intermediates and metadata.

`GO.db` and `org.Hs.eg.db` will be the first concrete examples for this structure.

## Consequences

- Build dependencies become explicit.
- Rebuilds can be targeted to the stage that changed.
- Documentation can describe a single flow instead of a large number of special cases.

## Alternatives considered

- Keep the current script-first flow and document it better.
- Collapse model and package into one step.

Both were rejected because they preserve the current coupling.

## Affected files and docs

- `Makefile`
- `docs/adr/*`
- top-level README and stage-specific README files

## Migration notes

The first implementation should introduce the stage boundaries without changing package contents.
