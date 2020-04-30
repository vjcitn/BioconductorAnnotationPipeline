#!/bin/sh
set -e

SRC_BASE=`pwd`

# The build step creates the following sqlite files in the "db/" directory:
# chipmapsrc_<organism>.sqlite
# chipsrc_<organism>.sqlite
# genesrc.sqlite
# GO.sqlite  gosrc.sqlite
# KEGG.sqlite
# keggsrc.sqlite
# gpsrc.sqlite
# ipisrc.sqlite
# chrlength.sqlite

## Remove old sqlite files from the db/ directory. Save metadatasrc.sqlite.

## -----------------------------------------------------------------------
## Create chipmapsrc_* dbs: order matters
## -----------------------------------------------------------------------

## Copies chrlength.sqlite to db/
echo "copy chrlength.sqlite to db/"
cd $SRC_BASE/chrlength; sh getdb.sh

echo "building unigene"
cd $SRC_BASE/unigene/script; sh getdb.sh 
echo "finished unigene"

# Creates organism specific chipmapsrc packages; best to use screen or tmux
echo "building gene"
cd $SRC_BASE/gene/script; sh getdb.sh  
echo "finished gene"

## Marc notes that genesrc.sqlite get duplicate inserts after
## building 'gene'.
##echo "DELETE FROM metadata WHERE rowid > 3;" > temp.sql
##sqlite3 -bail db/genesrc.sqlite < temp.sql
##rm temp.sql
## Fix by hand:
#> dbGetQuery(con, "delete from metadata where rowid > 3")
#> dbGetQuery(con, "select * from metadata")
#          name                                value
#1 EGSOURCEDATE                           2017-Mar29
#2 EGSOURCENAME                          Entrez Gene
#3  EGSOURCEURL ftp://ftp.ncbi.nlm.nih.gov/gene/DATA

## -----------------------------------------------------------------------
## Create chipsrc_* dbs: order matters
## -----------------------------------------------------------------------

echo "building blast2go"
cd $SRC_BASE/blast2go/script; sh getdb.sh
echo "finished blast2go"

echo "building GO db1"
cd $SRC_BASE/go/script; sh getdb1.sh
echo "finished GO db1"

echo "building GO db2"
cd $SRC_BASE/go/script; sh getdb2.sh
echo "finished GO db2"

## Rebuilds KEGG.sqlite and keggsrc.sqlite with current GO
echo "building kegg"
cd $SRC_BASE/kegg/script; sh getdb.sh
echo "finished kegg"

## builds gpsrc.sqlite from all organisms
echo "building ucsc"
cd $SRC_BASE/ucsc/script; sh getdb.sh
echo "finished ucsc"

## Skeleton chipsrc_* packages using genesrc.sqlite.
## This is where map_counts are tallied.
echo "building organism_annotation"
cd $SRC_BASE/organism_annotation/script; sh getdb.sh
echo "finished organism_annotation"

echo "building yeast"
cd $SRC_BASE/yeast/script; sh getdb.sh 
echo "finished yeast"

echo "building plasmoDB"
cd $SRC_BASE/plasmoDB/script; sh getdb.sh  
echo "finished plasmoDB"

## Modified to build only flybase
echo "building inparanoid"
cd $SRC_BASE/inparanoid/script; sh getdb.sh  
echo "finished inparanoid"

echo "building ensembl"
cd $SRC_BASE/ensembl/script; sh getdb.sh  
echo "finished ensembl"

## Inserts ipi identifiers in pfam and prosite tables of chipsrc_* sqlite dbs
echo "building uniprot"
cd $SRC_BASE/uniprot/script; sh getdb.sh
echo "finished uniprot"

## Creates tairsrc.sqlite and writes to 
## chipsrc_arabidopsis AND chipmapsrc_arabidopsis 
echo "building tair"
cd $SRC_BASE/tair/script; sh getdb.sh  
echo "finished tair"
