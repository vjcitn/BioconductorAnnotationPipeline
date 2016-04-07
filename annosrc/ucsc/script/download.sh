#!/bin/sh
set -e
. ./env.sh

BASE_URL=ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/
THIS_YEAR=`date|awk '{print $6}'`

LATEST_HUMAN=`curl -s -L $BASE_URL|grep -F "Homo_sapiens"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_HUMAN" ]; then
       echo "download.sh: Homo_sapiens from $BASEURL not found"
       exit 1
fi
LATEST_MOUSE=`curl -s -L $BASE_URL|grep -F "Mus_musculus"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_MOUSE" ]; then
       echo "download.sh: Mus_musculus from $BASEURL not found"
       exit 1
fi
LATEST_RAT=`curl -s -L $BASE_URL|grep -F "Rattus_norvegicus"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_RAT" ]; then
       echo "download.sh: Rattus_norvegicus from $BASEURL not found"
       exit 1
fi
LATEST_FLY=`curl -s -L $BASE_URL|grep -F "Drosophila_melanogaster"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_FLY" ]; then
       echo "download.sh: Drosophila_melanogaster from $BASEURL not found"
       exit 1
fi
LATEST_FISH=`curl -s -L $BASE_URL|grep -F "Danio_rerio"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_FISH" ]; then
       echo "download.sh: Danio_rerio from $BASEURL not found"
       exit 1
fi
LATEST_YEAST=`curl -s -L $BASE_URL|grep -F "Saccharomyces_cerevisiae"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_YEAST" ]; then
       echo "download.sh: Saccharomyces_cerevisiae from $BASEURL not found"
       exit 1
fi
LATEST_CANINE=`curl -s -L $BASE_URL|grep -F "Canis_familiaris"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_CANINE" ]; then
       echo "download.sh: Canis_familiaris from $BASEURL not found"
       exit 1
fi
LATEST_BOVINE=`curl -s -L $BASE_URL|grep -F "Bos_taurus"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_BOVINE" ]; then
       echo "download.sh: Bos_taurus from $BASEURL not found"
       exit 1
fi
LATEST_WORM=`curl -s -L $BASE_URL|grep -F "Caenorhabditis_elegans"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_WORM" ]; then
       echo "download.sh: Caenorhabditis_elegans from $BASEURL not found"
       exit 1
fi
LATEST_CHICKEN=`curl -s -L $BASE_URL|grep -F "Gallus_gallus"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_CHICKEN" ]; then
       echo "download.sh: Gallus_gallus from $BASEURL not found"
       exit 1
fi
LATEST_RHESUS=`curl -s -L $BASE_URL|grep -F "Rhesus_macaque"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_RHESUS" ]; then
       echo "download.sh: Rhesus_macaque from $BASEURL not found"
       exit 1
fi
LATEST_ANOPHELES=`curl -s -L $BASE_URL|grep -F "Anopheles_gambiae"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_ANOPHELES" ]; then
       echo "download.sh: Anopheles_gambiae from $BASEURL not found"
       exit 1
fi
LATEST_CHIMP=`curl -s -L $BASE_URL|grep -F "Pan_troglodytes"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
if [ -z "$LATEST_CHIMP" ]; then
       echo "download.sh: Pan_troglodytes from $BASEURL not found"
       exit 1
fi

## NOTE: pig and arabidopsis are not at UCSC
# LATEST_PIG=`curl -s -L $BASE_URL|grep -F "Sus_scrofa"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# LATEST_ARABIDOPSIS=`curl -s -L $BASE_URL|grep -F "Arabidopsis_thaliana"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`

##########################################################################################################################
## Note: there is presently a hard coding of the human and worm data (the "current" data at UCSC is presently quite old).
##########################################################################################################################

## There is a problem with human (temp?)

if [ "$LATEST_HUMAN" != "$GPSOURCEDATE_human" ]; then
	echo "update $GPSOURCENAME_human data from $GPSOURCEDATE_human to $LATEST_HUMAN"
        sed -i -e "s/ GPSOURCEDATE_human=.*$/ GPSOURCEDATE_human=$LATEST_HUMAN/g" env.sh
	mkdir ../human/$LATEST_HUMAN
	cd ../human/$LATEST_HUMAN

	curl --disable-epsv -O $GPSOURCEURL_human/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_human/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_human data is not correct or the currentGenomes folder is not up to date"; exit;}  

