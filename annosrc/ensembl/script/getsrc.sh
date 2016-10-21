#!/bin/sh
set -e
if [ "$ENSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$ENSOURCEDATE/

echo "parse protein to gene ID maps ..."
rm -f *.tab
R --slave < ../script/parseIDs.R 
 
echo "build db ..."
rm -f ensembl.sqlite
sqlite3 -bail ensembl.sqlite < ../script/srcdb.sql

echo "get ensembl to NCBI mappings ..."
R --slave < ../script/getEnsemblMappings.R 
## For mosquito and fly; don't think it's used anymore
# R --slave < ../script/getAltUniprotMappings.R

## record download date
echo "record download date ..."
echo "INSERT INTO metadata VALUES('ENSOURCEDATE', '$ENSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('ENSOURCENAME', '$ENSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('ENSOURCEURL', '$ENSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail ensembl.sqlite < temp_metadata.sql
rm -f temp_metadata.sql

cp ensembl.sqlite ../../db
echo "done!"
