#!/bin/sh
set -e
. ./env.sh

## Not updating inparanoid any longer - we are using version 6.1
THIS_YEAR=`date|awk '{print $6}'`
LATEST_INP_DATE=$IPHVMSOURCEDATE
BASE_FB_URL=$FBSOURCEURL
LATEST_FB_DATE=`curl -s --disable-epsv -L $BASE_FB_URL/|grep $FILE |awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*/$THIS_YEAR/g"`

if [ -z "$LATEST_FB_DATE" ]; then
       echo "download.sh: latest date from $BASE_FB_URL not found"
       exit 1
fi

if [ "$LATEST_FB_DATE" != "$FBSOURCEDATE" ]; then
        echo "update $FILE from $FBSOURCEDATE to $LATEST_FB_DATE"
        sed -i -e "s/ FBSOURCEDATE=.*$/ FBSOURCEDATE=$LATEST_FB_DATE/g" env.sh
	cd ../$LATEST_INP_DATE #sticking flybase also into here for now

	curl --disable-epsv -O $FBSOURCEURL/$FILE
        gunzip $FILE	
        sed -i -e "/^#.*$/ {d}" $UZFILE  ## remove comments
        cat $UZFILE | perl -ne 'chomp($_); $_ =~ s/^FBgn\d+\tFBtr\d+$//g; print($_,"\n");' > fbgn_fbtr_fbpp_purged.tsv
        sed -i -e "/^$/ {d}" fbgn_fbtr_fbpp_purged.tsv  ## remove whitespace
	cd ../script
else
        echo "the latest data for $FILE is still $FBSOURCEDATE"
fi
