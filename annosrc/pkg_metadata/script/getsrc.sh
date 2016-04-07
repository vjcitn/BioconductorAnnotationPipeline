#!/bin/sh
set -e
rm -f ../metadatasrc.sqlite
sqlite3 -bail ../metadatasrc.sqlite < srcdb.sql