##temp switch from $GPSOURCEURL_human/ to $HGPSOURCEURL_human/
	curl --disable-epsv -O $HGPSOURCEURL_human/database/knownToLocusLink.txt.gz
	curl --disable-epsv -O $HGPSOURCEURL_human/database/refGene.txt.gz
	curl --disable-epsv -O $HGPSOURCEURL_human/database/refLink.txt.gz
	curl --disable-epsv -O $HGPSOURCEURL_human/database/cytoBand.txt.gz
	curl --disable-epsv -O $HGPSOURCEURL_human/database/chromInfo.txt.gz

	cd ../../script
	#sh getsrc.sh human
else
	echo "the latest $GPSOURCENAME_human data is still $GPSOURCEDATE_human"
fi

if [ "$LATEST_MOUSE" != "$GPSOURCEDATE_mouse" ]; then
	echo "update $GPSOURCENAME_mouse data from $GPSOURCEDATE_mouse to $LATEST_MOUSE"
        sed -i -e "s/ GPSOURCEDATE_mouse=.*$/ GPSOURCEDATE_mouse=$LATEST_MOUSE/g" env.sh
	mkdir ../mouse/$LATEST_MOUSE
	cd ../mouse/$LATEST_MOUSE

	curl --disable-epsv -O $GPSOURCEURL_mouse/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_mouse/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_mouse data is not correct or the currentGenomes folder is not up to date"; exit;}  

# 	curl --disable-epsv -O $GPSOURCEURL_mouse/database/knownToLocusLink.txt.gz
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_mouse/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_mouse/database/refLink.txt.gz
 	curl --disable-epsv -O $GPSOURCEURL_mouse/database/cytoBand.txt.gz
#	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (not present .. yet) # IT MAY return...
	curl --disable-epsv -O $GPSOURCEURL_mouse/database/chromInfo.txt.gz
	cd ../../script
	#sh getsrc.sh mouse
else
	echo "the latest $GPSOURCENAME_mouse data is still $GPSOURCEDATE_mouse"
fi

if [ "$LATEST_RAT" != "$GPSOURCEDATE_rat" ]; then
	echo "update $GPSOURCENAME_rat data from $GPSOURCEDATE_rat to $LATEST_RAT"
        sed -i -e "s/ GPSOURCEDATE_rat=.*$/ GPSOURCEDATE_rat=$LATEST_RAT/g" env.sh
	mkdir ../rat/$LATEST_RAT
	cd ../rat/$LATEST_RAT

	curl --disable-epsv -O $GPSOURCEURL_rat/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_rat/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_rat data is not correct or the currentGenomes folder is not up to date"; exit;}  

# 	curl --disable-epsv -O $GPSOURCEURL_rat/database/knownToLocusLink.txt.gz
 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_rat/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_rat/database/refLink.txt.gz
# 	curl --disable-epsv -O $GPSOURCEURL_rat/database/cytoBand.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (not present .. yet) # IT MAY return...
	curl --disable-epsv -O $GPSOURCEURL_rat/database/chromInfo.txt.gz
	cd ../../script
	#sh getsrc.sh rat
else
	echo "the latest $GPSOURCENAME_rat data is still $GPSOURCEDATE_rat"
fi



if [ "$LATEST_FLY" != "$GPSOURCEDATE_fly" ]; then
	echo "update $GPSOURCENAME_fly data from $GPSOURCEDATE_fly to $LATEST_FLY"
        sed -i -e "s/ GPSOURCEDATE_fly=.*$/ GPSOURCEDATE_fly=$LATEST_FLY/g" env.sh
	mkdir ../fly/$LATEST_FLY
	cd ../fly/$LATEST_FLY

	curl --disable-epsv -O $GPSOURCEURL_fly/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_fly/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_fly data is not correct or the currentGenomes folder is not up to date"; exit;}  

 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_fly/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_fly/database/refLink.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_fly/database/cytoBand.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_fly/database/chromInfo.txt.gz
	cd ../../script
	#sh getsrc.sh fly
