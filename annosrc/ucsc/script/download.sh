#!/bin/sh
set -e
. ./env.sh

THIS_YEAR=`date|awk '{print $6}'`

## refLink table moved:
## http://hgdownload.cse.ucsc.edu/goldenPath/hgFixed/database/
## http://genome.ucsc.edu/FAQ/FAQdownloads.html#download35

## Get all data from most current directories here
## ftp://hgdownload.cse.ucsc.edu/goldenPath/
## instead of ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes
## which is not current for many organisms.

## Note: pig and arabidopsis are not at UCSC
LATEST_HUMAN=`curl --fail -s -L $UCSCBASEURL| grep -F $BUILD_human |awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_MOUSE=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_mouse|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_RAT=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_rat|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_FLY=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_fly|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_FISH=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_fish|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_YEAST=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_yeast|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_CANINE=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_canine|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_BOVINE=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_bovine|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_WORM=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_worm|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_RHESUS=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_rhesus|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_ANOPHELES=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_anopheles|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_CHIMP=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_chimp|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_CHICKEN=`curl --fail -s -L $UCSCBASEURL|grep -F $BUILD_chicken|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`

## refLink shared by all; download once
## TODO: modify scripts to look in single place for refLink vs each organism directory
cd ../
curl --fail --disable-epsv -O $UCSCREFLINKURL
cd script


if [ "$LATEST_HUMAN" != "$GPSOURCEDATE_human" ]; then
	echo "update $GPSOURCENAME_human data from $GPSOURCEDATE_human to $LATEST_HUMAN"
        sed -i -e "s/ GPSOURCEDATE_human=.*$/ GPSOURCEDATE_human=$LATEST_HUMAN/g" env.sh
	mkdir ../human/$LATEST_HUMAN
	cd ../human/$LATEST_HUMAN

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_human/database/knownToLocusLink.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_human/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_human/database/cytoBand.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_human/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
	cd ../../script
else
	echo "the latest $GPSOURCENAME_human data is still $GPSOURCEDATE_human"
fi

if [ "$LATEST_MOUSE" != "$GPSOURCEDATE_mouse" ]; then
	echo "update $GPSOURCENAME_mouse data from $GPSOURCEDATE_mouse to $LATEST_MOUSE"
        sed -i -e "s/ GPSOURCEDATE_mouse=.*$/ GPSOURCEDATE_mouse=$LATEST_MOUSE/g" env.sh
	mkdir ../mouse/$LATEST_MOUSE
	cd ../mouse/$LATEST_MOUSE

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_mouse/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_mouse/database/cytoBand.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_mouse/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_mouse data is still $GPSOURCEDATE_mouse"
fi

if [ "$LATEST_RAT" != "$GPSOURCEDATE_rat" ]; then
	echo "update $GPSOURCENAME_rat data from $GPSOURCEDATE_rat to $LATEST_RAT"
        sed -i -e "s/ GPSOURCEDATE_rat=.*$/ GPSOURCEDATE_rat=$LATEST_RAT/g" env.sh
	mkdir ../rat/$LATEST_RAT
	cd ../rat/$LATEST_RAT

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_rat/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_rat/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_rat data is still $GPSOURCEDATE_rat"
fi

if [ "$LATEST_FLY" != "$GPSOURCEDATE_fly" ]; then
	echo "update $GPSOURCENAME_fly data from $GPSOURCEDATE_fly to $LATEST_FLY"
        sed -i -e "s/ GPSOURCEDATE_fly=.*$/ GPSOURCEDATE_fly=$LATEST_FLY/g" env.sh
	mkdir ../fly/$LATEST_FLY
	cd ../fly/$LATEST_FLY

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_fly/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_fly/database/cytoBand.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_fly/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_fly data is still $GPSOURCEDATE_fly"
fi

if [ "$LATEST_FISH" != "$GPSOURCEDATE_fish" ]; then
	echo "update $GPSOURCENAME_fish data from $GPSOURCEDATE_fish to $LATEST_FISH"
        sed -i -e "s/ GPSOURCEDATE_fish=.*$/ GPSOURCEDATE_fish=$LATEST_FISH/g" env.sh
	mkdir ../fish/$LATEST_FISH
	cd ../fish/$LATEST_FISH

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_fish/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_fish/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_fish data is still $GPSOURCEDATE_fish"
fi

if [ "$LATEST_CANINE" != "$GPSOURCEDATE_canine" ]; then
	echo "update $GPSOURCENAME_canine data from $GPSOURCEDATE_canine to $LATEST_CANINE"
        sed -i -e "s/ GPSOURCEDATE_canine=.*$/ GPSOURCEDATE_canine=$LATEST_CANINE/g" env.sh
	mkdir ../canine/$LATEST_CANINE
	cd ../canine/$LATEST_CANINE

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_canine/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_canine/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
	touch cytoBand.txt; gzip cytoBand.txt 
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_canine data is still $GPSOURCEDATE_canine"
fi


if [ "$LATEST_BOVINE" != "$GPSOURCEDATE_bovine" ]; then
	echo "update $GPSOURCENAME_bovine data from $GPSOURCEDATE_bovine to $LATEST_BOVINE"
        sed -i -e "s/ GPSOURCEDATE_bovine=.*$/ GPSOURCEDATE_bovine=$LATEST_BOVINE/g" env.sh
	mkdir ../bovine/$LATEST_BOVINE
	cd ../bovine/$LATEST_BOVINE

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_bovine/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_bovine/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
	touch cytoBand.txt; gzip cytoBand.txt 
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_bovine data is still $GPSOURCEDATE_bovine"
fi

if [ "$LATEST_WORM" != "$GPSOURCEDATE_worm" ]; then
	echo "update $GPSOURCENAME_worm data from $GPSOURCEDATE_worm to $LATEST_WORM"
        sed -i -e "s/ GPSOURCEDATE_worm=.*$/ GPSOURCEDATE_worm=$LATEST_WORM/g" env.sh
	mkdir ../worm/$LATEST_WORM
	cd ../worm/$LATEST_WORM

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_worm/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_worm/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_worm data is still $GPSOURCEDATE_worm"
fi

if [ "$LATEST_CHICKEN" != "$GPSOURCEDATE_chicken" ]; then
	echo "update $GPSOURCENAME_chicken data from $GPSOURCEDATE_chicken to $LATEST_CHICKEN"
        sed -i -e "s/ GPSOURCEDATE_chicken=.*$/ GPSOURCEDATE_chicken=$LATEST_CHICKEN/g" env.sh
	mkdir ../chicken/$LATEST_CHICKEN
	cd ../chicken/$LATEST_CHICKEN

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_chicken/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_chicken/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_chicken data is still $GPSOURCEDATE_chicken"
fi

#Only get chromosome data for yeast (all else comes from sgd, or was not historically requested)
if [ "$LATEST_YEAST" != "$GPSOURCEDATE_yeast" ]; then
	echo "update $GPSOURCENAME_yeast data from $GPSOURCEDATE_yeast to $LATEST_YEAST"
        sed -i -e "s/ GPSOURCEDATE_yeast=.*$/ GPSOURCEDATE_yeast=$LATEST_YEAST/g" env.sh
	mkdir ../yeast/$LATEST_YEAST
	cd ../yeast/$LATEST_YEAST

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_yeast/database/chromInfo.txt.gz #used
        ## missing (not used)
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch refGene.txt; gzip refGene.txt
	touch refLink.txt; gzip refLink.txt
	touch cytoBand.txt; gzip cytoBand.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_yeast data is still $GPSOURCEDATE_yeast"
fi

if [ "$LATEST_RHESUS" != "$GPSOURCEDATE_rhesus" ]; then
	echo "update $GPSOURCENAME_rhesus data from $GPSOURCEDATE_rhesus to $LATEST_RHESUS"
        sed -i -e "s/ GPSOURCEDATE_rhesus=.*$/ GPSOURCEDATE_rhesus=$LATEST_RHESUS/g" env.sh
	mkdir ../rhesus/$LATEST_RHESUS
	cd ../rhesus/$LATEST_RHESUS

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_rhesus/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_rhesus/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing 
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_rhesus data is still $GPSOURCEDATE_rhesus"
fi

if [ "$LATEST_ANOPHELES" != "$GPSOURCEDATE_anopheles" ]; then
	echo "update $GPSOURCENAME_anopheles data from $GPSOURCEDATE_anopheles to $LATEST_ANOPHELES"
        sed -i -e "s/ GPSOURCEDATE_anopheles=.*$/ GPSOURCEDATE_anopheles=$LATEST_ANOPHELES/g" env.sh
	mkdir ../anopheles/$LATEST_ANOPHELES
	cd ../anopheles/$LATEST_ANOPHELES

        curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_anopheles/database/chromInfo.txt.gz
        ## missing (not used) 
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt
	touch refGene.txt; gzip refGene.txt
	touch refLink.txt; gzip refLink.txt
	cd ../../script
else
	echo "the latest $GPSOURCENAME_anopheles data is still $GPSOURCEDATE_anopheles"
fi

if [ "$LATEST_CHIMP" != "$GPSOURCEDATE_chimp" ]; then
	echo "update $GPSOURCENAME_chimp data from $GPSOURCEDATE_chimp to $LATEST_CHIMP"
        sed -i -e "s/ GPSOURCEDATE_chimp=.*$/ GPSOURCEDATE_chimp=$LATEST_CHIMP/g" env.sh
	mkdir ../chimp/$LATEST_CHIMP
	cd ../chimp/$LATEST_CHIMP

	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_chimp/database/refGene.txt.gz
	curl --fail --disable-epsv -O $UCSCBASEURL/$BUILD_chimp/database/chromInfo.txt.gz
        cp ../../refLink.txt.gz .
        ## missing 
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt 
	touch cytoBand.txt; gzip cytoBand.txt 
	cd ../../script
else
	echo "the latest $GPSOURCENAME_chimp data is still $GPSOURCEDATE_chimp"
fi
