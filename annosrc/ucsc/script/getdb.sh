#!/bin/sh
set -e

## create final sqlite db
rm -f ../../db/gpsrc.sqlite
sqlite3 -bail ../../db/gpsrc.sqlite < bindb.sql

## R --slave < correctOffByOneUCSCStartErrors.R
