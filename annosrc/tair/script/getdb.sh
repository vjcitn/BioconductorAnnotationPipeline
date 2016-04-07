#!/bin/sh
set -e
if [ "$TAIRSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$TAIRSOURCEDATE
## create final sqlite db
rm -f ../../db/chipsrc_arabidopsis.sqlite
rm -f ../../db/chipmapsrc_arabidopsis.sqlite
rm -f keggsrc.sqlite
rm -f gosrc.sqlite
rm -f GO.sqlite
rm -f chipsrc_arabidopsisNCBI.sqlite

ln -s ../../db/keggsrc.sqlite keggsrc.sqlite
ln -s ../../db/gosrc.sqlite gosrc.sqlite
ln -s ../../db/GO.sqlite GO.sqlite
ln -s ../../db/chipsrc_arabidopsisNCBI.sqlite chipsrc_arabidopsisNCBI.sqlite

sqlite3 -bail tairsrc.sqlite < ../script/cleanTairSrc.sql

sqlite3 -bail ../../db/chipsrc_arabidopsis.sqlite < ../script/bindb_ann.sql
sqlite3 -bail ../../db/chipmapsrc_arabidopsis.sqlite < ../script/bindb_map.sql
sqlite3 -bail ../../db/chipsrc_arabidopsis.sqlite < ../script/bindb_chrlengths.sql


echo "Verifying compatibility with current GO"
R --slave < ../script/checkGOCompatibility.R


rm -f keggsrc.sqlite
rm -f gosrc.sqlite

cd ../script

