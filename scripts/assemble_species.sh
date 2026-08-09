#!/usr/bin/env bash
# Usage: assemble_species.sh <species>
# Builds db/chipsrc_<species>.sqlite from provider SQLites.
# Must be run from the repository root (the top-level Makefile does this).
set -euo pipefail

SPECIES="${1:?Usage: assemble_species.sh <species>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DBDIR="$ROOT/db"
CONFIG="$ROOT/config/species.tsv"
ORGDIR="$ROOT/annosrc/organism_annotation/script"

# Validate species exists in config
TAXID=$(awk -v sp="$SPECIES" 'NR>1 && $1==sp {print $2}' "$CONFIG")
if [ -z "$TAXID" ]; then
    echo "ERROR: species '$SPECIES' not found in $CONFIG" >&2
    exit 1
fi

# ── KEGG stub ────────────────────────────────────────────────────────────────
# All bindb_*.sql scripts ATTACH keggsrc.sqlite. We don't run KEGG, so
# provide a stub with empty tables. Missing KEGG entries show up as 0 counts.
KEGGSTUB="$DBDIR/keggsrc.sqlite"
if [ ! -f "$KEGGSTUB" ]; then
    echo "Creating KEGG stub: $KEGGSTUB"
    sqlite3 "$KEGGSTUB" <<'KEGG_SQL'
CREATE TABLE metadata (name TEXT, value TEXT);
INSERT INTO metadata VALUES('KEGGSOURCENAME','KEGG (stub - not downloaded)');
INSERT INTO metadata VALUES('KEGGSOURCEURL','https://www.genome.jp/kegg/');
INSERT INTO metadata VALUES('KEGGSOURCEDATE','NA');
CREATE TABLE pathway2gene         (gene_or_orf_id TEXT, pathway_id TEXT);
CREATE TABLE ath_NCBI_pathway2gene(gene_or_orf_id TEXT, pathway_id TEXT);
CREATE TABLE hsa_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE mmu_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE rno_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE dre_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE dme_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE cel_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE sce_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE cfa_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE bta_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE ssc_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE gga_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE mcc_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE ptr_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE xla_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE ath_ncbi_ec(gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE aga_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE eco_ec     (gene_or_orf_id TEXT, ec_id TEXT);
CREATE TABLE ecs_ec     (gene_or_orf_id TEXT, ec_id TEXT);
KEGG_SQL
fi

# ── Map species name → SQL script name ───────────────────────────────────────
case "$SPECIES" in
    malaria)
        echo "ERROR: malaria requires plasmoDB provider (not yet implemented)" >&2
        exit 1 ;;
    *)
        SQLNAME="$SPECIES" ;;
esac

MAIN_SQL="$ORGDIR/bindb_${SQLNAME}.sql"
if [ ! -f "$MAIN_SQL" ]; then
    echo "ERROR: no assembly script at $MAIN_SQL" >&2
    exit 1
fi

# ── Build chipsrc_<species>.sqlite ───────────────────────────────────────────
OUT="$DBDIR/chipsrc_${SPECIES}.sqlite"
OUT_TMP="${OUT}.tmp"

echo "Assembling $OUT ..."
rm -f "$OUT_TMP"

# Preamble: stub table for UniProt (provider not yet available;
# uniprot table in chipsrc will be empty until a UniProt step is added).
sqlite3 -bail "$OUT_TMP" \
    "CREATE TABLE refseq_uniprot (refseq_id TEXT, uniprot_id TEXT);"

# All subsequent SQL runs from db/ so bare ATTACH paths resolve.
cd "$DBDIR"

sqlite3 -bail "$OUT_TMP" < "$MAIN_SQL"

# ── Meta scripts (sequence matches original getdb.sh) ────────────────────────
case "$SPECIES" in
    human)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta.sql"
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_OMIM.sql"
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_ucsc.sql"
        ;;
    mouse)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta.sql"
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_extra_meta_mouse.sql"
        ;;
    rat)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta.sql"
        ;;
    zebrafish)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta.sql"
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_fish.sql"
        ;;
    fly)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_fly.sql"
        ;;
    worm)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_worm.sql"
        ;;
    yeast)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_yeast.sql"
        ;;
    arabidopsis)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_arabidopsis.sql"
        ;;
    canine)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_canine.sql"
        ;;
    bovine)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_bovine.sql"
        ;;
    pig)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_pig.sql"
        ;;
    chicken)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_chicken.sql"
        ;;
    rhesus)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_rhesus.sql"
        ;;
    chimp)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_chimp.sql"
        ;;
    xenopus)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_xenopus.sql"
        ;;
    anopheles)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_anopheles.sql"
        ;;
    ecoliK12|ecoliSakai)
        sqlite3 -bail "$OUT_TMP" < "$ORGDIR/bindb_meta_ecoli.sql"
        ;;
esac

