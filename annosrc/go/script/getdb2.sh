#!/bin/sh
set -e
cd ../../db

## gosrc.sqlite:
## (Needs GO_ORGANISM_SPEC.sqlite)
rm -f gosrc.sqlite
sqlite3 -bail gosrc.sqlite < ../go/script/bindb3.sql
