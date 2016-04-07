#!/bin/sh
set -e

SRC_BASE=`pwd`

# create the following sqlite dbs and store them in folder "db"
# chipmapsrc_<organism>.sqlite
# chipsrc_<organism>.sqlite
# genesrc.sqlite
# GO.sqlite  gosrc.sqlite
# KEGG.sqlite keggsrc.sqlite
# gpsrc.sqlite
# ipisrc.sqlite
# chrlength.sqlite
# These sqlite dbs are mainly used to generate annotation packages
# like hgu95av2
# kegg depends on geneext, go/script/getdb2.sh depends on gene

## 
##Purge DBs is not comprehensive so don't count on it to remove EVERYTHING from db...  
##In general, (for a CLEAN new build) you should just purge ALL except for the metadatasrc.sqlite file from ./db and then just start with "parse"
### ###sh purge_DBs.sh

#cd $SRC_BASE/unigene/script; sh getdb.sh 
#echo "Finished unigene"

#cd $SRC_BASE/gene/script; sh getdb.sh  
#echo "Finished gene"
## Marc's notes that 
## "...for some reason, genesrc.sqlite will get duplicate inserts after
## precisely THIS point...
##echo "DELETE FROM metadata WHERE rowid > 3;" > temp.sql
##sqlite3 -bail db/genesrc.sqlite < temp.sql
##rm temp.sql
## Fix by hand:
#> dbGetQuery(con, "delete from metadata where rowid > 3")
#> dbGetQuery(con, "select * from metadata")
#          name                                value
#1 EGSOURCEDATE                           2016-Mar14
#3  EGSOURCEURL ftp://ftp.ncbi.nlm.nih.gov/gene/DATA

#cd $SRC_BASE/blast2go/script; sh getdb.sh
#echo "Finished blast2go"
#cd $SRC_BASE/go/script; sh getdb1.sh
#echo "Finished GO db1"
#cd $SRC_BASE/go/script; sh getdb2.sh
#echo "Finished GO db2"
#cd $SRC_BASE/kegg/script; sh getdb.sh
#echo "Finished kegg"
#cd $SRC_BASE/ucsc/script; sh getdb.sh
#echo "Finished ucsc"

## DEAD:
#cd $SRC_BASE/ipi/script; sh getdb.sh ## this is now dead
##cd $SRC_BASE/chrlength; sh getdb.sh

## -----------------------------------------------------------------------
## Alls scripts below create and modify the chipsrc_* dbs: order matters
## -----------------------------------------------------------------------

## Skeleton chipsrc_* packages using genesrc.sqlite:
#cd $SRC_BASE/organism_annotation/script; sh getdb.sh
#echo "Finished organism_annotation"

#cd $SRC_BASE/yeast/script; sh getdb.sh 
#echo "Finished yeast"

#cd $SRC_BASE/plasmoDB/script; sh getdb.sh  
#echo "Finished plasmoDB"

## Modified to build only flybase:
#cd $SRC_BASE/inparanoid/script; sh getdb.sh  
#echo "Finished inparanoid"

#cd $SRC_BASE/ensembl/script; sh getdb.sh  
#echo "Finished ensembl"

## Inserts ipi identifiers in pfam and prosite tables of chipsrc_* sqlite dbs
#cd $SRC_BASE/uniprot/script; sh getdb.sh
#echo "Finished uniprot"

## -----------------------------------------------------------------------
## Propagate but don't build as of Bioconductor 3.5 (April 2016)
## Creates tairsrc.sqlite and writes to 
## chipsrc_arabidopsis, chipmapsrc_arabidopsis dbs
cd $SRC_BASE/tair/script; sh getdb.sh  
echo "Finished tair"