## ── UniProt enrichment (optional) ────────────────────────────────────────────
## If db/uniprot.sqlite exists, replace the empty uniprot table (populated from
## the refseq_uniprot stub) with direct gene→UniProt mappings, and add
## ensembl_pro / ensembl_trs tables for ENSEMBLPROT / ENSEMBLTRANS columns.
UNIPROTSRC="$DBDIR/uniprot.sqlite"
if [ -f "$UNIPROTSRC" ]; then
    echo "Enriching from uniprot.sqlite (taxid=$TAXID) ..."
    sqlite3 -bail "$OUT_TMP" <<EOF
ATTACH DATABASE '$UNIPROTSRC' AS up;

-- Replace stub-populated uniprot table with direct gene→UniProt mapping.
-- Some species (e.g. ecoli) have no uniprot table in their assembly SQL;
-- create it if absent so the enrichment step is safe for all species.
CREATE TABLE IF NOT EXISTS uniprot (
    _id       INTEGER REFERENCES genes(_id),
    uniprot_id TEXT
);
DELETE FROM uniprot;
INSERT OR IGNORE INTO uniprot (_id, uniprot_id)
    SELECT DISTINCT g._id, u.uniprot_id
    FROM genes g
    JOIN up.gene2uniprot u ON g.gene_id = u.gene_id
    WHERE u.taxon_id = '$TAXID';

-- Ensembl protein IDs (via gene→UniProt→Ensembl_PRO)
CREATE TABLE IF NOT EXISTS ensembl_pro (
    _id    INTEGER REFERENCES genes(_id),
    pro_id TEXT
);
INSERT OR IGNORE INTO ensembl_pro (_id, pro_id)
    SELECT DISTINCT g._id, ep.ensembl_pro_id
    FROM genes g
    JOIN up.gene2uniprot u  ON g.gene_id = u.gene_id AND u.taxon_id = '$TAXID'
    JOIN up.uniprot2ensembl_pro ep ON u.uniprot_id = ep.uniprot_id;
CREATE INDEX IF NOT EXISTS ensembl_pro__id ON ensembl_pro(_id);

-- Ensembl transcript IDs (via gene→UniProt→Ensembl_TRS)
CREATE TABLE IF NOT EXISTS ensembl_trs (
    _id    INTEGER REFERENCES genes(_id),
    trs_id TEXT
);
INSERT OR IGNORE INTO ensembl_trs (_id, trs_id)
    SELECT DISTINCT g._id, et.ensembl_trs_id
    FROM genes g
    JOIN up.gene2uniprot u  ON g.gene_id = u.gene_id AND u.taxon_id = '$TAXID'
    JOIN up.uniprot2ensembl_trs et ON u.uniprot_id = et.uniprot_id;
CREATE INDEX IF NOT EXISTS ensembl_trs__id ON ensembl_trs(_id);

DETACH DATABASE up;
EOF
    echo "  uniprot rows:     $(sqlite3 "$OUT_TMP" 'SELECT count(*) FROM uniprot;')"
    echo "  ensembl_pro rows: $(sqlite3 "$OUT_TMP" 'SELECT count(*) FROM ensembl_pro;')"
    echo "  ensembl_trs rows: $(sqlite3 "$OUT_TMP" 'SELECT count(*) FROM ensembl_trs;')"
fi

## ── Pfam enrichment (optional) ───────────────────────────────────────────────
## If db/PFAM.sqlite exists and the uniprot table is non-empty, populate a
## pfam table via gene→UniProt→Pfam. Runs after UniProt enrichment so the
## uniprot table is already fully populated.
PFAMSRC="$DBDIR/PFAM.sqlite"
if [ -f "$PFAMSRC" ]; then
    n_uni=$(sqlite3 "$OUT_TMP" 'SELECT count(*) FROM uniprot;' 2>/dev/null || echo 0)
    if [ "$n_uni" -gt 0 ]; then
        echo "Adding Pfam annotations from PFAM.sqlite (via UniProt bridge) ..."
        sqlite3 -bail "$OUT_TMP" <<EOF
ATTACH DATABASE '$PFAMSRC' AS pfsrc;

CREATE TABLE IF NOT EXISTS pfam (
    _id     INTEGER REFERENCES genes(_id),
    pfam_id TEXT
);

INSERT OR IGNORE INTO pfam (_id, pfam_id)
    SELECT DISTINCT u._id, p.pfam_id
    FROM uniprot u
    JOIN pfsrc.uniprot2pfam p ON u.uniprot_id = p.uniprot_id;

CREATE INDEX IF NOT EXISTS pfam__id ON pfam(_id);

DETACH DATABASE pfsrc;
EOF
        echo "  pfam rows: $(sqlite3 "$OUT_TMP" 'SELECT count(*) FROM pfam;')"
    else
        echo "Pfam skipped — uniprot table empty for taxid=$TAXID"
    fi
fi

mv "$OUT_TMP" "$OUT"
echo "Done: $OUT ($(du -sh "$OUT" | cut -f1))"
