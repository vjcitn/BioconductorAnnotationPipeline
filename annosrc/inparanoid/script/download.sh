#!/bin/sh
set -e
. ./env.sh

#this download script will use wget because curl does not recursivly get stuff...

# BASE_URL=$IPSOURCEURL

THIS_YEAR=`date|awk '{print $6}'`
## apparently not updating inparanoid any longer - we are using version 6.1
LATEST_INP_DATE=$IPHVMSOURCEDATE

# #HVM
# # FILE="sqltable.ensHOMSA.fa-modMUSMU.fa"
# FILE="sqltable.H.sapiens.fa-M.musculus.fa"

# #NOTE THAT THE DIRECTORY is just named after the human vs mouse comparison
# #We are using this one files date as a metric for whether to get all the 
# #other ones since there are many many dozens of files and I don't think 
# #its going to be practical to monitor them all

# LATEST_INP_DATE=`curl -s --disable-epsv -L $BASE_URL/|grep $FILE | perl -ne 'chomp($_);$_=~s/(.+?)([^\>]+?)(\s\d.??:)(.+)/$2/g;print($_,"\n")'`

# if [ "$LATEST_INP_DATE" != "$IPHVMSOURCEDATE" ]; then
#         echo "update $FILE from $IPHVMSOURCEDATE to $LATEST_INP_DATE"
#         sed -i -e "s/ IPHVMSOURCEDATE=.*$/ IPHVMSOURCEDATE=$LATEST_INP_DATE/g" env.sh
#         mkdir ../$LATEST_INP_DATE
#         cd ../$LATEST_INP_DATE
	
# 	mkdir IPDATA
# 	cd IPDATA
# 	# At this point just get all the files in that directory with wget.
# 	# this command says to recurse to one level (-r -l1)
# 	# not to recreate the dir structure (-nd) 
# 	# and accept only .fa files (-A .fa).
# 	wget -r -nd -l1 -A .fa $BASE_URL
# 	#then clean up the files
# 	R --slave < ../../script/cleanINPFiles.R
# 	cd ../../script
	

# else
#         echo "the latest data for $FILE is still $IPHVMSOURCEDATE"
# fi



BASE_FB_URL=$FBSOURCEURL
## This file will not be found each time so I will get to rename it (thanks flybase!)
FILE="fbgn_fbtr_fbpp_fb_2016_01.tsv.gz"
UZFILE="fbgn_fbtr_fbpp_fb_2016_01.tsv"
LATEST_FB_DATE=`curl -s --disable-epsv -L $BASE_FB_URL/|grep $FILE |awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*/$THIS_YEAR/g"`

if [ -z "$LATEST_FB_DATE" ]; then
       echo "download.sh: latest date from $BASE_FB_URL not found"
       exit 1
fi

if [ "$LATEST_FB_DATE" != "$FBSOURCEDATE" ]; then
        echo "update $FILE from $FBSOURCEDATE to $LATEST_FB_DATE"
        sed -i -e "s/ FBSOURCEDATE=.*$/ FBSOURCEDATE=$LATEST_FB_DATE/g" env.sh
        #mkdir ../$LATEST_FB_DATE #This and the next line are commented for now
        #cd ../$LATEST_FB_DATE
	cd ../$LATEST_INP_DATE #sticking flybase also into here for now

	#get the gigantic map file from flybase
	#curl --disable-epsv -O ftp://ftp.flybase.net/releases/current/reporting-xml/FBpp.xml.gz
 	#curl --disable-epsv -O $FBSOURCEURL/FBpp.xml.gz
	#mv FBpp.xml.gz curFBpp.xml.gz
	curl --disable-epsv -O $FBSOURCEURL/$FILE
        gunzip $FILE	
        sed -i -e "/^#.*$/ {d}" $UZFILE  ## remove comments
        cat $UZFILE | perl -ne 'chomp($_); $_ =~ s/^FBgn\d+\tFBtr\d+$//g; print($_,"\n");' > fbgn_fbtr_fbpp_purged.tsv
        sed -i -e "/^$/ {d}" fbgn_fbtr_fbpp_purged.tsv  ## remove whitespace
	cd ../script


else
        echo "the latest data for $FILE is still $FBSOURCEDATE"
fi

