#!/bin/sh
set -e
if [ "$IPHVMSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$FBSOURCEDATE

## No longer necessary to build this:
#R --slave < ../script/bindb.R
#mv hom.* ../../db/

## We do update flybase which affects the chipsrc db:
sqlite3 -bail ../../db/chipsrc_fly.sqlite < ../script/bindb_flyExtras.sql

cd ../script
