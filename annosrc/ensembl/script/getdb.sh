#!/bin/sh
set -e
if [ "$ENSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../$ENSOURCEDATE

R --slave < ../script/bindb.R 
cd ../script
