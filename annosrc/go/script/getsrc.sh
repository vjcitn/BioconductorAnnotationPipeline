#!/bin/sh
set -e
if [ "$GOSOURCEDATE" = "" ]; then
  . ./env.sh
fi

#GOTERM_DIR=go_weekly-termdb-tables
GOTERM_DIR=.
GOTERM_TAR=$FILE
cd ../$GOSOURCEDATE
#rm -rf $GOTERM_DIR
#tar xvfz $GOTERM_TAR
rm -rf goterm
mkdir goterm
cd goterm
#ln -s $GOTERM_DIR goterm

Rscript ../../script/parseOBO.R

## create source sqlite db
cd ..
rm -f gosrcsrc.sqlite
sqlite3 -bail gosrcsrc.sqlite < ../script/srcdb.sql

## record data download date
echo "INSERT INTO metadata VALUES('GOSOURCENAME', '$GOSOURCENAME');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('GOSOURCEURL', '$GOSOURCEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('GOSOURCEDATE', '$GOSOURCEDATE');" >> temp_metadata.sql
sqlite3 -bail gosrcsrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
