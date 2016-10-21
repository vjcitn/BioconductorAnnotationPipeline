#!/bin/sh
set -e
if [ "$PATHNAMESOURCEDATE" = "" ]; then
  . ./env.sh
fi

## create source sqlite db
cd ../$PATHNAMESOURCEDATE
rm -f pathway_src.sqlite

#Optionally, remove duplicated term for metabolism!
#I Can add more terms here is KEGG insists on being stupid...
#but if this persists, then this will not be viable long term.
##sed -i -e "s/09010\tMetabolism//g" map_title.tab
#Then remove blank lines.
sed -i -e '/^$/d' map_title.tab
#Remove the line (and ONLY this one line) that says " map"
# grep -vx "map" map_title.tab > map_title.tab
##sed -i -e "s/ map//g" map_title.tab

sqlite3 -bail pathway_src.sqlite < ../script/pathway.sql

## record data download date
echo "INSERT INTO metadata VALUES('PATHNAMESOURCENAME', '$PATHNAMESOURCENAME');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('PATHNAMESOURCEURL', '$PATHNAMESOURCEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('PATHNAMESOURCEDATE', '$PATHNAMESOURCEDATE');" >> temp_metadata.sql
sqlite3 -bail pathway_src.sqlite < temp_metadata.sql
rm -f temp_metadata.sql

