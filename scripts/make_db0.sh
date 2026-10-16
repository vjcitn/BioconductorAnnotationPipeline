#!/usr/bin/env bash
# Usage: make_db0.sh <species>
#
# Produces <DATA_ROOT>/db/db0_<species>.sqlite: a copy of
# chipsrc_<species>.sqlite with tables/columns renamed (and, where no data
# source exists, stubbed with empty placeholders) to match
# AnnotationDbi's internal `.definePossibleTables(class, species)` contract.
# That unexported function is the single source of truth both
# AnnotationForge::makeAnnDbPkg() (legacy per-table Bimap generation) and
# the modern OrgDb keys()/select()/mapIds() dispatch query against — see
# PlanFor3.24.md for how this was traced and the full comparison table.
#
# Per-species rename rules live in the `case` block below, derived by
# diffing annosrc/organism_annotation/script/bindb_<species>.sql (and its
# meta scripts) against .definePossibleTables()'s expectations. Currently
# only `human` is implemented; see PlanFor3.24.md Milestone 5 for the plan
# to generalize to the other 17 species in config/species.tsv.
set -euo pipefail

SPECIES="${1:?Usage: make_db0.sh <species>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_ROOT="${DATA_ROOT:-$ROOT/data}"
DBDIR="$DATA_ROOT/db"

SRC="$DBDIR/chipsrc_${SPECIES}.sqlite"
OUT="$DBDIR/db0_${SPECIES}.sqlite"
OUT_TMP="${OUT}.tmp"

if [ ! -s "$SRC" ]; then
    echo "ERROR: $SRC is missing or empty — run 'make $SRC' first" >&2
    exit 1
fi

case "$SPECIES" in
    human) DBSCHEMA="HUMAN_DB" ;;
    *)
        echo "ERROR: make_db0.sh has no schema-conformance rules for '$SPECIES' yet" >&2
        echo "       see PlanFor3.24.md Milestone 5" >&2
        exit 1 ;;
esac

rm -f "$OUT_TMP"
cp "$SRC" "$OUT_TMP"

has_table() {
    sqlite3 "$OUT_TMP" \
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name='$1';" | grep -q 1
}

echo "Conforming $OUT_TMP to $DBSCHEMA table/column contract ..."

# alias: .definePossibleTables() expects alias.alias_symbol (backs
# ALIAS2EG/ALIAS2PROBE); chipsrc names this table/column
# gene_synonyms.symbol (see bindb_human.sql).
sqlite3 -bail "$OUT_TMP" "ALTER TABLE gene_synonyms RENAME TO alias;"
sqlite3 -bail "$OUT_TMP" "ALTER TABLE alias RENAME COLUMN symbol TO alias_symbol;"

# CHRLOCCHR expects chromosome_locations.seqname; chipsrc names that column
# "chromosome" (start_location/end_location already match).
sqlite3 -bail "$OUT_TMP" \
    "ALTER TABLE chromosome_locations RENAME COLUMN chromosome TO seqname;"

# ENSEMBL expects ensembl.ensembl_id; bindb_human.sql names it "ensid" (a
# leftover from stripping the "Ensembl:" dbXref prefix).
sqlite3 -bail "$OUT_TMP" "ALTER TABLE ensembl RENAME COLUMN ensid TO ensembl_id;"

# ENSEMBLPROT/ENSEMBLTRANS: only present when assemble_species.sh's optional
# UniProt enrichment ran (db/uniprot.sqlite existed at assembly time), under
# names ("ensembl_pro"/"pro_id", "ensembl_trs"/"trs_id") that predate this
# conformance pass. Rename if present; otherwise stub empty so the keytype
# returns character(0) instead of a SQL error.
if has_table ensembl_pro; then
    sqlite3 -bail "$OUT_TMP" "ALTER TABLE ensembl_pro RENAME TO ensembl_prot;"
    sqlite3 -bail "$OUT_TMP" "ALTER TABLE ensembl_prot RENAME COLUMN pro_id TO prot_id;"
else
    sqlite3 -bail "$OUT_TMP" \
        "CREATE TABLE ensembl_prot (_id INTEGER REFERENCES genes(_id), prot_id TEXT);"
fi

if has_table ensembl_trs; then
    sqlite3 -bail "$OUT_TMP" "ALTER TABLE ensembl_trs RENAME TO ensembl_trans;"
    sqlite3 -bail "$OUT_TMP" "ALTER TABLE ensembl_trans RENAME COLUMN trs_id TO trans_id;"
else
    sqlite3 -bail "$OUT_TMP" \
        "CREATE TABLE ensembl_trans (_id INTEGER REFERENCES genes(_id), trans_id TEXT);"
fi

# PFAM: populated by assemble_species.sh only when db/PFAM.sqlite plus a
# non-empty uniprot table were both present at assembly time, and only with
# a pfam_id column (no ipi_id source exists in this pipeline yet). Add
# ipi_id as NULL so the IPI keytype has a column to query (empty results,
# not a SQL error) rather than omitting the table outright.
if has_table pfam; then
    sqlite3 -bail "$OUT_TMP" "ALTER TABLE pfam ADD COLUMN ipi_id TEXT;"
else
    sqlite3 -bail "$OUT_TMP" \
        "CREATE TABLE pfam (_id INTEGER REFERENCES genes(_id), ipi_id TEXT, pfam_id TEXT);"
fi

# PROSITE / UNIGENE: no data source in this pipeline yet. Stub empty rather
# than leaving the table missing, matching PFAM/IPI's treatment above.
sqlite3 -bail "$OUT_TMP" \
    "CREATE TABLE IF NOT EXISTS prosite (_id INTEGER REFERENCES genes(_id), ipi_id TEXT, prosite_id TEXT);"
sqlite3 -bail "$OUT_TMP" \
    "CREATE TABLE IF NOT EXISTS unigene (_id INTEGER REFERENCES genes(_id), unigene_id TEXT);"

# DBSCHEMA metadata row: required by AnnotationForge::makeAnnDbPkg()'s
# initWithDbMetada(), which hard-stops if it's absent (see Milestone 2/3).
sqlite3 -bail "$OUT_TMP" \
    "DELETE FROM metadata WHERE name = 'DBSCHEMA';
     INSERT INTO metadata (name, value) VALUES ('DBSCHEMA', '$DBSCHEMA');"

mv "$OUT_TMP" "$OUT"
echo "Done: $OUT ($(du -sh "$OUT" | cut -f1))"
