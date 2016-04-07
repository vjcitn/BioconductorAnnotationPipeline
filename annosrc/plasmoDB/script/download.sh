#!/bin/sh
set -e
. ./env.sh

BASE_URL=$PLASMOSOURCEURL
PARENT_URL=$PLASMOSOURCEURL/
THIS_YEAR=`date|awk '{print $6}'`

#TODO!
#ARGH.  RIGHT NOW the date and the file have to be set up manually, because there is not a way to automatically know that I have the "latest" file...

FILE="PlasmoDB-25_Pfalciparum3D7Gene.txt"
LATEST_DATE=20-Jul-2015

#LATEST_DATE=`curl -s --disable-epsv -L $BASE_URL/|grep $FILE | perl -ne 'chomp($_);$_=~s/(.+?)([^\>]+?)(\s\d.??:)(.+)/$2/g;print($_,"\n")'`

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $PARENT_URL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$PLASMOSOURCEDATE" ]; then
        echo "update $FILE from $PLASMOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ PLASMOSOURCEDATE=.*$/ PLASMOSOURCEDATE=$LATEST_DATE/g" env.sh
        mkdir ../$LATEST_DATE
        cd ../$LATEST_DATE

        #Lets turn robots off and ONLY grab the one file...
	wget -e robots=off $BASE_URL/$FILE
	cp $FILE ../processedFiles/LatestPfalciparumGene_plasmoDB.txt
	#Then clean out stuff from last time:
	rm -f ALIAStable.txt
	rm -f GOtable.txt
	rm -f SYMBOLtable.txt
        rm -f plasmoDBSrc.sqlite
        #then parse the files
	dos2unix ../script/extractPlasmoDBtables.R
        R --slave < ../script/extractPlasmoDBtables.R

	#return to here
         cd ../script


else
        echo "the latest data for $FILE is still $PLASMOSOURCEDATE"
fi

