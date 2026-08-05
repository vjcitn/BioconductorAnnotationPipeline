# ADR 0004: Deprecate environment-based package access

## Context

The legacy package shape exposes many R environments that were created to satisfy older contracts. They complicate the user model and distract from the supported `AnnotationDbi` accessors.

## Decision

Environment-based access will be deprecated in favor of accessor-based workflows. New documentation should avoid environments unless a legacy caveat is unavoidable.

## Consequences

- The preferred API surface is simpler.
- Documentation can focus on actual package tasks instead of internal representation.
- Legacy compatibility remains possible during the transition, but it is no longer the primary story.

## Alternatives considered

- Continue documenting the environments as if they were the normal user interface.
- Remove them immediately without a transition period.

Both were rejected because they either preserve confusion or create unnecessary breakage.

## Affected files and docs

- package docs and READMEs
- examples, vignettes, and help text
- ADR documentation

## Migration notes

Start by changing examples, then internal call paths, then reduce legacy references in the top-level README and package-specific docs.
