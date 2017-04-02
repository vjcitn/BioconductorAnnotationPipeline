#!/bin/sh
set -e
. ./env.sh

BASE_URL=$YGSOURCEURL
THIS_YEAR=`date|awk '{print $6}'`
LATEST_DATE=`curl -s -L --disable-epsv $BASE_URL/curation/literature/|grep "gene_literature.tab"|awk '{print $9}'|sed -e "s/align=\"right\">//g"`

YG_URL=http://downloads.yeastgenome.org/curation/calculated_protein_info/domains/domains.tab
REJECTORF_URL=http://archive.broadinstitute.org/ftp/pub/annotation/fungi/comp_yeasts/S6.RFC_test/a.orf_decisions.txt

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: gene_literature.tab from $BASE_URL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$YGSOURCEDATE" ]; then
      echo "update $YGSOURCENAME data from $YGSOURCEDATE to $LATEST_DATE"
      sed -i -e "s/ YGSOURCEDATE=.*$/ YGSOURCEDATE=$LATEST_DATE/g" env.sh    
      mkdir -p ../$LATEST_DATE
      cd ../$LATEST_DATE
      curl --disable-epsv -O $BASE_URL/curation/literature/gene_literature.tab
      curl --disable-epsv -O $BASE_URL/curation/literature/gene_association.sgd.gz
      curl --disable-epsv -O $BASE_URL/curation/chromosomal_feature/SGD_features.tab
      curl --disable-epsv -O $YG_URL
      curl -O $REJECTORF_URL
      cd ../script  
      #sh getsrc.sh
else
      echo "the latest $YGSOURCENAME data is still $YGSOURCEDATE"
fi
