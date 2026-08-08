#!/usr/bin/env bash
# Build db/uniprot.sqlite from UniProt idmapping_selected.tab.gz.
#
# idmapping_selected.tab has no header. Fixed column layout (UniProt docs):
#   1  UniProtKB-AC       <- uniprot_id
#   3  GeneID (Entrez)    <- gene_id   (semicolon-separated)
#   4  RefSeq             <- refseq_id (semicolon-separated)
#  13  NCBI-taxon         <- taxon_id
#  20  Ensembl_TRS        <- ensembl transcript IDs (semicolon-separated)
#  21  Ensembl_PRO        <- ensembl protein IDs    (semicolon-separated)
#
# One awk pass writes four temp TSVs to WORKDIR; each is then streamed
# into SQLite via a FIFO. Temp files are removed after loading.
#
# Usage: build_uniprot.sh <sqlite_path> <idmapping_gz> <workdir>
set -euo pipefail

SQLITE="${1:?Usage: build_uniprot.sh <sqlite_path> <idmapping_gz> <workdir>}"
IDMAP="${2:?}"
WORKDIR="${3:?}"

G2U="$WORKDIR/.gene2uniprot.tsv"
R2U="$WORKDIR/.refseq2uniprot.tsv"
U2EP="$WORKDIR/.uniprot2ensembl_pro.tsv"
U2ET="$WORKDIR/.uniprot2ensembl_trs.tsv"

## ── Create tables ─────────────────────────────────────────────────────────────
sqlite3 "$SQLITE" <<'SQL'
CREATE TABLE gene2uniprot (
    uniprot_id TEXT,
    gene_id    TEXT,
    taxon_id   TEXT
);
CREATE TABLE refseq2uniprot (
    refseq_id  TEXT,
    uniprot_id TEXT
);
CREATE TABLE uniprot2ensembl_pro (
    uniprot_id     TEXT,
    ensembl_pro_id TEXT
);
CREATE TABLE uniprot2ensembl_trs (
    uniprot_id     TEXT,
    ensembl_trs_id TEXT
);
CREATE TABLE metadata (name TEXT PRIMARY KEY, value TEXT);
SQL

## ── Single awk pass → four temp TSVs ─────────────────────────────────────────
echo "Streaming $(du -sh "$IDMAP" | cut -f1) -- progress every 5M rows ..."
zcat "$IDMAP" | awk -F'\t' \
    -v g="$G2U" -v r="$R2U" -v ep="$U2EP" -v et="$U2ET" '
BEGIN { n = 0 }
{
    n++
    if (n % 5000000 == 0) print "  " n/1000000 " M rows" > "/dev/stderr"

    uid   = $1
    taxon = $13

    # gene2uniprot (col 3: GeneID, semicolon-separated)
    if ($3 != "") {
        m = split($3, a, "; ")
        for (i = 1; i <= m; i++)
            if (a[i] != "") print uid "\t" a[i] "\t" taxon >> g
    }

    # refseq2uniprot (col 4: RefSeq, semicolon-separated)
    if ($4 != "") {
        m = split($4, a, "; ")
        for (i = 1; i <= m; i++)
            if (a[i] != "") print a[i] "\t" uid >> r
    }

    # uniprot2ensembl_pro (col 21: Ensembl_PRO)
    if ($21 != "") {
        m = split($21, a, "; ")
        for (i = 1; i <= m; i++)
            if (a[i] != "") print uid "\t" a[i] >> ep
    }

    # uniprot2ensembl_trs (col 20: Ensembl_TRS)
    if ($20 != "") {
        m = split($20, a, "; ")
        for (i = 1; i <= m; i++)
            if (a[i] != "") print uid "\t" a[i] >> et
    }
}
END { print "  Done: " n " rows processed" > "/dev/stderr" }
'

## ── Load each TSV into SQLite via FIFO ───────────────────────────────────────
load_tsv() {
    local FILE="$1" TABLE="$2"
    if [ ! -f "$FILE" ]; then
        echo "  WARNING: $TABLE — no data extracted, skipping" >&2
        return
    fi
    echo "Loading $TABLE ..."
    local FIFO
    FIFO=$(mktemp -u /tmp/up_XXXXXX)
    mkfifo "$FIFO"
    trap 'rm -f "$FIFO"' RETURN
    cat "$FILE" > "$FIFO" &
    sqlite3 "$SQLITE" <<EOF
.separator "	"
.import $FIFO $TABLE
EOF
    wait
    rm -f "$FILE"
    local N
    N=$(sqlite3 "$SQLITE" "SELECT count(*) FROM $TABLE;")
    echo "  $TABLE: $N rows"
}

load_tsv "$G2U"  gene2uniprot
load_tsv "$R2U"  refseq2uniprot
load_tsv "$U2EP" uniprot2ensembl_pro
load_tsv "$U2ET" uniprot2ensembl_trs

## ── Indexes ───────────────────────────────────────────────────────────────────
echo "Building indexes ..."
sqlite3 "$SQLITE" <<'SQL'
CREATE INDEX gene2uniprot_gene   ON gene2uniprot(gene_id);
CREATE INDEX gene2uniprot_taxon  ON gene2uniprot(taxon_id);
CREATE INDEX gene2uniprot_uid    ON gene2uniprot(uniprot_id);
CREATE INDEX refseq2uniprot_ref  ON refseq2uniprot(refseq_id);
CREATE INDEX up2ep_uid           ON uniprot2ensembl_pro(uniprot_id);
CREATE INDEX up2et_uid           ON uniprot2ensembl_trs(uniprot_id);
SQL

## ── Metadata ──────────────────────────────────────────────────────────────────
DATE=$(date +%Y-%b%d)
sqlite3 "$SQLITE" <<SQL
INSERT INTO metadata VALUES('UPSOURCENAME','UniProt');
INSERT INTO metadata VALUES('UPSOURCEURL','https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping');
INSERT INTO metadata VALUES('UPSOURCEDATE','$DATE');
SQL

echo "Done: $(du -sh "$SQLITE" | cut -f1) uniprot.sqlite"
