#!/bin/sh
set -e

export UCSCBASEURL="ftp://hgdownload.cse.ucsc.edu/goldenPath/"
export UCSCREFLINKURL="http://hgdownload.cse.ucsc.edu/goldenPath/hgFixed/database/refLink.txt.gz"

export GPSOURCEDATE_human=2020-Jan28
export GPSOURCEDATE_mouse=2019-Sep3
export GPSOURCEDATE_rat=2017-Mar16
export GPSOURCEDATE_fly=2019-Jan15
export GPSOURCEDATE_fish=2017-Nov1
export GPSOURCEDATE_yeast=2012-Jan4
export GPSOURCEDATE_canine=2017-Apr6
export GPSOURCEDATE_bovine=2019-Jun6
export GPSOURCEDATE_worm=2019-Jan10
export GPSOURCEDATE_chicken=2019-Jan16
export GPSOURCEDATE_rhesus=2017-Aug10
export GPSOURCEDATE_anopheles=2018-Oct2
export GPSOURCEDATE_chimp=2019-Apr25

export GPSOURCENAME_human="UCSC Genome Bioinformatics (Homo sapiens)"
export GPSOURCENAME_mouse="UCSC Genome Bioinformatics (Mus musculus)"
export GPSOURCENAME_rat="UCSC Genome Bioinformatics (Rattus norvegicus)"
export GPSOURCENAME_fly="UCSC Genome Bioinformatics (Drosophila melanogaster)"
export GPSOURCENAME_fish="UCSC Genome Bioinformatics (Danio rerio)"
export GPSOURCENAME_yeast="UCSC Genome Bioinformatics (Saccaromyces cerevisiae)"
export GPSOURCENAME_canine="UCSC Genome Bioinformatics (Canis familiaris)"
export GPSOURCENAME_bovine="UCSC Genome Bioinformatics (Bos taurus)"
export GPSOURCENAME_worm="UCSC Genome Bioinformatics (Caenorhabditis elegans)"
export GPSOURCENAME_chicken="UCSC Genome Bioinformatics (Gallus gallus)"
export GPSOURCENAME_rhesus="UCSC Genome Bioinformatics (Macaca mulatta)"
export GPSOURCENAME_anopheles="UCSC Genome Bioinformatics (Anopheles gambiae)"
export GPSOURCENAME_chimp="UCSC Genome Bioinformatics (Pan troglodytes)"
# export GPSOURCENAME_pig="UCSC Genome Bioinformatics (Sus scrofa)"
# export GPSOURCENAME_arabidopsis="UCSC Genome Bioinformatics (Arabidopsis thaliana)"

export BUILD_human="hg38"
export BUILD_mouse="mm10"
export BUILD_rat="rn6"
export BUILD_fly="dm6"
export BUILD_fish="danRer11" 
export BUILD_yeast="sacCer3"
export BUILD_canine="canFam3"
export BUILD_bovine="bosTau9"
export BUILD_worm="ce11"
export BUILD_chicken="galGal6"
export BUILD_rhesus="rheMac8"
export BUILD_anopheles="anoGam3"
export BUILD_chimp="panTro6"
