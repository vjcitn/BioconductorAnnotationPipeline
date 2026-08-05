#!/bin/sh
set -e

## Copy select dbs into sanctionedSqlite and insert schema version metadata.

ROOT_DIR=${BIOCANNOPIPE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
BASEVERSION=${DBSCHEMAVERSION:-2.1}
COPYFROM=${ANNOSRC_DB_DIR:-"$ROOT_DIR/annosrc/db"}
COPYTO=${SANCTIONED_SQLITE_DIR:-"$ROOT_DIR/newPkgs/sanctionedSqlite"}

mkdir -p "$COPYTO"

for db_name in GO.sqlite PFAM.sqlite KEGG.sqlite YEAST.sqlite Orthology.eg.sqlite
do
 cp "$COPYFROM/$db_name" "$COPYTO/"
done

cd "$COPYTO"

## Remove org.*.sqlite files to avoid UNIQUE constraint errors on rebuild.
rm -f org.*.sqlite

for file in *.sqlite
do
 [ "$file" = '*.sqlite' ] && break
 printf "INSERT INTO metadata VALUES('DBSCHEMAVERSION', '%s');\n" "$BASEVERSION" > temp_metadata.sql
 sqlite3 -bail "$file" < temp_metadata.sql
 rm -f temp_metadata.sql
done
