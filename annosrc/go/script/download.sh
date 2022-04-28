#!/bin/sh
set -e
. ./env.sh

LATEST=`curl --fail --silent --range 0-100 $GOSOURCEURL | head -n 2 | tail -n 1 | awk '{print $2}'`
LATEST_DATE=`basename $LATEST`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $GOSOURCEURL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$GOSOURCEDATE" ]; then
        echo "update $GOSOURCENAME from $GOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ GOSOURCEDATE=.*$/ GOSOURCEDATE=$LATEST_DATE/g" env.sh    
        mkdir ../$LATEST_DATE
        cd ../$LATEST_DATE
        curl --fail -O $GOSOURCEURL
        cd ../script  
else
        echo "the latest $GOSOURCENAME is still $LATEST_DATE"
fi
