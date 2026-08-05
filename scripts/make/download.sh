#!/bin/sh
set -e

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}

cd "$ROOT_DIR/annosrc"
sh src_download.sh