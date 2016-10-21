#!/bin/sh
set -e
# this script was modified from http://www.sqlite.org/cvstrac/wiki?p=ConverterTools
    cat $1 |sed -e "s/^INSERT  IGNORE INTO/INSERT INTO/g"|
    grep "^INSERT INTO" |
    perl -e 'local $/;$_=<>;s/,\n\)/\n\)/gs;print "begin;\n";print;print "commit;\n"' |
    perl -pe '
        if (/^(INSERT.+?)\(/) {
                $a=$1;
                s/\\'\''/'\'\''/g;
                s/\\n/\n/g;
                s/\),\(/\);\n$a\(/g;
        }
    ' > InsertStmnts.sql
##|
##    sqlite3  $2 

