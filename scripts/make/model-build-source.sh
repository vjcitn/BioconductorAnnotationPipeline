#!/bin/sh
set -e

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
source_name=${1:-}

if [ -z "$source_name" ]; then
 echo "Usage: sh scripts/make/model-build-source.sh <source>" >&2
 exit 1
fi

case "$source_name" in
 chrlength)
  work_dir="$ROOT_DIR/annosrc/chrlength"
  cmd="sh getdb.sh"
 ;;
 gene)
  work_dir="$ROOT_DIR/annosrc/gene/script"
  cmd="sh getdb.sh"
 ;;
 blast2go)
  work_dir="$ROOT_DIR/annosrc/blast2go/script"
  cmd="sh getdb.sh"
 ;;
 go-db1)
  work_dir="$ROOT_DIR/annosrc/go/script"
  cmd="sh getdb1.sh"
 ;;
 go-db2)
  work_dir="$ROOT_DIR/annosrc/go/script"
  cmd="sh getdb2.sh"
 ;;
 kegg)
  work_dir="$ROOT_DIR/annosrc/kegg/script"
  cmd="sh getdb.sh"
 ;;
 ucsc)
  work_dir="$ROOT_DIR/annosrc/ucsc/script"
  cmd="sh getdb.sh"
 ;;
 organism_annotation)
  work_dir="$ROOT_DIR/annosrc/organism_annotation/script"
  cmd="sh getdb.sh"
 ;;
 yeast)
  work_dir="$ROOT_DIR/annosrc/yeast/script"
  cmd="sh getdb.sh"
 ;;
 plasmoDB)
  work_dir="$ROOT_DIR/annosrc/plasmoDB/script"
  cmd="sh getdb.sh"
 ;;
 inparanoid)
  work_dir="$ROOT_DIR/annosrc/inparanoid/script"
  cmd="sh getdb.sh"
 ;;
 ensembl)
  work_dir="$ROOT_DIR/annosrc/ensembl/script"
  cmd="sh getdb.sh"
 ;;
 uniprot)
  work_dir="$ROOT_DIR/annosrc/uniprot/script"
  cmd="sh getdb.sh"
 ;;
 tair)
  work_dir="$ROOT_DIR/annosrc/tair/script"
  cmd="sh getdb.sh"
 ;;
 *)
  echo "Unknown build source: $source_name" >&2
  exit 1
 ;;
esac

cd "$work_dir"

sh -c "$cmd"