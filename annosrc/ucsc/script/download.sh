#!/bin/sh
set -e
. ./env.sh


## 2024/09/21 Bioc-3.21 build

## See download.bak for how this used to work UCSC changed
## ftp://hgdownload.cse.ucsc.edu/goldenPath/ to redirect to an
## interactive HTML page, so checking for the dir timestamp to decide
## to download files no longer works. Not that it ever did, since each
## dir has hundreds of files, and basing the timestamp of the dir to
## decide if like four files have changed doesn't make sense
## anyway. Here we change to using rsync to automatically download if
## necessary. Since we aren't basing on the date any longer, we change
## the download dirs to species/current (as an example
## ../human/current

## refLink is shared so just get it once in human

cd ../human/current
echo "Human"
rsync -avzP $UCSCBASEURL/$BUILD_human/database/knownToLocusLink.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_human/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_human/database/cytoBand.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_human/database/chromInfo.txt.gz .
rsync -avzP $UCSCREFLINKURL .


cd ../../mouse/current
echo "Mouse"
rsync -avzP $UCSCBASEURL/$BUILD_mouse/database/refGene.txt.gz .
## the cytoBandIdeo file is missing the gieStain colum, but maybe it doesn't matter?
rsync -avzP $UCSCBASEURL/$BUILD_mouse/database/cytoBandIdeo.txt.gz ./cytoBand.txt.gz
rsync -avzP $UCSCBASEURL/$BUILD_mouse/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../rat/current
echo "Rat"
rsync -avzP $UCSCBASEURL/$BUILD_rat/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_rat/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../fly/current
echo "Fly"
rsync -avzP $UCSCBASEURL/$BUILD_fly/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_fly/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../fish/current
echo "Fish"
rsync -avzP $UCSCBASEURL/$BUILD_fish/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_fish/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../canine/current
echo "Dog"
rsync -avzP $UCSCBASEURL/$BUILD_canine/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_canine/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../bovine/current
echo "Cow"
rsync -avzP $UCSCBASEURL/$BUILD_bovine/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_bovine/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../worm/current
echo "Worm"
rsync -avzP $UCSCBASEURL/$BUILD_worm/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_worm/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../chicken/current
echo "Chicken"
rsync -avzP $UCSCBASEURL/$BUILD_chicken/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_chicken/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../yeast/current
echo "Yeast"
rsync -avzP $UCSCBASEURL/$BUILD_yeast/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../rhesus/current
echo "Monkey"
rsync -avzP $UCSCBASEURL/$BUILD_rhesus/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_rhesus/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../anopheles/current
echo "Anopheles"
rsync -avzP $UCSCBASEURL/$BUILD_anopheles/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .

cd ../../chimp/current
echo "Chimp"
rsync -avzP $UCSCBASEURL/$BUILD_chimp/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_chimp/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .


cd ../../pig/current
echo "Pig"
rsync -avzP $UCSCBASEURL/$BUILD_pig/database/refGene.txt.gz .
rsync -avzP $UCSCBASEURL/$BUILD_pig/database/chromInfo.txt.gz .
rsync ../../human/current/refLink.txt.gz .
