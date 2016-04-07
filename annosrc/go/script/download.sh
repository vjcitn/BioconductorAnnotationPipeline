#!/bin/sh
set -e
. ./env.sh
BASE_URL=$GOSOURCEURL
LATEST_TAR=`curl -s -L --disable-epsv $BASE_URL/|grep -o -e "go\_[0-9]*-termdb-tables.tar.gz"|grep -m 1 -e "."`
LATEST_DATE=`echo $LATEST_TAR|sed -e "s/go\_//g" -e "s/-termdb-tables.tar.gz//g"`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $GOSOURCEURL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$GOSOURCEDATE" ]; then
        echo "update $GOSOURCENAME from $GOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ GOSOURCEDATE=.*$/ GOSOURCEDATE=$LATEST_DATE/g" env.sh    
        mkdir ../$LATEST_DATE
        cd ../$LATEST_DATE
        curl -O $BASE_URL/$LATEST_TAR
        cd ../script  
        #sh getsrc.sh
else
        echo "the latest $GOSOURCENAME is still $LATEST_DATE"
fi
