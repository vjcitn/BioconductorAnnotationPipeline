#!/bin/sh
set -e
. ./env.sh
BASE_URL=$GOEXTSOURCEURL
echo $BASE_URL
LATEST_DATE=`curl -IL $BASE_URL/ec2go | grep "Last-Modified" | awk '{print $5 "-" $4 $3}'`


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
