#!/bin/sh
set -e
if [ "$TAIRSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$TAIRSOURCEDATE

## Skip these steps - data are already parsed.
## split locus column by ;
#R --slave < ../script/parseLocus.R
#echo "cleaning up the PMID sources"
#R --slave < ../script/cleanOutWhitespaceButNotTabs.R

## Rebuild db to incorporate new GO
rm -f tairsrc.sqlite

echo "Creating low-level tables"
sqlite3 -bail tairsrc.sqlite < ../script/srcdb.sql

echo "Populating low-level tables"
R --slave < ../script/populateTables.R

echo "Creating indices for low-level tables"
sqlite3 -bail tairsrc.sqlite < ../script/srcdb2.sql

## necessary ad hoc addition: now run an R script to download and then
## process the gff files and then add that info to sequenced genes
## table
R --slave < ../script/processGFFData.R

## record data download date
echo "INSERT INTO metadata VALUES('TAIRSOURCENAME', '$TAIRSOURCENAME');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRSOURCEDATE', '$TAIRSOURCEDATE');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRSOURCEURL', '$TAIRSOURCEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRGOURL', '$TAIRGOURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRGENEURL', '$TAIRGENEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRSYMBOLURL', '$TAIRSYMBOLURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRPATHURL', '$TAIRPATHURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRPMIDURL', '$TAIRPMIDURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRCHRURL', '$TAIRCHRURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRATHURL', '$TAIRATHURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('TAIRAGURL', '$TAIRAGURL');" >> temp_metadata.sql
sqlite3 -bail tairsrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
