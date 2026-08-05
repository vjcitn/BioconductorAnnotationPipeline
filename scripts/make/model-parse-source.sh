#!/bin/sh
set -e

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
source_name=${1:-}

if [ -z "$source_name" ]; then
 echo "Usage: sh scripts/make/model-parse-source.sh <source>" >&2
 exit 1
fi

case "$source_name" in
 go)
  script_dir="$ROOT_DIR/annosrc/go/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 gene)
  script_dir="$ROOT_DIR/annosrc/gene/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 goext)
  script_dir="$ROOT_DIR/annosrc/goext/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 ucsc)
  script_dir="$ROOT_DIR/annosrc/ucsc/script"
  script_name="getsrc.sh"
  script_args="human mouse rat canine bovine chicken fly fish yeast worm rhesus anopheles chimp pig"
 ;;
 yeast)
  script_dir="$ROOT_DIR/annosrc/yeast/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 plasmoDB)
  script_dir="$ROOT_DIR/annosrc/plasmoDB/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 pfam)
  script_dir="$ROOT_DIR/annosrc/pfam/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 inparanoid)
  script_dir="$ROOT_DIR/annosrc/inparanoid/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 tair)
  script_dir="$ROOT_DIR/annosrc/tair/script"
  script_name="getsrc.sh"
  script_args=""
 ;;
 ;;
cd "$script_dir"

if [ -z "$script_args" ]; then
 sh "$script_name"
else
 for arg in $script_args
 do
  sh "$script_name" "$arg"
 done
fi