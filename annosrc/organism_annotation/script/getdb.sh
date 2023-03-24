#!/bin/sh
set -e

cd ../../db
#rm -f chipsrc_human.sqlite
#echo "building chipsrc_human.sqlite"
#sqlite3 -bail chipsrc_human.sqlite < ../organism_annotation/script/bindb_human.sql
#sqlite3 -bail chipsrc_human.sqlite < ../organism_annotation/script/bindb_meta.sql
#sqlite3 -bail chipsrc_human.sqlite < ../organism_annotation/script/bindb_OMIM.sql
#sqlite3 -bail chipsrc_human.sqlite < ../organism_annotation/script/bindb_meta_ucsc.sql

#rm -f chipsrc_mouse.sqlite
#echo "building chipsrc_mouse.sqlite"
#sqlite3 -bail chipsrc_mouse.sqlite < ../organism_annotation/script/bindb_mouse.sql
#sqlite3 -bail chipsrc_mouse.sqlite < ../organism_annotation/script/bindb_meta.sql
#sqlite3 -bail chipsrc_mouse.sqlite < ../organism_annotation/script/bindb_extra_meta_mouse.sql
# sqlite3 -bail chipsrc_mouse.sqlite < ../organism_annotation/script/bindb_meta_ucsc.sql

#rm -f chipsrc_rat.sqlite
#echo "building chipsrc_rat.sqlite"
#sqlite3 -bail chipsrc_rat.sqlite < ../organism_annotation/script/bindb_rat.sql
#sqlite3 -bail chipsrc_rat.sqlite < ../organism_annotation/script/bindb_meta.sql
# sqlite3 -bail chipsrc_rat.sqlite < ../organism_annotation/script/bindb_meta_ucsc.sql

#rm -f chipsrc_fly.sqlite
#echo "building chipsrc_fly.sqlite"
#sqlite3 -bail chipsrc_fly.sqlite < ../organism_annotation/script/bindb_fly.sql
#sqlite3 -bail chipsrc_fly.sqlite < ../organism_annotation/script/bindb_meta_fly.sql

#rm -f chipsrc_zebrafish.sqlite
#echo "building chipsrc_zebrafish.sqlite"
#sqlite3 -bail chipsrc_zebrafish.sqlite < ../organism_annotation/script/bindb_zebrafish.sql
#sqlite3 -bail chipsrc_zebrafish.sqlite < ../organism_annotation/script/bindb_meta.sql
#sqlite3 -bail chipsrc_zebrafish.sqlite < ../organism_annotation/script/bindb_meta_fish.sql

#rm -f chipsrc_ecoliK12.sqlite
#echo "building chipsrc_ecoliK12.sqlite"
#sqlite3 -bail chipsrc_ecoliK12.sqlite < ../organism_annotation/script/bindb_ecoliK12.sql
#sqlite3 -bail chipsrc_ecoliK12.sqlite < ../organism_annotation/script/bindb_meta_ecoli.sql

#rm -f chipsrc_ecoliSakai.sqlite
#echo "building chipsrc_ecoliSakai.sqlite"
#sqlite3 -bail chipsrc_ecoliSakai.sqlite < ../organism_annotation/script/bindb_ecoliSakai.sql
#sqlite3 -bail chipsrc_ecoliSakai.sqlite < ../organism_annotation/script/bindb_meta_ecoli.sql


#rm -f chipsrc_canine.sqlite
#echo "building chipsrc_canine.sqlite"
#sqlite3 -bail chipsrc_canine.sqlite < ../organism_annotation/script/bindb_canine.sql
#sqlite3 -bail chipsrc_canine.sqlite < ../organism_annotation/script/bindb_meta_canine.sql

#rm -f chipsrc_bovine.sqlite
#echo "building chipsrc_bovine.sqlite"
#sqlite3 -bail chipsrc_bovine.sqlite < ../organism_annotation/script/bindb_bovine.sql
#sqlite3 -bail chipsrc_bovine.sqlite < ../organism_annotation/script/bindb_meta_bovine.sql

#rm -f chipsrc_worm.sqlite
#echo "building chipsrc_worm.sqlite"
#sqlite3 -bail chipsrc_worm.sqlite < ../organism_annotation/script/bindb_worm.sql
#sqlite3 -bail chipsrc_worm.sqlite < ../organism_annotation/script/bindb_meta_worm.sql

#rm -f chipsrc_pig.sqlite
#echo "building chipsrc_pig.sqlite"
#sqlite3 -bail chipsrc_pig.sqlite < ../organism_annotation/script/bindb_pig.sql
#sqlite3 -bail chipsrc_pig.sqlite < ../organism_annotation/script/bindb_meta_pig.sql

#rm -f chipsrc_chicken.sqlite
#echo "building chipsrc_chicken.sqlite"
#sqlite3 -bail chipsrc_chicken.sqlite < ../organism_annotation/script/bindb_chicken.sql
#sqlite3 -bail chipsrc_chicken.sqlite < ../organism_annotation/script/bindb_meta_chicken.sql

#rm -f chipsrc_rhesus.sqlite
#echo "building chipsrc_rhesus.sqlite"
#sqlite3 -bail chipsrc_rhesus.sqlite < ../organism_annotation/script/bindb_rhesus.sql
#sqlite3 -bail chipsrc_rhesus.sqlite < ../organism_annotation/script/bindb_meta_rhesus.sql

#rm -f chipsrc_xenopus.sqlite
#echo "building chipsrc_xenopus.sqlite"
#sqlite3 -bail chipsrc_xenopus.sqlite < ../organism_annotation/script/bindb_xenopus.sql
#sqlite3 -bail chipsrc_xenopus.sqlite < ../organism_annotation/script/bindb_meta_xenopus.sql

#rm -f chipsrc_anopheles.sqlite
#echo "building chipsrc_anopheles.sqlite"
#sqlite3 -bail chipsrc_anopheles.sqlite < ../organism_annotation/script/bindb_anopheles.sql
#sqlite3 -bail chipsrc_anopheles.sqlite < ../organism_annotation/script/bindb_meta_anopheles.sql

#rm -f chipsrc_chimp.sqlite
#echo "building chipsrc_chimp.sqlite"
#sqlite3 -bail chipsrc_chimp.sqlite < ../organism_annotation/script/bindb_chimp.sql
#sqlite3 -bail chipsrc_chimp.sqlite < ../organism_annotation/script/bindb_meta_chimp.sql

rm -f chipsrc_yeastNCBI.sqlite
echo "building chipsrc_yeastNCBI.sqlite"
sqlite3 -bail chipsrc_yeastNCBI.sqlite < ../organism_annotation/script/bindb_yeast.sql
sqlite3 -bail chipsrc_yeastNCBI.sqlite < ../organism_annotation/script/bindb_meta_yeast.sql

## FIXME: AnnotationForge::wrapBaseDBPackages() does not use 'UCSC' in the name ...
##        Should we change it here?
rm -f chipsrc_arabidopsisNCBI.sqlite
echo "building chipsrc_arabidopsisNCBI.sqlite"
sqlite3 -bail chipsrc_arabidopsisNCBI.sqlite < ../organism_annotation/script/bindb_arabidopsis.sql
sqlite3 -bail chipsrc_arabidopsisNCBI.sqlite < ../organism_annotation/script/bindb_meta_arabidopsis.sql

