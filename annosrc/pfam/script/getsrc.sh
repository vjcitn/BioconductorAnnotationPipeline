#!/bin/sh
set -e
if [ "$PFAMSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$PFAMSOURCEDATE/

## Reduce the HUGE 4 GB file down to just its ID components.
# gunzip Pfam-A.full.gz
echo "simplifyToIds ..."
sh ../script/simplifyToIds.sh
rm -f *.tab
echo "parseIDs ..."
R --slave < ../script/parseIDs.R

## remove the older DB and make a new one
echo "create the db ..."
rm -f PFAM.sqlite
sqlite3 -bail PFAM.sqlite < ../script/srcdb_pfam.sql

## record local metadata
echo "record download dates ..."
echo "INSERT INTO metadata VALUES('PFAMSOURCEDATE', '$PFAMSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('PFAMSOURCENAME', '$PFAMSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('PFAMSOURCEURL', '$PFAMSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail PFAM.sqlite < temp_metadata.sql
rm -f temp_metadata.sql

#put this in the DB
cp PFAM.sqlite ../../db

#then stick some stuff in for the metadata;
cd ../../db
sqlite3 -bail PFAM.sqlite < ../pfam/script/bindb_pfam.sql
echo "done!"
