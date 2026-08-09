#!/usr/bin/env bash
# Run make check for each species that has a tarball and print a markdown
# results table suitable for pasting into QUALITY_ASSESSMENT.md.
#
# Usage:
#   bash scripts/tabulate_checks.sh            # all species with tarballs
#   bash scripts/tabulate_checks.sh human mouse rat  # specific species

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/config/species.tsv"
PKGDIR="$ROOT/packages/orgdb"
DATE="$(date '+%Y-%b-%d')"
BIOC_VER="${BIOC_PKG_VERSION:-3.24.0}"

## Determine which species to check
if [ $# -gt 0 ]; then
    SPECIES_LIST="$*"
else
    ## Auto-detect from existing tarballs
    SPECIES_LIST=""
    while IFS=$'\t' read -r name _ _ prefix _ _ _; do
        [ "$name" = "name" ] && continue   # skip header
        tarball=$(ls "$PKGDIR/${prefix}.db_"*.tar.gz 2>/dev/null | tail -1 || true)
        [ -n "$tarball" ] && SPECIES_LIST="$SPECIES_LIST $name"
    done < "$CONFIG"
fi

## Print table header
printf '\n| Date | Species | BIOC_PKG_VERSION | Pass | Fail | Notes |\n'
printf '|---|---|---|---|---|---|\n'

for sp in $SPECIES_LIST; do
    ## Find tarball
    prefix=$(awk -v s="$sp" '$1==s{print $4}' "$CONFIG")
    if [ -z "$prefix" ]; then
        printf '| %s | %s | %s | — | — | species not in config |\n' \
            "$DATE" "$sp" "$BIOC_VER"
        continue
    fi
    tarball=$(ls "$PKGDIR/${prefix}.db_"*.tar.gz 2>/dev/null | tail -1 || true)
    if [ -z "$tarball" ]; then
        printf '| %s | %s | %s | — | — | no tarball — run make package first |\n' \
            "$DATE" "$sp" "$BIOC_VER"
        continue
    fi

    ## Run check, capture output
    tmpout=$(mktemp)
    set +e
    Rscript "$ROOT/tests/check_orgdb.R" \
        --species "$sp" \
        --dbpath  "$ROOT/db/" \
        --tarball "$tarball" \
        > "$tmpout" 2>&1
    rc=$?
    set -e

    ## Parse pass/fail counts
    summary=$(grep -E "^=== Results:" "$tmpout" || echo "=== Results: 0 passed, 0 failed ===")
    passed=$(echo "$summary" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+')
    failed=$(echo "$summary" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+')

    ## Collect NOTEs and failed check names
    notes=""
    while IFS= read -r line; do
        case "$line" in
            *"NOTE  MAP:"*)        notes="${notes}NOTE:MAP(schema); " ;;
            *"NOTE  MAP skipped"*) notes="${notes}NOTE:MAP(no data); " ;;
            *"NOTE  ALIAS:"*)      notes="${notes}NOTE:ALIAS(schema); " ;;
            *"NOTE  GENETYPE data"*) notes="${notes}NOTE:GENETYPE(schema); " ;;
            *"NOTE  GENETYPE skip"*) notes="${notes}NOTE:GENETYPE(no data); " ;;
            *"NOTE  uniprot table empty"*) notes="${notes}NOTE:UniProt(not run); " ;;
            *"NOTE  no known_genes"*) notes="${notes}NOTE:spot-checks(none defined); " ;;
        esac
    done < "$tmpout"

    ## Collect names of failed checks
    if [ "$failed" -gt 0 ] 2>/dev/null; then
        fail_names=$(awk '/^Failed checks:/{f=1;next} f && /^  - /{print substr($0,5)}' "$tmpout" \
            | paste -sd '; ' -)
        notes="${notes}FAIL: ${fail_names}"
    fi

    notes="${notes%; }"   # strip trailing '; '
    [ -z "$notes" ] && notes="clean"

    printf '| %s | %s | %s | %s | %s | %s |\n' \
        "$DATE" "$sp" "$BIOC_VER" "${passed:-?}" "${failed:-?}" "$notes"

    rm -f "$tmpout"
done
printf '\n'
