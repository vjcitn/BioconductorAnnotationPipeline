#!/bin/sh
set -e
. ./env.sh
BASE_URL=$GOEXTSOURCEURL
echo $BASE_URL
LATEST_ALL=`curl -s -L $BASE_URL|grep [^a-Z]ec2go|sed -e "s/<[^>]*>//g"|awk '{print $1}'`
LATEST_DATE=`echo $LATEST_ALL|awk -F '-' '{print $3 "-" $2$1}'`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $BASEURL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$GOEXTSOURCEDATE" ]; then
	echo "update $GOEXTSOURCENAME from $GOEXT_DATE to $LATEST_DATE"
        sed -i -e "s/ GOEXTSOURCEDATE=.*$/ GOEXTSOURCEDATE=$LATEST_DATE/g" env.sh
	mkdir ../$LATEST_DATE
	cd ../$LATEST_DATE
	curl -O $BASE_URL/ec2go
	cd ../script
else
	echo "the latest $GOEXTSOURCENAME is still $GOEXTSOURCEDATE"
fi
