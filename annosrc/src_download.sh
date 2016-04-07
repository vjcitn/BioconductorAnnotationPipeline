#!/bin/sh
set -e

SRC_BASE=`pwd`

## download source data and parse them into sqlite db files
## no dependencies between data sources, i.e. 
## scripts can be executed in any order

#cd $SRC_BASE/go/script; sh download.sh
#echo "finished downloading go"

#cd $SRC_BASE/unigene/script; sh download.sh  
#echo "finished downloading unigene"

#cd $SRC_BASE/gene/script; sh download.sh
#echo "finished downloading gene"

#cd $SRC_BASE/goext/script; sh download.sh
#echo "finished downloading goext"

#cd $SRC_BASE/ucsc/script; sh download.sh 
#echo "finished downloading ucsc"

#cd $SRC_BASE/yeast/script; sh download.sh
#echo "finished downloading yeast"

#cd $SRC_BASE/ensembl/script; sh download.sh
#echo "finished downloading ensembl"

## NOTE: The date in download.sh must be checked manually before each release
#cd $SRC_BASE/plasmoDB/script; sh download.sh
#echo "finished downloading plasmoDB"

#cd $SRC_BASE/pfam/script; sh download.sh
#echo "finished downloading pfam"

## This code only downloads the new flybase not inparanoid.
#cd $SRC_BASE/inparanoid/script; sh download.sh
#echo "finished downloading flybase"

#cd $SRC_BASE/tair/script; sh download.sh
#echo "finished downloading tair"

#cd $SRC_BASE
#CURR_DATE=`date|awk '{print $6 "-" $2 $3}'`
#cat */*/env.sh|grep export > env_${CURR_DATE}.sh
