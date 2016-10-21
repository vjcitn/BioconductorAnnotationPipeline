#!/bin/sh
set -e
. ./env.sh

BASE_URL=$PLASMOSOURCEURL
PARENT_URL=$PLASMOSOURCEURL/
THIS_YEAR=`date|awk '{print $6}'`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $PARENT_URL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$PLASMOSOURCEDATE" ]; then
        echo "update $FILE from $PLASMOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ PLASMOSOURCEDATE=.*$/ PLASMOSOURCEDATE=$LATEST_DATE/g" env.sh
        mkdir ../$LATEST_DATE
        cd ../$LATEST_DATE

	wget -e robots=off $BASE_URL/$FILE
	cp $FILE ../processedFiles/LatestPfalciparumGene_plasmoDB.txt
        cd ../script
else
        echo "the latest data for $FILE is still $PLASMOSOURCEDATE"
fi
