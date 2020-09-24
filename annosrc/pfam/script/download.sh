#!/bin/sh
set -e
. ./env.sh


BASE_URL=$PFAMSOURCEURL
THIS_YEAR=`date|awk '{print $6}'`
FILE="Pfam-A.full.gz"

LATEST_PFAM_DATE=`curl -IL $BASE_URL/$FILE | grep "Last-Modified" | awk '{print $5 "-" $4 $3}'`

if [ -z "$LATEST_PFAM_DATE" ]; then
       echo "download.sh: latest date from $PFAMSOURCEURL not found"
       exit 1
fi

if [ "$LATEST_PFAM_DATE" != "$PFAMSOURCEDATE" ]; then
        echo "update $FILE from $PFAMSOURCEDATE to $LATEST_PFAM_DATE"
        sed -i -e "s/ PFAMSOURCEDATE=.*$/ PFAMSOURCEDATE=$LATEST_PFAM_DATE/g" env.sh
        mkdir ../$LATEST_PFAM_DATE
        cd ../$LATEST_PFAM_DATE
	wget $BASE_URL/$FILE
	gunzip $FILE
	cd ../script
else
        echo "the latest data for $FILE is still $PFAMSOURCEDATE"
fi
