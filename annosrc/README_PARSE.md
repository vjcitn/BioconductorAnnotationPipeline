# Parse process, after downloads completed

## Starting off

The legacy README tells us `src_parse.sh` manages the
parsing of downloaded resources.
```

#!/bin/sh
set -e

SRC_BASE=`pwd`

## Order doesn't matter; no dependencies
## Remove all dbs in the db/ directory except metadata.sqlite.
```

We only saw
```
exouser@biocanno2025q1:~/BioconductorAnnotationPipeline/annosrc$ ls -tl db
total 236
-rw-rw-r-- 1 exouser exouser 200704 Jan 22 13:57 map_counts.sqlite
-rw-rw-r-- 1 exouser exouser  39936 Jan 22 13:57 metadatasrc.sqlite
```

Is `metadata.sqlite` a typo?

Let's just try step by step.

## GO

```
## go
echo "parsing go"
cd $SRC_BASE/go/script; sh getsrc.sh  
echo "finished parsing go"
```

We had to install sqlite3 and some R packages (see top level README) but then the script completed.
```
-rw-r--r-- 1 exouser exouser 63537152 Feb  2 20:28 gosrcsrc.sqlite
drwxrwxr-x 2 exouser exouser     4096 Feb  2 20:28 goterm
-rw-rw-r-- 1 exouser exouser 31417323 Jan 22 15:16 go-basic.obo
```
We'll skip unigene and delete the text from this readme segment.   Let's delete the folder some time.


## gene

What is "gene"?  NCBI?

```
echo "parsing gene"
cd $SRC_BASE/gene/script; sh getsrc.sh
echo "finished parsing gene"
```
That ran fine.

## goext 
```
echo "parsing goext"
cd $SRC_BASE/goext/script; sh getsrc.sh
echo "finished parsing goext"
```
seems to have worked

## ucsc

```
echo "parsing ucsc"
cd $SRC_BASE/ucsc/script; sh getsrc.sh human
cd $SRC_BASE/ucsc/script; sh getsrc.sh mouse
cd $SRC_BASE/ucsc/script; sh getsrc.sh rat
cd $SRC_BASE/ucsc/script; sh getsrc.sh canine
cd $SRC_BASE/ucsc/script; sh getsrc.sh bovine
cd $SRC_BASE/ucsc/script; sh getsrc.sh chicken
cd $SRC_BASE/ucsc/script; sh getsrc.sh fly
cd $SRC_BASE/ucsc/script; sh getsrc.sh fish
cd $SRC_BASE/ucsc/script; sh getsrc.sh yeast
cd $SRC_BASE/ucsc/script; sh getsrc.sh worm
cd $SRC_BASE/ucsc/script; sh getsrc.sh rhesus
cd $SRC_BASE/ucsc/script; sh getsrc.sh anopheles
cd $SRC_BASE/ucsc/script; sh getsrc.sh chimp
cd $SRC_BASE/ucsc/script; sh getsrc.sh pig
echo "finished parsing ucsc"

## yeast 
echo "parsing yeast"
cd $SRC_BASE/yeast/script; sh getsrc.sh
echo "finished parsing yeast"

## ensembl
## Builds ensembl.sqlite needed (by others) in build step 
echo "parsing ensembl"
cd $SRC_BASE/ensembl/script; sh getsrc.sh 
echo "finished parsing ensembl"

## plasmoDB 
echo "parsing plasmoDB"
cd $SRC_BASE/plasmoDB/script; sh getsrc.sh
echo "finished parsing plasmoDB"

## pfam 
echo "parsing pfam"
cd $SRC_BASE/pfam/script; sh getsrc.sh
echo "finished parsing pfam"

## inparanoid:
## The inparanoid data are old but flybase and GO are current.
## The parse/build scripts update flybase and GO mappings in 
## inparanoid.sqlite and chip_fly.sqlite.
echo "parsing inparanoid"
cd $SRC_BASE/inparanoid/script; sh getsrc.sh  
echo "finished parsing inparanoid"

## tair 
## NOTE: parse and build to incorporate current GO.
echo "parsing tair"
cd $SRC_BASE/tair/script; sh getsrc.sh 
echo "finished parsing tair"
```
