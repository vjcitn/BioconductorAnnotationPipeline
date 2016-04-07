#!/bin/sh
set -e
if [ "$PLASMOSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../processedFiles
cp plasmoDBSrc.sqlite ../../db/

## create organism specific homology sqlite files

cd ../../db
rm -f chipsrc_malaria.sqlite
sqlite3 -bail chipsrc_malaria.sqlite < ../plasmoDB/script/bindb_plasmoDB.sql

