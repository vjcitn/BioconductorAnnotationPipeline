#!/bin/sh
#set -e
if [ "$PLASMOSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$PLASMOSOURCEDATE/

## Clean and parse
rm -f ALIAStable.txt
rm -f GOtable.txt
rm -f SYMBOLtable.txt
rm -f plasmoDBSrc.sqlite
dos2unix ../script/extractPlasmoDBtables.R
R --slave < ../script/extractPlasmoDBtables.R
 
## remove the older DB and make a new one
echo "build the db ..."
cd ../processedFiles
rm -f plasmoDBSrc.sqlite
## need to remove stuff like this:
##PF13_0133	Sanger P. falciparum chromosomes
sed -i -e 's/^\S*\t*Sanger P. falciparum chromosomes$//g' ALIAStable.txt
sed -i -e '/^$/d' ALIAStable.txt
cat ALIAStable.txt | awk '{print $1 "\t" $2}' > ALIASTemp.txt
rm ALIAStable.txt
mv ALIASTemp.txt ALIAStable.txt
sqlite3 -bail plasmoDBSrc.sqlite < ../script/srcdb.sql

## record Inparanoid data download date
echo "record the download date ..."
echo "INSERT INTO metadata VALUES('PLASMOSOURCEDATE', '$PLASMOSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('PLASMOSOURCENAME', '$PLASMOSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('PLASMOSOURCEURL', '$PLASMOSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail plasmoDBSrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
echo "done!"
