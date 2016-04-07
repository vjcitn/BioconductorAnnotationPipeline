#!/bin/sh
#set -e


BASEVERSION=2.1
 
echo "INSERT INTO metadata VALUES('DBSCHEMAVERSION', '$BASEVERSION');" > temp_metadata.sql
sqlite3 -bail GO.sqlite < temp_metadata.sql
sqlite3 -bail PFAM.sqlite < temp_metadata.sql
sqlite3 -bail KEGG.sqlite < temp_metadata.sql
sqlite3 -bail YEAST.sqlite < temp_metadata.sql
rm -f temp_metadata.sql

