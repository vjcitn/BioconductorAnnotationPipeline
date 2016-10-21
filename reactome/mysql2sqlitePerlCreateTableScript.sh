#!/bin/sh
set -e
# this script is just meant to pull out all lines starting with CREATE
# and leading up to );

cat $1 | sed -n '/CREATE TABLE/,/);/p' > CreateStmnts.sql

## usage: sh mysql2sqlitePerlCreateTableScript.sh sqlite3.sql
