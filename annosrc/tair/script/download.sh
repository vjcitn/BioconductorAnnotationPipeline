#!/bin/sh
set -e
. ./env.sh

BASE_URL=$TAIRSOURCEURL
THIS_YEAR=`date|awk '{print $6}'`
LATEST_DATE=`curl -s -L --disable-epsv $BASE_URL/|grep "User_Requests"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`

## FIXME: necessary for logging or ... ?
echo "TAIRATHURL=$TAIRATHURL"

if [ -z "$LATEST_DATE" ]; then
        echo "download.sh: User_Requests directory from $BASEURL not found"
        exit 1
fi

if [ "$LATEST_DATE" != "$TAIRSOURCEDATE" ]; then
      mkdir -p ../$LATEST_DATE
      cd ../$LATEST_DATE
      curl --disable-epsv -O $TAIRGENEURL
      curl --disable-epsv -O $TAIRCHRURL
      curl --disable-epsv -O $TAIRATHURL
      curl --disable-epsv -O $TAIRAGURL
      curl --disable-epsv -O $TAIRGOURL
      curl --disable-epsv -O $TAIRSYMBOLURL   
      curl --disable-epsv -O $TAIRPATHURL
      curl --disable-epsv -O $TAIRPMIDURL
      curl --disable-epsv -O $TAIRGFF
      cd ../script  
      TAIRATHURL=`echo $TAIRATHURL|sed -e 's/\//\\\\\//g'`
      TAIRAGURL=`echo $TAIRAGURL|sed -e 's/\//\\\\\//g'`
      TAIRGOURL=`echo $TAIRGOURL|sed -e 's/\//\\\\\//g'`
      TAIRSYMBOLURL=`echo $TAIRSYMBOLURL|sed -e 's/\//\\\\\//g'`
      TAIRPATHURL=`echo $TAIRPATHURL|sed -e 's/\//\\\\\//g'`
      TAIRPMIDURL=`echo $TAIRPMIDURL|sed -e 's/\//\\\\\//g'`
      echo "update $TAIRSOURCENAME data from $TAIRSOURCEDATE to $LATEST_DATE"
      sed -i -e "s/ TAIRSOURCEDATE=.*$/ TAIRSOURCEDATE=$LATEST_DATE/g" env.sh    
      sed -i -e "s/ TAIRATHURL=.*$/ TAIRATHURL=\"$TAIRATHURL\"/g" env.sh    
      sed -i -e "s/ TAIRAGURL=.*$/ TAIRAGURL=\"$TAIRAGURL\"/g" env.sh    
      sed -i -e "s/ TAIRGOURL=.*$/ TAIRGOURL=\"$TAIRGOURL\"/g" env.sh    
      sed -i -e "s/ TAIRSYMBOLURL=.*$/ TAIRSYMBOLURL=\"$TAIRSYMBOLURL\"/g" env.sh    
      sed -i -e "s/ TAIRPATHURL=.*$/ TAIRPATHURL=\"$TAIRPATHURL\"/g" env.sh    
      sed -i -e "s/ TAIRPMIDURL=.*$/ TAIRPMIDURL=\"$TAIRPMIDURL\"/g" env.sh    
      #sh getsrc.sh
      ##Some post-processing (would be nicer if I made more variables here
    
      # In the following files, first line is column name
      cd ../$LATEST_DATE
      sed -e "1d" $TAIRAGURLNAME > affy_AG_array_elements1.txt
      sed -e "1d" $TAIRATHURLNAME > affy_ATH1_array_elements1.txt
      sed -e "1d" $TAIRPMIDURLNAME > LocusPublished1.txt
      sed -e "1d" $TAIRGENEURLNAME > TAIR_sequenced_genes1
      
      iconv -f WINDOWS-1252 -t UTF-8 TAIR_sequenced_genes1 > TAIR_sequenced_genes2 
      ## get rid of quotes
      sed -i -e 's/"//g' TAIR_sequenced_genes2
      # gene_aliases has various number of columns (some lines 2, others 4)
      awk '{print $1 "\t" $2}' $TAIRSYMBOLURLNAME > gene_aliases1
      
      cp $TAIRPATHURLNAME  aracyc_dump1
      tail -n +2 aracyc_dump1 > aracyc_dump2
      mv aracyc_dump2 aracyc_dump1
    else
      echo "the latest $TAIRSOURCENAME data is still $TAIRSOURCEDATE"
fi
