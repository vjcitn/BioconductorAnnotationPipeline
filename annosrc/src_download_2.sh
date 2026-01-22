#!/bin/sh
set -e

SRC_BASE=`pwd`

## download source data and parse them into sqlite db files
## no dependencies between data sources, i.e. 
## scripts can be executed in any order

# DONE 22 Jan 2026 echo "downloading go"
# DONE 22 Jan 2026 cd $SRC_BASE/go/script; sh download.sh
# DONE 22 Jan 2026 echo "finished downloading go"

echo "downloading gene"

# DONE 22 Jan 2026 cd $SRC_BASE/gene/script; sh download.sh  
# DONE 22 Jan 2026 echo "finished downloading gene"

# DONE 22 Jan 2026 ### NOTE: There has been a timeout when downloading data, do by hand
# DONE 22 Jan 2026 #echo "downloading goext"
# DONE 22 Jan 2026 #cd $SRC_BASE/goext/script; sh download.sh
# DONE 22 Jan 2026 #echo "finished downloading goext"

### NOTE: Update genome build versions in env.sh to most current.
mkdir ucsc/anopheles/current
mkdir ucsc/bovine/current
mkdir ucsc/canine/current
mkdir ucsc/chicken/current
mkdir ucsc/chimp/current
mkdir ucsc/fish/current
mkdir ucsc/fly/current
mkdir ucsc/human/current
mkdir ucsc/mouse/current
mkdir ucsc/pig/current
mkdir ucsc/rat/current
mkdir ucsc/rhesus/current
mkdir ucsc/worm/current
mkdir ucsc/yeast/current

echo "downloading ucsc"
cd $SRC_BASE/ucsc/script; sh download.sh # FAILED ON FIRST ATTEMPT FOR LACK OF human/current -- so create the folders!
echo "finished downloading ucsc"

echo "downloading yeast"
cd $SRC_BASE/yeast/script; sh download.sh
echo "finished downloading yeast"

echo "downloading ensembl"
cd $SRC_BASE/ensembl/script; sh download.sh
echo "finished downloading ensembl"

echo "downloading plasmoDB"
cd $SRC_BASE/plasmoDB/script; sh download.sh
echo "finished downloading plasmoDB"

echo "downloading pfam"
cd $SRC_BASE/pfam/script; sh download.sh
echo "finished downloading pfam"

## NOTE: Only downloads the new flybase, not inparanoid.
echo "downloading flybase"
cd $SRC_BASE/inparanoid/script; sh download.sh
echo "finished downloading flybase"

## NOTE: this is updated by hand - compare URLS in ./tair/script/env.sh
## with what is on the various web pages to make sure it points to the newest
## data, and then run the download.sh script
echo "downloading tair"
cd $SRC_BASE/tair/script; sh download.sh
echo "finished downloading tair"

#cd $SRC_BASE
#CURR_DATE=`date|awk '{print $6 "-" $2 $3}'`
##cat */*/env.sh|grep export > env_${CURR_DATE}.sh
