#!/bin/sh
set -e
if [ "$ENSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$ENSOURCEDATE

## All replaced by bindb.R
#sqlite3 -bail ../../db/chipsrc_human.sqlite < ../script/bindb.sql
#sqlite3 -bail ../../db/chipsrc_rat.sqlite < ../script/bindb_rat.sql
#sqlite3 -bail ../../db/chipsrc_mouse.sqlite < ../script/bindb_mouse.sql
#sqlite3 -bail ../../db/chipsrc_zebrafish.sqlite < ../script/bindb_fish.sql
#sqlite3 -bail ../../db/chipsrc_canine.sqlite < ../script/bindb_canine.sql
#sqlite3 -bail ../../db/chipsrc_bovine.sqlite < ../script/bindb_bovine.sql
#sqlite3 -bail ../../db/chipsrc_worm.sqlite < ../script/bindb_worm.sql
#sqlite3 -bail ../../db/chipsrc_chicken.sqlite < ../script/bindb_chicken.sql
#sqlite3 -bail ../../db/chipsrc_rhesus.sqlite < ../script/bindb_rhesus.sql
#sqlite3 -bail ../../db/chipsrc_anopheles.sqlite < ../script/bindb_anopheles.sql
#sqlite3 -bail ../../db/chipsrc_chimp.sqlite < ../script/bindb_chimp.sql

R --slave < ../script/bindb.R 
cd ../script
