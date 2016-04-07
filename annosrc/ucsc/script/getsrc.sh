#!/bin/sh
set -e
ORGANISM=$1
if [ "$ORGANISM" = "" ]; then
 echo "Please give organism name (human, mouse or rat) as argument. For example, sh getsrc.sh human"
else
 echo "parsing data for ucsc organism: $ORGANISM"
 TEMP_DATE="eval echo \"\$GPSOURCEDATE_$ORGANISM\""
 GPSOURCEDATE=`$TEMP_DATE`

 if [ "$GPSOURCEDATE" = "" ]; then
   . ./env.sh
   GPSOURCEDATE=`$TEMP_DATE`
 fi

 TEMP_NAME="eval echo \"\$GPSOURCENAME_$ORGANISM\""
 GPSOURCENAME=`$TEMP_NAME`
 TEMP_URL="eval echo \"\$GPSOURCEURL_$ORGANISM\""
 GPSOURCEURL=`$TEMP_URL`
 HTEMP_URL="eval echo \"\$HGPSOURCEURL_$ORGANISM\""
 HGPSOURCEURL=`$HTEMP_URL`

 cd ../${ORGANISM}/${GPSOURCEDATE}

 ## unpack source data
 gunzip -c refGene.txt.gz > refGene.txt
 gunzip -c refLink.txt.gz > refLink.txt
 gunzip -c cytoBand.txt.gz > cytoBand.txt
 gunzip -c chromInfo.txt.gz  > chromInfo.txt
 gunzip -c knownToLocusLink.txt.gz  > knownToLocusLink.txt 

 ## create source sqlite db
 rm -f gpsrc.sqlite
 sqlite3 -bail gpsrc.sqlite < ../../script/srcdb_${ORGANISM}.sql

 ## record data download date
 echo "INSERT INTO metadata VALUES('GPSOURCENAME', '$GPSOURCENAME');" > temp_metadata.sql
 echo "INSERT INTO metadata VALUES('GPSOURCEURL', '$HGPSOURCEURL');" >> temp_metadata.sql
 echo "INSERT INTO metadata VALUES('GPSOURCEDATE', '$GPSOURCEDATE');" >> temp_metadata.sql
 sqlite3 -bail gpsrc.sqlite < temp_metadata.sql
 rm -f temp_metadata.sql

 cd ..
 rm -f gpsrc.sqlite
 ln -s ${GPSOURCEDATE}/gpsrc.sqlite gpsrc.sqlite
 
fi

