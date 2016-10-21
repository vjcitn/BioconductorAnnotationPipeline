#!/bin/sh

# Converts a mysqldump file into a Sqlite 3 compatible file. It also
# extracts the MySQL `KEY xxxxx` from the CREATE block and create them
# in separate commands _after_ all the INSERTs.

# Awk is choosen because it's fast and portable. You can use gawk,
# original awk or even the lightning fast mawk.  The mysqldump file is
# traversed only once.

# Usage: 
# $ ./mysql2sqlite.sh mysqldump-opts db-name | sqlite3 database.sqlite 

# Example: 
# $ ./mysql2sqlite.sh --no-data -u root -p myDbase | sqlite3 test.sqlite

## my example:
## sh mysql2sqlite.sh sql | sqlite3 test2.sqlite

## new example
## cat sql | ./mysql2sqlite_forDumps.sh | sqlite3 test.sqlite ## has issues

## But this gets us closer
## cat sql | ./mysql2sqlite_forDumps.sh > sqlite.sql
## And this should maybe help?
## cp sqlite.sql sqlite2.sql
## sed -i -e "s/\`//g" sqlite2.sql
## cp sqlite2.sql sqlite3.sql
## sed -i -e "s/INSERT/);\nINSERT/g" sqlite3.sql

## The mysql2sqlitePerlScript.sh can extract out the insert data into
## simple insert statements like this:
## sh mysql2sqlitePerlScript.sh sqlite3.sql 
## Then just run the code to extract out the CREATE TABLE statements too.
## ##sh mysql2sqlitePerlCreateTableScript.sh sqlite3.sql
## INSTEAD, I used the R code to generate the createStatements.sql (with more plans for the future)
## sqlite3 -bail reactome.sqlite < createStatements.sql
## sqlite3 -bail reactome.sqlite < InsertStmnts.sql

# Thanks to and @artemyk and @gkuenning for their nice tweaks.

# mysqldump --compatible=ansi --skip-extended-insert --compact "$@" | \

awk '

BEGIN {
FS=",$"
print "PRAGMA synchronous = OFF;"
print "PRAGMA journal_mode = MEMORY;"
print "BEGIN TRANSACTION;"
}

# CREATE TRIGGER statements have funny commenting. Remember we are in trigger.
/^\/\*.*CREATE.*TRIGGER/ {
gsub( /^.*TRIGGER/, "CREATE TRIGGER" )
print
inTrigger = 1
next
}

# The end of CREATE TRIGGER has a stray comment terminator
/END \*\/;;/ { gsub( /\*\//, "" ); print; inTrigger = 0; next }

# The rest of triggers just get passed through
inTrigger != 0 { print; next }

# Skip other comments
/^\/\*/ { next }

# Print all `INSERT` lines. The single quotes are protected by another single quote.
/INSERT/ {
gsub( /\\\047/, "\047\047" )
gsub(/\\n/, "\n")
gsub(/\\r/, "\r")
gsub(/\\"/, "\"")
gsub(/\\\\/, "\\")
gsub(/\\\032/, "\032")
print
next
}

# Print the `CREATE` line as is and capture the table name.
/^CREATE/ {
print
if ( match( $0, /\"[^\"]+/ ) ) tableName = substr( $0, RSTART+1, RLENGTH-1 )
}

# Replace `FULLTEXT KEY` or any other `XXXXX KEY` except PRIMARY by `KEY`
/^ [^"]+KEY/ && !/^ PRIMARY KEY/ { gsub( /.+KEY/, " KEY" ) }

# Get rid of field lengths in KEY lines
/ KEY/ { gsub(/\([0-9]+\)/, "") }

# Print all fields definition lines except the `KEY` lines.
/^ / && !/^( KEY|\);)/ {
gsub( /AUTO_INCREMENT|auto_increment/, "" )
gsub( /(CHARACTER SET|character set) [^ ]+ /, "" )
gsub( /DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP|default current_timestamp on update current_timestamp/, "" )
gsub( /(COLLATE|collate) [^ ]+ /, "" )
gsub(/(ENUM|enum)[^)]+\)/, "text ")
gsub(/(SET|set)\([^)]+\)/, "text ")
gsub(/UNSIGNED|unsigned/, "")
if (prev) print prev ","
prev = $1
}

# `KEY` lines are extracted from the `CREATE` block and stored in array for later print
# in a separate `CREATE KEY` command. The index name is prefixed by the table name to
# avoid a sqlite error for duplicate index name.
/^( KEY|\);)/ {
if (prev) print prev
prev=""
if ($0 == ");"){
print
} else {
if ( match( $0, /\"[^"]+/ ) ) indexName = substr( $0, RSTART+1, RLENGTH-1 )
if ( match( $0, /\([^()]+/ ) ) indexKey = substr( $0, RSTART+1, RLENGTH-1 )
key[tableName]=key[tableName] "CREATE INDEX \"" tableName "_" indexName "\" ON \"" tableName "\" (" indexKey ");\n"
}
}

# Print all `KEY` creation lines.
END {
for (table in key) printf key[table]
print "END TRANSACTION;"
}
'
exit 0