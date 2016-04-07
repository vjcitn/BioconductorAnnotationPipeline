#!/bin/sh
set -e

# if [ "$BL2GOSOURCEDATE" = "" ]; then
#   . ./env.sh
# fi
# cd ../$BL2GOSOURCEDATE/

## now move things to the db dir so that we can finish the process of making the entrez gene 3 GO mapping.
# cp blast2go.sqlite ../../db
# cd ../../db
# sqlite3 -bail blast2go.sqlite < ../blast2go/script/bindb.sql

##Just combine the old getsrc.sh script with this one...

# if [ "$BL2GOSOURCEDATE" = "" ]; then
#   . ./env.sh
# fi

# cd ../$BL2GOSOURCEDATE/
## Run the script that parses the huge protein to gene ID maps.
# rm -f *.tab
# rm -f blast2go.sqlite
# R --slave < ../script/parseIDs.R
# sqlite3 -bail blast2go.sqlite < ../script/srcdb.sql
## record data alternate GO download date
## LATER ON in the process: When we come to the point where we are going to put this info. into another database,
## We will have to say DELETE FROM metadata WHERE VALUE = GOSOURCENAME etc before copying this metadata... 
## Or even better just comment that stuff out (if possible from being entered in 1st place)
# echo "CREATE TABLE metadata (name TEXT,value TEXT);" > temp_metadata.sql
# echo "INSERT INTO metadata VALUES('BL2GOSOURCENAME', '$BL2GOSOURCENAME');" >> temp_metadata.sql
# echo "INSERT INTO metadata VALUES('BL2GOSOURCEURL', '$BL2GOSOURCEURL');" >> temp_metadata.sql
# echo "INSERT INTO metadata VALUES('BL2GOSOURCEDATE', '$BL2GOSOURCEDATE');" >> temp_metadata.sql
# sqlite3 -bail blast2go.sqlite < temp_metadata.sql
# rm -f temp_metadata.sql
# R --slave < ../script/getBlast2Go.R


## New instructions:
R --slave < ../script/byPassBlast2GoAndInsteadUseUniProt.R

