#!/bin/sh
set -e
. ./env.sh

BASE_URL=$GOSOURCEURL
THIS_YEAR=`date|awk '{print $6}'`
LATEST_DATE=`curl -s -L $BASE_URL|grep -F $FILE|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $GOSOURCEURL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$GOSOURCEDATE" ]; then
        echo "update $GOSOURCENAME from $GOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ GOSOURCEDATE=.*$/ GOSOURCEDATE=$LATEST_DATE/g" env.sh    
        mkdir ../$LATEST_DATE
        cd ../$LATEST_DATE
        curl -O $BASE_URL/$FILE
        cd ../script  
else
        echo "the latest $GOSOURCENAME is still $LATEST_DATE"
fi
