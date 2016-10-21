#!/bin/sh
set -e
ORGANISM=$1
if [ "$ORGANISM" = "" ]; then
    echo "Please give organism name (human, mouse or rat) as argument. For example, sh getsrc.sh human"
else
    case $ORGANISM in
        human)
                DATANAME=Hs
                ;;
        mouse)
                DATANAME=Mm
                ;;
        rat)
                DATANAME=Rn
                ;;
        fly)
                DATANAME=Dm
                ;;
        fish)
                DATANAME=Dr
                ;;
        canine)
                DATANAME=Cfa
                ;;
        bovine)
                DATANAME=Bt
                ;;
        worm)
                DATANAME=Cel
                ;;
        pig)
                DATANAME=Ssc
                ;;
        chicken)
                DATANAME=Gga
                ;;
        rhesus)
                DATANAME=Mmu
                ;;
        xenopus)
                DATANAME=Xl
                ;;
        arabidopsis)
                DATANAME=At
                ;;
        anopheles)
                DATANAME=Aga
                ;;
    esac
    
    echo "parsing data for organism: $ORGANISM"
    
    TEMP_DATE="eval echo \"\$UGSOURCEDATE_$ORGANISM\""
    UGSOURCEDATE=`$TEMP_DATE`
    
    if [ "$UGSOURCEDATE" = "" ]; then
        . ./env.sh
        UGSOURCEDATE=`$TEMP_DATE`
    fi
    
    TEMP_NAME="eval echo \"\$UGSOURCENAME_$ORGANISM\""
    UGSOURCENAME=`$TEMP_NAME`
    TEMP_URL="eval echo \"\$UGSOURCEURL_$ORGANISM\""
    UGSOURCEURL=`$TEMP_URL`
    
    ## unpack source data
    cd ../$ORGANISM/$UGSOURCEDATE
    gunzip -c $DATANAME.data.gz > unigene.data
    
    ## parse source data
    rm -f unigene.txt
    echo "source(\"../../script/unigeneParser.R\"); unigeneParser(\"unigene.data\", \"unigene.txt\")" |R --slave 
    rm -f image.txt
    echo "source(\"../../script/imageParser.R\"); imageParser(\"unigene.data\", \"image.txt\")" |R --slave 
     
    ## create source sqlite db
    rm -f unigenesrc.sqlite
    sqlite3 -bail unigenesrc.sqlite < ../../script/srcdb.sql
    
    ## record data download date
    echo "INSERT INTO metadata VALUES('UGSOURCENAME', '$UGSOURCENAME');" > temp_metadata.sql
    echo "INSERT INTO metadata VALUES('UGSOURCEURL', '$UGSOURCEURL');" >> temp_metadata.sql
    echo "INSERT INTO metadata VALUES('UGSOURCEDATE', '$UGSOURCEDATE');" >> temp_metadata.sql
    sqlite3 -bail unigenesrc.sqlite < temp_metadata.sql
    rm -f temp_metadata.sql
fi

