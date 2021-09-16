#!/bin/sh
set -e
. ./env.sh
THIS_YEAR=`date|awk '{print $6}'`

echo "We no longer build unigene tables!"

# LATEST_DATE_HUMAN=`curl -s --disable-epsv -L $UGSOURCEURL_human/|grep "Hs.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_HUMAN" ]; then
#        echo "download.sh: Hs.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_MOUSE=`curl -s --disable-epsv -L $UGSOURCEURL_mouse/|grep "Mm.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_MOUSE" ]; then
#        echo "download.sh: Mm.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_RAT=`curl -s --disable-epsv -L $UGSOURCEURL_rat/|grep "Rn.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_RAT" ]; then
#        echo "download.sh: Rn.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_FLY=`curl -s --disable-epsv -L $UGSOURCEURL_fly/|grep "Dm.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_FLY" ]; then
#        echo "download.sh: Dm.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_FISH=`curl -s --disable-epsv -L $UGSOURCEURL_fish/|grep "Dr.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_FISH" ]; then
#        echo "download.sh: Dr.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_CANINE=`curl -s --disable-epsv -L $UGSOURCEURL_canine/|grep "Cfa.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_CANINE" ]; then
#        echo "download.sh: Cfa.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_BOVINE=`curl -s --disable-epsv -L $UGSOURCEURL_bovine/|grep "Bt.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_BOVINE" ]; then
#        echo "download.sh: Bt.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_WORM=`curl -s --disable-epsv -L $UGSOURCEURL_worm/|grep "Cel.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_WORM" ]; then
#        echo "download.sh: Cel.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_PIG=`curl -s --disable-epsv -L $UGSOURCEURL_pig/|grep "Ssc.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_PIG" ]; then
#        echo "download.sh: Ssc.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_CHICKEN=`curl -s --disable-epsv -L $UGSOURCEURL_chicken/|grep "Gga.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_CHICKEN" ]; then
#        echo "download.sh: Gga.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_RHESUS=`curl -s --disable-epsv -L $UGSOURCEURL_rhesus/|grep "Mmu.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_RHESUS" ]; then
#        echo "download.sh: Mmu.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_XENOPUS=`curl -s --disable-epsv -L $UGSOURCEURL_xenopus/|grep "Xl.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_XENOPUS" ]; then
#        echo "download.sh: Xl.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_ARABIDOPSIS=`curl -s --disable-epsv -L $UGSOURCEURL_arabidopsis/|grep "At.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_ARABIDOPSIS" ]; then
#        echo "download.sh: At.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi

# LATEST_DATE_ANOPHELES=`curl -s --disable-epsv -L $UGSOURCEURL_anopheles/|grep "Aga.data.gz"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
# if [ -z "$LATEST_DATE_ANOPHELES" ]; then
#        echo "download.sh: Aga.data.gz from $UGSOURCEURL not found"
#        exit 1
# fi



# if [ "$LATEST_DATE_HUMAN" != "$UGSOURCEDATE_human" ]; then
# 	echo "update $UGSOURCENAME_human data from $UGSOURCEDATE_human to $LATEST_DATE_HUMAN"
#         sed -i -e "s/ UGSOURCEDATE_human=.*$/ UGSOURCEDATE_human=$LATEST_DATE_HUMAN/g" env.sh
# 	mkdir ../human/$LATEST_DATE_HUMAN
# 	cd ../human/$LATEST_DATE_HUMAN
# 	curl --disable-epsv -O $UGSOURCEURL_human/Hs.data.gz
# 	cd ../../script
# 	#sh getsrc.sh human
# else
# 	echo "the latest $UGSOURCENAME_human data is still $UGSOURCEDATE_human"
# fi

# if [ "$LATEST_DATE_MOUSE" != "$UGSOURCEDATE_mouse" ]; then
# 	echo "update $UGSOURCENAME_mouse data from $UGSOURCEDATE_mouse to $LATEST_DATE_MOUSE"
#         sed -i -e "s/ UGSOURCEDATE_mouse=.*$/ UGSOURCEDATE_mouse=$LATEST_DATE_MOUSE/g" env.sh
# 	mkdir ../mouse/$LATEST_DATE_MOUSE
# 	cd ../mouse/$LATEST_DATE_MOUSE
# 	curl --disable-epsv -O $UGSOURCEURL_mouse/Mm.data.gz
# 	cd ../../script
# 	#sh getsrc.sh mouse
# else
# 	echo "the latest $UGSOURCENAME_mouse data is still $UGSOURCEDATE_mouse"
# fi

