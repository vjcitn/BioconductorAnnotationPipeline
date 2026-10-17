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
CONFIG="${CONFIG:-$ROOT/config/species.tsv}"

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

TAXID="$(awk -F'\t' -v s="$SPECIES" 'NR==1{for(i=1;i<=NF;i++) if($i=="taxid") c=i} $1==s{print $c}' "$CONFIG")"
GENUS="$(awk -F'\t' -v s="$SPECIES" 'NR==1{for(i=1;i<=NF;i++) if($i=="genus") c=i} $1==s{print $c}' "$CONFIG")"
SPECIESEPITHET="$(awk -F'\t' -v s="$SPECIES" 'NR==1{for(i=1;i<=NF;i++) if($i=="species") c=i} $1==s{print $c}' "$CONFIG")"
ORGANISM="$GENUS $SPECIESEPITHET"
SPECIES_TAG="$(printf '%s' "$SPECIES" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"

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

# go / go_all views: resolves the "GO is special" open question from
# PlanFor3.24.md empirically. The legacy GO Bimap (Go3AnnDbBimap) queries
# go_bp/go_cc/go_mf directly and needs no schema change, and GOALL has
# never had a legacy Bimap even in production org.*.eg.db packages — but
# the *modern* bare-OrgDb keys()/select() dispatch for GOALL (and, if the
# Bimap-aware path for GO were ever bypassed, GO too) falls through to the
# generic .definePossibleTables() literal-table lookup, which expects
# single tables named "go"/"go_all" with an "ontology" column. Confirmed
# by empirical test: without this view, keys(x, keytype="GOALL") raised
# "no such table: go_all".
sqlite3 -bail "$OUT_TMP" \
    "DROP VIEW IF EXISTS go;
     CREATE VIEW go AS
         SELECT _id, go_id, evidence, 'BP' AS ontology FROM go_bp
         UNION ALL SELECT _id, go_id, evidence, 'CC' AS ontology FROM go_cc
         UNION ALL SELECT _id, go_id, evidence, 'MF' AS ontology FROM go_mf;
     DROP VIEW IF EXISTS go_all;
     CREATE VIEW go_all AS
         SELECT _id, go_id, evidence, 'BP' AS ontology FROM go_bp_all
         UNION ALL SELECT _id, go_id, evidence, 'CC' AS ontology FROM go_cc_all
         UNION ALL SELECT _id, go_id, evidence, 'MF' AS ontology FROM go_mf_all;"

# DBSCHEMA metadata row: required by AnnotationForge::makeAnnDbPkg()'s
# initWithDbMetada(), which hard-stops if it's absent (see Milestone 2/3).
sqlite3 -bail "$OUT_TMP" \
    "DELETE FROM metadata WHERE name = 'DBSCHEMA';
     INSERT INTO metadata (name, value) VALUES ('DBSCHEMA', '$DBSCHEMA');"

# "Db type" metadata row: .makeAnnDbPkg() reads this directly (not via
# initWithDbMetada) to decide whether to resolve an org-package dependency
# (ChipDb) or not (OrgDb); missing/empty value crashes with "argument is of
# length zero" before any other error reporting.
sqlite3 -bail "$OUT_TMP" \
    "DELETE FROM metadata WHERE name = 'Db type';
     INSERT INTO metadata (name, value) VALUES ('Db type', 'OrgDb');"

# DBSCHEMAVERSION / "Supporting package": checked by the OrgDb/AnnotationDbi
# package's .onLoad() (dbmeta(dbconn, "DBSCHEMAVERSION")), not by
# makeAnnDbPkg() itself — their absence doesn't fail the build, only
# loading the resulting package. "2.1" matches the schema version real
# installed OrgDb packages (e.g. org.Hs.eg.db) carry as of AnnotationDbi's
# current schema.
sqlite3 -bail "$OUT_TMP" \
    "DELETE FROM metadata WHERE name IN ('DBSCHEMAVERSION', 'Supporting package');
     INSERT INTO metadata (name, value) VALUES
         ('DBSCHEMAVERSION', '2.1'),
         ('Supporting package', 'AnnotationDbi');"

if [ -n "$TAXID" ]; then
    sqlite3 -bail "$OUT_TMP" \
        "DELETE FROM metadata WHERE name = 'TAXID';
         INSERT INTO metadata (name, value) VALUES ('TAXID', '$TAXID');"
fi