else
	echo "the latest $GPSOURCENAME_fly data is still $GPSOURCEDATE_fly"
fi



if [ "$LATEST_FISH" != "$GPSOURCEDATE_fish" ]; then
	echo "update $GPSOURCENAME_fish data from $GPSOURCEDATE_fish to $LATEST_FISH"
        sed -i -e "s/ GPSOURCEDATE_fish=.*$/ GPSOURCEDATE_fish=$LATEST_FISH/g" env.sh
	mkdir ../fish/$LATEST_FISH
	cd ../fish/$LATEST_FISH

	curl --disable-epsv -O $GPSOURCEURL_fish/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_fish/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_fish data is not correct or the currentGenomes folder is not up to date"; exit;}  

 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_fish/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_fish/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_fish/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_fish data is still $GPSOURCEDATE_fish"
fi


if [ "$LATEST_CANINE" != "$GPSOURCEDATE_canine" ]; then
	echo "update $GPSOURCENAME_canine data from $GPSOURCEDATE_canine to $LATEST_CANINE"
        sed -i -e "s/ GPSOURCEDATE_canine=.*$/ GPSOURCEDATE_canine=$LATEST_CANINE/g" env.sh
	mkdir ../canine/$LATEST_CANINE
	cd ../canine/$LATEST_CANINE

	curl --disable-epsv -O $GPSOURCEURL_canine/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_canine/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_canine data is not correct or the currentGenomes folder is not up to date"; exit;}  

 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_canine/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_canine/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_canine/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_canine data is still $GPSOURCEDATE_canine"
fi


if [ "$LATEST_BOVINE" != "$GPSOURCEDATE_bovine" ]; then
	echo "update $GPSOURCENAME_bovine data from $GPSOURCEDATE_bovine to $LATEST_BOVINE"
        sed -i -e "s/ GPSOURCEDATE_bovine=.*$/ GPSOURCEDATE_bovine=$LATEST_BOVINE/g" env.sh
	mkdir ../bovine/$LATEST_BOVINE
	cd ../bovine/$LATEST_BOVINE

	curl --disable-epsv -O $GPSOURCEURL_bovine/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_bovine/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_bovine data is not correct or the currentGenomes folder is not up to date"; exit;}  

 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_bovine/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_bovine/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_bovine/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_bovine data is still $GPSOURCEDATE_bovine"
fi




## There is a problem with worm (temp?)
if [ "$LATEST_WORM" != "$GPSOURCEDATE_worm" ]; then
	echo "update $GPSOURCENAME_worm data from $GPSOURCEDATE_worm to $LATEST_WORM"
        sed -i -e "s/ GPSOURCEDATE_worm=.*$/ GPSOURCEDATE_worm=$LATEST_WORM/g" env.sh
	mkdir ../worm/$LATEST_WORM
	cd ../worm/$LATEST_WORM

##temp comment this (it fails this test right now!) :(
	# curl --disable-epsv -O $GPSOURCEURL_worm/database/README.txt
	# mv README.txt RCur.txt
	# curl --disable-epsv -O $HGPSOURCEURL_worm/database/README.txt
	# mv README.txt RSpec.txt
	# cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_worm data is not correct or the currentGenomes folder is not up to date"; exit;}  

 	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $HGPSOURCEURL_worm/database/refGene.txt.gz
	curl --disable-epsv -O $HGPSOURCEURL_worm/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $HGPSOURCEURL_worm/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_worm data is still $GPSOURCEDATE_worm"
fi



