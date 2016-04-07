#!/bin/sh
set -e
if [ "$GOSOURCEDATE" = "" ]; then
  . ./env.sh
fi
cd ../$GOSOURCEDATE

## GO.sqlite:
## (Needs gosrcsrc.sqlite)
rm -f ../../db/GO.sqlite
sqlite3 -bail ../../db/GO.sqlite < ../script/bindb4.sql

## GO_ORGANISM_SPEC.sqlite:
## (Needs gosrcsrc.sqlite)

## Marc's notes:
## GO_ORGANISM_SPEC is not presently used for GO proper, BUT it is 
## used for the GO terms packed into the organism specific packages.
## (org packages and chip packages)  It's contents eventually are in the 
## gosrc.sqlite database, which is what we use for those packages.
## the terms in the ontology table made by GO_ORGANISM_SPEC are subtly 
## different in that go_offspring.ontology will be the category of the 
## ancestor term instead of the category of the offspring term.
## Also, if there is a pair ALL --> GO term, it will be left out of the
## tables created for the GO_ORGANISM_SPEC DB (the way things are coded 
## right now) 
rm -f ../../db/GO_ORGANISM_SPEC.sqlite
sqlite3 -bail ../../db/GO_ORGANISM_SPEC.sqlite < ../script/bindb1.sql

## Add gene mapping
cd ../../db
sqlite3 -bail GO_ORGANISM_SPEC.sqlite < ../go/script/bindb2.sql

## Add metadata and ... ?
## (Needs metadatasrc.sqlite, genesrc.sqlite)
sqlite3 -bail GO.sqlite < ../go/script/bindb5.sql
cd ../go/script
