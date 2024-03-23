#!/bin/sh
set -e
if [ "$YGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

## unpack source data
cd ../$YGSOURCEDATE
zcat gene_association.sgd.gaf.gz | awk -F'\t' '!/\!/' > gene_association.sgd

# split alias column by |
rm -f gene2alias.tab
R --slave < ../script/parseAlias.R

# a.orf_decisions.txt: first line is column name
sed -e "1d" a.orf_decisions.txt > a.orf_decisions1.txt

# select correct columns from domains.tab
zcat domains_201610.tab.gz | cut -f 1,4,5,12 - > domains1.tab

## remove old source sqlite db
rm -f sgdsrc.sqlite


## record data download date
echo "DROP TABLE IF EXISTS metadata;" > temp_metadata.sql
echo "CREATE TABLE metadata (name TEXT, value TEXT);" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('YGSOURCENAME', '$YGSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('YGSOURCEURL', '$YGSOURCEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('YGSOURCEDATE', '$YGSOURCEDATE');" >> temp_metadata.sql
sqlite3 -bail sgdsrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