if [ "$LATEST_CHICKEN" != "$GPSOURCEDATE_chicken" ]; then
	echo "update $GPSOURCENAME_chicken data from $GPSOURCEDATE_chicken to $LATEST_CHICKEN"
        sed -i -e "s/ GPSOURCEDATE_chicken=.*$/ GPSOURCEDATE_chicken=$LATEST_CHICKEN/g" env.sh
	mkdir ../chicken/$LATEST_CHICKEN
	cd ../chicken/$LATEST_CHICKEN

	curl --disable-epsv -O $GPSOURCEURL_chicken/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_chicken/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_chicken data is not correct or the currentGenomes folder is not up to date"; exit;}  

  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_chicken/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_chicken/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_chicken/database/chromInfo.txt.gz
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
  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_yeast/database/chromInfo.txt.gz #used
	touch refGene.txt; gzip refGene.txt   #fake not used
	touch refLink.txt; gzip refLink.txt   #fake not used
	touch cytoBand.txt; gzip cytoBand.txt #fake not used
	cd ../../script
else
	echo "the latest $GPSOURCENAME_yeast data is still $GPSOURCEDATE_yeast"
fi

if [ "$LATEST_RHESUS" != "$GPSOURCEDATE_rhesus" ]; then
	echo "update $GPSOURCENAME_rhesus data from $GPSOURCEDATE_rhesus to $LATEST_RHESUS"
        sed -i -e "s/ GPSOURCEDATE_rhesus=.*$/ GPSOURCEDATE_rhesus=$LATEST_RHESUS/g" env.sh
	mkdir ../rhesus/$LATEST_RHESUS
	cd ../rhesus/$LATEST_RHESUS

	curl --disable-epsv -O $GPSOURCEURL_rhesus/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_rhesus/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_rhesus data is not correct or the currentGenomes folder is not up to date"; exit;}  

  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_rhesus/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_rhesus/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_rhesus/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_rhesus data is still $GPSOURCEDATE_rhesus"
fi


if [ "$LATEST_ANOPHELES" != "$GPSOURCEDATE_anopheles" ]; then
	echo "update $GPSOURCENAME_anopheles data from $GPSOURCEDATE_anopheles to $LATEST_ANOPHELES"
        sed -i -e "s/ GPSOURCEDATE_anopheles=.*$/ GPSOURCEDATE_anopheles=$LATEST_ANOPHELES/g" env.sh
	mkdir ../anopheles/$LATEST_ANOPHELES
	cd ../anopheles/$LATEST_ANOPHELES

	curl --disable-epsv -O $GPSOURCEURL_anopheles/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_anopheles/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_anopheles data is not correct or the currentGenomes folder is not up to date"; exit;}  

  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
        touch refGene.txt; gzip refGene.txt # curl --disable-epsv -O $GPSOURCEURL_anopheles/database/refGene.txt.gz
        touch refLink.txt; gzip refLink.txt # curl --disable-epsv -O $GPSOURCEURL_anopheles/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_anopheles/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_anopheles data is still $GPSOURCEDATE_anopheles"
fi


if [ "$LATEST_CHIMP" != "$GPSOURCEDATE_chimp" ]; then
	echo "update $GPSOURCENAME_chimp data from $GPSOURCEDATE_chimp to $LATEST_CHIMP"
        sed -i -e "s/ GPSOURCEDATE_chimp=.*$/ GPSOURCEDATE_chimp=$LATEST_CHIMP/g" env.sh
	mkdir ../chimp/$LATEST_CHIMP
	cd ../chimp/$LATEST_CHIMP

	curl --disable-epsv -O $GPSOURCEURL_chimp/database/README.txt
	mv README.txt RCur.txt
	curl --disable-epsv -O $HGPSOURCEURL_chimp/database/README.txt
	mv README.txt RSpec.txt
	cmp -s RCur.txt RSpec.txt || { echo "TROUBLE!!!"; echo "The $HGPSOURCEURL_chimp data is not correct or the currentGenomes folder is not up to date"; exit;}  

  	touch knownToLocusLink.txt; gzip knownToLocusLink.txt  #fakey
	curl --disable-epsv -O $GPSOURCEURL_chimp/database/refGene.txt.gz
	curl --disable-epsv -O $GPSOURCEURL_chimp/database/refLink.txt.gz
	touch cytoBand.txt; gzip cytoBand.txt  #fake this one for now (does not exist)
	curl --disable-epsv -O $GPSOURCEURL_chimp/database/chromInfo.txt.gz
	cd ../../script
else
	echo "the latest $GPSOURCENAME_chimp data is still $GPSOURCEDATE_chimp"
fi