# if [ "$LATEST_DATE_RAT" != "$UGSOURCEDATE_rat" ]; then
# 	echo "update $UGSOURCENAME_rat data from $UGSOURCEDATE_rat to $LATEST_DATE_RAT"
#         sed -i -e "s/ UGSOURCEDATE_rat=.*$/ UGSOURCEDATE_rat=$LATEST_DATE_RAT/g" env.sh
# 	mkdir ../rat/$LATEST_DATE_RAT
# 	cd ../rat/$LATEST_DATE_RAT
# 	curl --disable-epsv -O $UGSOURCEURL_rat/Rn.data.gz
# 	cd ../../script
# 	#sh getsrc.sh rat
# else
# 	echo "the latest $UGSOURCENAME_rat data is still $UGSOURCEDATE_rat"
# fi

# if [ "$LATEST_DATE_FLY" != "$UGSOURCEDATE_fly" ]; then
# 	echo "update $UGSOURCENAME_fly data from $UGSOURCEDATE_fly to $LATEST_DATE_FLY"
#         sed -i -e "s/ UGSOURCEDATE_fly=.*$/ UGSOURCEDATE_fly=$LATEST_DATE_FLY/g" env.sh
# 	mkdir ../fly/$LATEST_DATE_FLY
# 	cd ../fly/$LATEST_DATE_FLY
# 	curl --disable-epsv -O $UGSOURCEURL_fly/Dm.data.gz
# 	cd ../../script
# 	#sh getsrc.sh fly
# else
# 	echo "the latest $UGSOURCENAME_fly data is still $UGSOURCEDATE_fly"
# fi

# if [ "$LATEST_DATE_FISH" != "$UGSOURCEDATE_fish" ]; then
# 	echo "update $UGSOURCENAME_fish data from $UGSOURCEDATE_fish to $LATEST_DATE_FISH"
#         sed -i -e "s/ UGSOURCEDATE_fish=.*$/ UGSOURCEDATE_fish=$LATEST_DATE_FISH/g" env.sh
# 	mkdir ../fish/$LATEST_DATE_FISH
# 	cd ../fish/$LATEST_DATE_FISH
# 	curl --disable-epsv -O $UGSOURCEURL_fish/Dr.data.gz
# 	cd ../../script
# 	#sh getsrc.sh fish
# else
# 	echo "the latest $UGSOURCENAME_fish data is still $UGSOURCEDATE_fish"
# fi

# if [ "$LATEST_DATE_CANINE" != "$UGSOURCEDATE_canine" ]; then
# 	echo "update $UGSOURCENAME_canine data from $UGSOURCEDATE_canine to $LATEST_DATE_CANINE"
#         sed -i -e "s/ UGSOURCEDATE_canine=.*$/ UGSOURCEDATE_canine=$LATEST_DATE_CANINE/g" env.sh
# 	mkdir ../canine/$LATEST_DATE_CANINE
# 	cd ../canine/$LATEST_DATE_CANINE
# 	curl --disable-epsv -O $UGSOURCEURL_canine/Cfa.data.gz
# 	cd ../../script
# 	#sh getsrc.sh canine
# else
# 	echo "the latest $UGSOURCENAME_canine data is still $UGSOURCEDATE_canine"
# fi

# if [ "$LATEST_DATE_BOVINE" != "$UGSOURCEDATE_bovine" ]; then
# 	echo "update $UGSOURCENAME_bovine data from $UGSOURCEDATE_bovine to $LATEST_DATE_BOVINE"
#         sed -i -e "s/ UGSOURCEDATE_bovine=.*$/ UGSOURCEDATE_bovine=$LATEST_DATE_BOVINE/g" env.sh
# 	mkdir ../bovine/$LATEST_DATE_BOVINE
# 	cd ../bovine/$LATEST_DATE_BOVINE
# 	curl --disable-epsv -O $UGSOURCEURL_bovine/Bt.data.gz
# 	cd ../../script
# 	#sh getsrc.sh bovine
# else
# 	echo "the latest $UGSOURCENAME_bovine data is still $UGSOURCEDATE_bovine"
# fi

# if [ "$LATEST_DATE_WORM" != "$UGSOURCEDATE_worm" ]; then
# 	echo "update $UGSOURCENAME_worm data from $UGSOURCEDATE_worm to $LATEST_DATE_WORM"
#         sed -i -e "s/ UGSOURCEDATE_worm=.*$/ UGSOURCEDATE_worm=$LATEST_DATE_WORM/g" env.sh
# 	mkdir ../worm/$LATEST_DATE_WORM
# 	cd ../worm/$LATEST_DATE_WORM
# 	curl --disable-epsv -O $UGSOURCEURL_worm/Cel.data.gz
# 	cd ../../script
# 	#sh getsrc.sh worm
# else
# 	echo "the latest $UGSOURCENAME_worm data is still $UGSOURCEDATE_worm"
# fi

# if [ "$LATEST_DATE_PIG" != "$UGSOURCEDATE_pig" ]; then
# 	echo "update $UGSOURCENAME_pig data from $UGSOURCEDATE_pig to $LATEST_DATE_PIG"
#         sed -i -e "s/ UGSOURCEDATE_pig=.*$/ UGSOURCEDATE_pig=$LATEST_DATE_PIG/g" env.sh
# 	mkdir ../pig/$LATEST_DATE_PIG
# 	cd ../pig/$LATEST_DATE_PIG
# 	curl --disable-epsv -O $UGSOURCEURL_pig/Ssc.data.gz
# 	cd ../../script
# 	#sh getsrc.sh pig
# else
# 	echo "the latest $UGSOURCENAME_pig data is still $UGSOURCEDATE_pig"
# fi

