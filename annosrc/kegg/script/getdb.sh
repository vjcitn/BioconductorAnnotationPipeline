#!/bin/sh
set -e
if [ "$PATHNAMESOURCEDATE" = "" ]; then
  . ./env.sh
fi

## create final sqlite db
rm -f ../../db/KEGG.sqlite
rm -f ../../db/keggsrc.sqlite
cp ../$PATHNAMESOURCEDATE/pathway_src.sqlite ../../db/keggsrc.sqlite

cd ../$KEGGSOURCEDATE
sqlite3 -bail ../../db/keggsrc.sqlite < ../script/bindb1.sql
cp ../../db/keggsrc.sqlite ../../db/KEGG.sqlite
sqlite3 -bail ../../db/keggsrc.sqlite < ../script/bindb2.sql

cd ../../goext/script
if [ "$GOEXTSOURCEDATE" = "" ]; then
  . ./env.sh
fi
cd ../$GOEXTSOURCEDATE
sqlite3 -bail ../../db/KEGG.sqlite < ../script/bindb.sql

cd ../../db
sqlite3 -bail KEGG.sqlite < ../kegg/script/bindb3.sql
