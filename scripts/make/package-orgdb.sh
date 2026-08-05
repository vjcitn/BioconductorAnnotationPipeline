#!/bin/sh
set -e

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
PKG_DATE=${PKG_DATE:?PKG_DATE must be set}
PKG_VERSION=${PKG_VERSION:?PKG_VERSION must be set}
RSCRIPT_BIN=${RSCRIPT_BIN:-Rscript}

export BIOCANNOPIPE_ROOT="$ROOT_DIR"
export SANCTIONED_SQLITE_DIR=${SANCTIONED_SQLITE_DIR:-"$ROOT_DIR/newPkgs/sanctionedSqlite"}
export ANNOTATIONFORGE_INDEX=${ANNOTATIONFORGE_INDEX:-"$HOME/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT"}
export PACKAGE_OUTPUT_BASE_DIR=${PACKAGE_OUTPUT_BASE_DIR:-"$ROOT_DIR/newPkgs"}
export ANNOSRC_DB_DIR=${ANNOSRC_DB_DIR:-"$ROOT_DIR/annosrc/db"}

cd "$ROOT_DIR/newPkgs"
sh fixAnnoFile.sh "$PKG_VERSION"

cd "$ROOT_DIR/annosrc"
sh copyLatest.sh

cd "$ROOT_DIR/newPkgs"
"$RSCRIPT_BIN" makeTerminalDBPkgs.R OrgDb "$PKG_DATE" "$PKG_VERSION"