# if [ "$LATEST_DATE_CHICKEN" != "$UGSOURCEDATE_chicken" ]; then
# 	echo "update $UGSOURCENAME_chicken data from $UGSOURCEDATE_chicken to $LATEST_DATE_CHICKEN"
#         sed -i -e "s/ UGSOURCEDATE_chicken=.*$/ UGSOURCEDATE_chicken=$LATEST_DATE_CHICKEN/g" env.sh
# 	mkdir ../chicken/$LATEST_DATE_CHICKEN
# 	cd ../chicken/$LATEST_DATE_CHICKEN
# 	curl --disable-epsv -O $UGSOURCEURL_chicken/Gga.data.gz
# 	cd ../../script
# 	#sh getsrc.sh chicken
# else
# 	echo "the latest $UGSOURCENAME_chicken data is still $UGSOURCEDATE_chicken"
# fi

# if [ "$LATEST_DATE_RHESUS" != "$UGSOURCEDATE_rhesus" ]; then
# 	echo "update $UGSOURCENAME_rhesus data from $UGSOURCEDATE_rhesus to $LATEST_DATE_RHESUS"
#         sed -i -e "s/ UGSOURCEDATE_rhesus=.*$/ UGSOURCEDATE_rhesus=$LATEST_DATE_RHESUS/g" env.sh
# 	mkdir ../rhesus/$LATEST_DATE_RHESUS
# 	cd ../rhesus/$LATEST_DATE_RHESUS
# 	curl --disable-epsv -O $UGSOURCEURL_rhesus/Mmu.data.gz
# 	cd ../../script
# 	#sh getsrc.sh rhesus
# else
# 	echo "the latest $UGSOURCENAME_rhesus data is still $UGSOURCEDATE_rhesus"
# fi

# if [ "$LATEST_DATE_XENOPUS" != "$UGSOURCEDATE_xenopus" ]; then
# 	echo "update $UGSOURCENAME_xenopus data from $UGSOURCEDATE_xenopus to $LATEST_DATE_XENOPUS"
#         sed -i -e "s/ UGSOURCEDATE_xenopus=.*$/ UGSOURCEDATE_xenopus=$LATEST_DATE_XENOPUS/g" env.sh
# 	mkdir ../xenopus/$LATEST_DATE_XENOPUS
# 	cd ../xenopus/$LATEST_DATE_XENOPUS
# 	curl --disable-epsv -O $UGSOURCEURL_xenopus/Xl.data.gz
# 	cd ../../script
# 	#sh getsrc.sh xenopus
# else
# 	echo "the latest $UGSOURCENAME_xenopus data is still $UGSOURCEDATE_xenopus"
# fi

# if [ "$LATEST_DATE_ARABIDOPSIS" != "$UGSOURCEDATE_arabidopsis" ]; then
# 	echo "update $UGSOURCENAME_arabidopsis data from $UGSOURCEDATE_arabidopsis to $LATEST_DATE_ARABIDOPSIS"
#         sed -i -e "s/ UGSOURCEDATE_arabidopsis=.*$/ UGSOURCEDATE_arabidopsis=$LATEST_DATE_ARABIDOPSIS/g" env.sh
# 	mkdir ../arabidopsis/$LATEST_DATE_ARABIDOPSIS
# 	cd ../arabidopsis/$LATEST_DATE_ARABIDOPSIS
# 	curl --disable-epsv -O $UGSOURCEURL_arabidopsis/At.data.gz
# 	cd ../../script
# 	#sh getsrc.sh arabidopsis
# else
# 	echo "the latest $UGSOURCENAME_arabidopsis data is still $UGSOURCEDATE_arabidopsis"
# fi

# if [ "$LATEST_DATE_ANOPHELES" != "$UGSOURCEDATE_anopheles" ]; then
# 	echo "update $UGSOURCENAME_anopheles data from $UGSOURCEDATE_anopheles to $LATEST_DATE_ANOPHELES"
#         sed -i -e "s/ UGSOURCEDATE_anopheles=.*$/ UGSOURCEDATE_anopheles=$LATEST_DATE_ANOPHELES/g" env.sh
# 	mkdir ../anopheles/$LATEST_DATE_ANOPHELES
# 	cd ../anopheles/$LATEST_DATE_ANOPHELES
# 	curl --disable-epsv -O $UGSOURCEURL_anopheles/Aga.data.gz
# 	cd ../../script
# 	#sh getsrc.sh anopheles
# else
# 	echo "the latest $UGSOURCENAME_anopheles data is still $UGSOURCEDATE_anopheles"
# fi
