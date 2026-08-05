#!/bin/sh
set -e

if [ $# -ne 1 ]; then
 echo "Usage: sh fixAnnoFile.sh <version>" >&2
 exit 1
fi

version=$1
ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
SANCTIONED_DIR=${SANCTIONED_SQLITE_DIR:-"$ROOT_DIR/newPkgs/sanctionedSqlite"}
INDEX_PATH=${ANNOTATIONFORGE_INDEX:-"$HOME/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT"}
tmp_file=$(mktemp "${TMPDIR:-/tmp}/ANNDBPKG-INDEX.XXXXXX")

if [ ! -f "$INDEX_PATH" ]; then
 echo "AnnotationForge index not found: $INDEX_PATH" >&2
 exit 1
fi

VERSION="$version" SANCTIONED_DIR="$SANCTIONED_DIR" perl -0pe '
 s/\b\d+\.\d+\.\d+\b/$ENV{VERSION}/g;
 s/newPipe/newPkgs/g;
 s{cpb_anno/AnnotationBuildPipeline/newPkgs/old_code/\d{4}\.\d{2}\.\d{2}}{$ENV{SANCTIONED_DIR}}g;
 s{/home/ubuntu/BioconductorAnnotationPipeline/newPkgs/sanctionedSqlite}{$ENV{SANCTIONED_DIR}}g;
' "$INDEX_PATH" > "$tmp_file"

mv "$tmp_file" "$INDEX_PATH"
