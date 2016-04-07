
#!/bin/sh
set -e

SRC_BASE=`pwd`


## Order doesn't matter; no dependencies
## Remove all dbs in the db/ directory except metadata.sqlite

## go
#cd $SRC_BASE/go/script; sh getsrc.sh  
#echo "finished parsing go"

## unigene
#cd $SRC_BASE/unigene/script; sh getsrc.sh human 
#cd $SRC_BASE/unigene/script; sh getsrc.sh mouse
#cd $SRC_BASE/unigene/script; sh getsrc.sh rat
#cd $SRC_BASE/unigene/script; sh getsrc.sh fly
#cd $SRC_BASE/unigene/script; sh getsrc.sh fish
#cd $SRC_BASE/unigene/script; sh getsrc.sh canine
#cd $SRC_BASE/unigene/script; sh getsrc.sh bovine
#cd $SRC_BASE/unigene/script; sh getsrc.sh worm
#cd $SRC_BASE/unigene/script; sh getsrc.sh pig
#cd $SRC_BASE/unigene/script; sh getsrc.sh chicken
#cd $SRC_BASE/unigene/script; sh getsrc.sh rhesus
#cd $SRC_BASE/unigene/script; sh getsrc.sh xenopus
#cd $SRC_BASE/unigene/script; sh getsrc.sh arabidopsis
#cd $SRC_BASE/unigene/script; sh getsrc.sh anopheles
#echo "finished parsing unigene"

## gene 
#cd $SRC_BASE/gene/script; sh getsrc.sh
#echo "finished parsing gene"

## goext 
#cd $SRC_BASE/goext/script; sh getsrc.sh
#echo "finished parsing goext"

## ucsc
#cd $SRC_BASE/ucsc/script; sh getsrc.sh human
#cd $SRC_BASE/ucsc/script; sh getsrc.sh mouse
#cd $SRC_BASE/ucsc/script; sh getsrc.sh rat
#cd $SRC_BASE/ucsc/script; sh getsrc.sh canine
#cd $SRC_BASE/ucsc/script; sh getsrc.sh bovine
#cd $SRC_BASE/ucsc/script; sh getsrc.sh chicken
#cd $SRC_BASE/ucsc/script; sh getsrc.sh fly
#cd $SRC_BASE/ucsc/script; sh getsrc.sh fish
#cd $SRC_BASE/ucsc/script; sh getsrc.sh yeast
#cd $SRC_BASE/ucsc/script; sh getsrc.sh worm
#cd $SRC_BASE/ucsc/script; sh getsrc.sh rhesus
#cd $SRC_BASE/ucsc/script; sh getsrc.sh anopheles
#cd $SRC_BASE/ucsc/script; sh getsrc.sh chimp
#echo "finished parsing ucsc"

## yeast 
#cd $SRC_BASE/yeast/script; sh getsrc.sh
#echo "finished parsing yeast"

## ensembl
## Builds ensembl.sqlite needed (by others) in build step 
#cd $SRC_BASE/ensembl/script; sh getsrc.sh 
#echo "finished parsing ensembl"

## plasmoDB 
#cd $SRC_BASE/plasmoDB/script; sh getsrc.sh
#echo "finished parsing plasmoDB"

## pfam 
#cd $SRC_BASE/pfam/script; sh getsrc.sh
#echo "finished parsing pfam"

## inparanoid:
## The inparanoid data are old but flybase and GO are current.
## The parse/build scripts update flybase and GO mappings in 
## inparanoid.sqlite.
#cd $SRC_BASE/inparanoid/script; sh getsrc.sh  
#echo "finished parsing inparanoid"

## NOTE: broken; downloads are TAIR10 (March 2015) so just
##        parse and build to incorporate current GO.
## tair 
#cd $SRC_BASE/tair/script; sh getsrc.sh ## this IS BUSTED till we fix data and reset.
#echo "finished parsing tair"
