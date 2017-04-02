#!/bin/sh
set -e
if [ "$YGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

## unpack source data
cd ../$YGSOURCEDATE
gunzip -c gene_association.sgd.gz > gene_association.sgd
sed -i -e "/^\!.*$/d" gene_association.sgd
sed -i -e 's/[ \t]*$//' gene_association.sgd ## removes trailing whitespace.

# split alias column by |
rm -f gene2alias.tab
R --slave < ../script/parseAlias.R

# a.orf_decisions.txt: first line is column name
sed -e "1d" a.orf_decisions.txt > a.orf_decisions1.txt

# domains.tab has various number of columns (some lines 13, others 14)
awk '{print $1 "\t" $4 "\t" $5 "\t" $12}' domains.tab > domains1.tab

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
