#!/bin/sh
set -e
if [ "$EGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

cd ../../db

## create final sqlite db
echo "copy genesrc.sqlite from local to /db"
cp ../gene/$EGSOURCEDATE/genesrc.sqlite .

## create organism specific sqlite db: 
## only keep gene2accession and gene2unigene mapping
## data extracted from both Entrez Gene and UniGene
## this is used to generate the probe to Entrez Gene mapping for individual chips
echo "building chipmapsrc_human.sqlite"
sqlite3 -bail chipmapsrc_human.sqlite < ../gene/script/bindb_human.sql
echo "building chipmapsrc_mouse.sqlite"
sqlite3 -bail chipmapsrc_mouse.sqlite < ../gene/script/bindb_mouse.sql
echo "building chipmapsrc_rat.sqlite"
sqlite3 -bail chipmapsrc_rat.sqlite < ../gene/script/bindb_rat.sql
echo "building chipmapsrc_fly.sqlite"
sqlite3 -bail chipmapsrc_fly.sqlite < ../gene/script/bindb_fly.sql
echo "building chipmapsrc_zebrafish.sqlite"
sqlite3 -bail chipmapsrc_zebrafish.sqlite < ../gene/script/bindb_zebrafish.sql
echo "building chipmapsrc_zebrafish.sqlite"
sqlite3 -bail chipmapsrc_canine.sqlite < ../gene/script/bindb_canine.sql
echo "building chipmapsrc_bovine.sqlite"
sqlite3 -bail chipmapsrc_bovine.sqlite < ../gene/script/bindb_bovine.sql
echo "building chipmapsrc_pig.sqlite"
sqlite3 -bail chipmapsrc_pig.sqlite < ../gene/script/bindb_pig.sql
echo "building chipmapsrc_chicken.sqlite"
sqlite3 -bail chipmapsrc_chicken.sqlite < ../gene/script/bindb_chicken.sql
echo "building chipmapsrc_worm.sqlite"
sqlite3 -bail chipmapsrc_worm.sqlite < ../gene/script/bindb_worm.sql
echo "building chipmapsrc_ecoliK12.sqlite"
sqlite3 -bail chipmapsrc_ecoliK12.sqlite < ../gene/script/bindb_ecoliK12.sql
echo "building chipmapsrc_ecoliSakai.sqlite"
sqlite3 -bail chipmapsrc_ecoliSakai.sqlite < ../gene/script/bindb_ecoliSakai.sql
echo "building chipmapsrc_rhesus.sqlite"
sqlite3 -bail chipmapsrc_rhesus.sqlite < ../gene/script/bindb_rhesus.sql
echo "building chipmapsrc_xenopus.sqlite"
sqlite3 -bail chipmapsrc_xenopus.sqlite < ../gene/script/bindb_xenopus.sql
echo "building chipmapsrc_anopheles.sqlite"
sqlite3 -bail chipmapsrc_anopheles.sqlite < ../gene/script/bindb_anopheles.sql
echo "building chipmapsrc_chimp.sqlite"
sqlite3 -bail chipmapsrc_chimp.sqlite < ../gene/script/bindb_chimp.sql
echo "building chipmapsrc_yeastNCBI.sqlite"
sqlite3 -bail chipmapsrc_yeastNCBI.sqlite < ../gene/script/bindb_yeast.sql
echo "building chipmapsrc_arabidopsisNCBI.sqlite"
sqlite3 -bail chipmapsrc_arabidopsisNCBI.sqlite < ../gene/script/bindb_arabidopis.sql