# ORGANISM/SPECIES/CENTRALID: AnnotationDbi::species() (and from there
# .definePossibleTables()'s per-organism exception blocks — e.g. Human
# gets OMIM/UCSCKG added) reads the 'ORGANISM' metadata row directly from
# the sqlite at query time. makeAnnDbPkg() never writes this itself — the
# AnnDbPkgSeed's organism/species slots only drive man-page text, not the
# database — so without this row species() silently returns character(0)
# and every organism-specific keytype (ENSEMBL, PFAM, OMIM, UCSCKG, ...)
# vanishes from keytypes()/columns() despite the Bimap objects existing.
sqlite3 -bail "$OUT_TMP" \
    "DELETE FROM metadata WHERE name IN ('ORGANISM', 'SPECIES', 'CENTRALID');
     INSERT INTO metadata (name, value) VALUES
         ('ORGANISM', '$ORGANISM'),
         ('SPECIES', '$SPECIES_TAG'),
         ('CENTRALID', 'EG');"

# map_metadata gaps: makeAnnDbPkg()'s man-page generation needs a
# map_metadata row for every map name HUMAN_DB's .definePossibleTables()
# expects (22 total), used to fill in e.g. @ALIAS2EGSOURCE@ in the Rd
# template. annosrc/organism_annotation/script/bindb_meta.sql populates
# ACCNUM/CHR/CHRLOC/CHRLOCEND/ENZYME/GENENAME/GO/MAP/GENETYPE/PATH/PMID/
# REFSEQ/SYMBOL/PFAM/PROSITE/ENSEMBL/UNIPROT, and bindb_OMIM.sql/
# bindb_meta_ucsc.sql add OMIM/UCSCKG — but never ALIAS2EG (only the
# differently-named ALIAS2GENE), ENSEMBLPROT, or ENSEMBLTRANS. Without
# these three, makeAnnDbPkg() hard-fails with "UNRESOLVED SYMBOLS" while
# building the man pages. Backfill them here, copying source provenance
# from the nearest existing row (ACCNUM for ALIAS2EG, ENSEMBL for the
# other two), matching the pattern bindb_meta.sql itself already uses
# for OMIM/UCSCKG.
if has_table map_metadata; then
    sqlite3 -bail "$OUT_TMP" <<'SQL'
INSERT INTO map_metadata
 SELECT 'ALIAS2EG', source_name, source_url, source_date
 FROM map_metadata WHERE map_name='ACCNUM'
 AND NOT EXISTS (SELECT 1 FROM map_metadata WHERE map_name='ALIAS2EG');

INSERT INTO map_metadata
 SELECT 'ENSEMBLPROT', source_name, source_url, source_date
 FROM map_metadata WHERE map_name='ENSEMBL'
 AND NOT EXISTS (SELECT 1 FROM map_metadata WHERE map_name='ENSEMBLPROT');

INSERT INTO map_metadata
 SELECT 'ENSEMBLTRANS', source_name, source_url, source_date
 FROM map_metadata WHERE map_name='ENSEMBL'
 AND NOT EXISTS (SELECT 1 FROM map_metadata WHERE map_name='ENSEMBLTRANS');
SQL
fi

# map_counts ENTREZID phantom entry: bindb_meta.sql (annosrc/organism_
# annotation/script/bindb_meta.sql, line ~103-105) inserts a map_counts
# row 'ENTREZID' = count(*) FROM genes. AnnotationDbi:::createMAPCOUNTS()
# builds the package's exported MAPCOUNTS vector straight from this
# table (excluding only 'TOTAL' by name), so MAPCOUNTS ends up listing
# org.<X>.egENTREZID -- but ENTREZID is the central gene ID, not a
# separate map, so makeAnnDbPkg() never creates a Bimap/env object by
# that name. AnnotationDbi::checkMAPCOUNTS() -- called from the
# auto-generated MAPCOUNTS.Rd example run by R CMD check --examples --
# special-cases PFAM/PROSITE this same way but not ENTREZID, so it
# calls get('org.<X>.egENTREZID', ...), which fails with "object not
# found" and aborts R CMD check. This is a legacy bindb_meta.sql
# characteristic (present for every species, not introduced by this
# pipeline); drop the row here so MAPCOUNTS never claims a map that
# doesn't exist.
if has_table map_counts; then
    sqlite3 -bail "$OUT_TMP" \
        "DELETE FROM map_counts WHERE map_name = 'ENTREZID';"
fi

mv "$OUT_TMP" "$OUT"
echo "Done: $OUT ($(du -sh "$OUT" | cut -f1))"
