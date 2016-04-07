#!/bin/sh
set -e
if [ "$YGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$YGSOURCEDATE


## update to the latest GO.sqlite file local (so it can be attached)
rm -f GO.sqlite
cp ../../db/GO.sqlite .

# create, clean, and populate the new source sqlite file
# This part is moved out of getsrc.sh because it is dependent upon GO having been updated 1st.
echo "Creating low-level tables"
sqlite3 -bail sgdsrc.sqlite < ../script/srcdb.sql

## Investigate why the next two lines will sometimes fail if not run manually...
echo "Populating low-level tables"
R --slave < ../script/populateTables.R

echo "Creating indices for low-level tables"
sqlite3 -bail sgdsrc.sqlite < ../script/srcdb2.sql



## create final sqlite db
rm -f ../../db/YEAST.sqlite
sqlite3 -bail ../../db/YEAST.sqlite < ../script/bindb.sql

cd ../../db
sqlite3 -bail YEAST.sqlite < ../yeast/script/bindb2.sql
cp YEAST.sqlite chipsrc_yeast.sqlite

cd ../yeast/script
