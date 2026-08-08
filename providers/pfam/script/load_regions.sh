#!/usr/bin/env bash
# Load Pfam-A.regions.tsv.gz into PFAM.sqlite as the uniprot2pfam table.
# Detects column positions from the header so it is robust to column-order changes.
# Usage: load_regions.sh <sqlite_path> <regions_gz_path>
set -euo pipefail

SQLITE="${1:?Usage: load_regions.sh <sqlite_path> <regions_gz_path>}"
REGIONS="${2:?Usage: load_regions.sh <sqlite_path> <regions_gz_path>}"

echo "Reading header from $(basename "$REGIONS") ..."
set +o pipefail
HEADER=$(zcat "$REGIONS" | head -1)
set -o pipefail

COL_UP=$(echo "$HEADER" | tr '\t' '\n' | grep -in "pfamseq_acc\|uniprot" | head -1 | cut -d: -f1)
COL_PF=$(echo "$HEADER" | tr '\t' '\n' | grep -in "pfamA_acc\|pfam_acc" | head -1 | cut -d: -f1)

if [ -z "$COL_UP" ] || [ -z "$COL_PF" ]; then
    echo "ERROR: could not locate required columns." >&2
    echo "Header: $HEADER" >&2
    exit 1
fi
echo "  uniprot column: $COL_UP   pfam_acc column: $COL_PF"

echo "Creating uniprot2pfam table in $(basename "$SQLITE") ..."
sqlite3 "$SQLITE" "CREATE TABLE IF NOT EXISTS uniprot2pfam (uniprot_id TEXT, pfam_id TEXT);"

FIFO=$(mktemp -u /tmp/pfam_regions_XXXXXX)
mkfifo "$FIFO"
trap 'rm -f "$FIFO"' EXIT

echo "Streaming $(du -sh "$REGIONS" | cut -f1) -- progress every 5M rows ..."

zcat "$REGIONS" | awk -F'\t' -v up="$COL_UP" -v pf="$COL_PF" '
    NR > 1 {
        if ((NR-1) % 5000000 == 0) print "  " (NR-1)/1000000 " M rows" > "/dev/stderr"
        print $up "\t" $pf
    }
    END { print "  Done: " (NR-1) " rows" > "/dev/stderr" }
' > "$FIFO" &

sqlite3 "$SQLITE" <<EOF
.separator "	"
.import $FIFO uniprot2pfam
EOF

wait

echo "Indexing uniprot2pfam on uniprot_id ..."
sqlite3 "$SQLITE" "CREATE INDEX IF NOT EXISTS uniprot2pfam_uid ON uniprot2pfam(uniprot_id);"

N=$(sqlite3 "$SQLITE" "SELECT count(*) FROM uniprot2pfam;")
echo "Done: $N rows in uniprot2pfam"
