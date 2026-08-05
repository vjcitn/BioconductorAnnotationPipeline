#!/bin/sh
set -e

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
source_name=${1:-}

if [ -z "$source_name" ]; then
 echo "Usage: sh scripts/make/download-source.sh <source>" >&2
 exit 1
fi

case "$source_name" in
 go|gene|ucsc|yeast|plasmoDB|pfam|inparanoid|tair)
 ;;
 *)
 echo "Unknown download source: $source_name" >&2
 exit 1
 ;;
esac

cd "$ROOT_DIR/annosrc/$source_name/script"
sh download.sh