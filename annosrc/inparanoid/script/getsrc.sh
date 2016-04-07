#!/bin/sh
set -e
if [ "$IPHVMSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$IPHVMSOURCEDATE/

## Note: Don't need to re-parse the static inparanoid data: 
## Run the script that parses the huge protein to gene ID maps.
###rm -f HsIDs.tab
###rm -f RnIDs.tab
# rm -f FBIDs.tab
# R --slave < ../script/parseIDs.R   ##To get this to run literally took an hour and 90% of the memory on merlot1 (~28 gigs)! (also works on gladstone)
 
## NOTE: Install InparanoidBaseBuilder package
echo "creating inparanoid.sqlite ..."
rm -f inparanoid.sqlite
sqlite3 -bail inparanoid.sqlite < ../script/srcdb2.sql
echo "inserting flybase data in inparanoid.sqlite ..."
echo "INSERT INTO metadata VALUES('FBSOURCEDATE', '$FBSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('FBSOURCENAME', '$FBSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('FBSOURCEURL', '$FBSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail inparanoid.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
echo "done!"
