#!/bin/sh
set -e
if [ "$KEGGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

## create source sqlite db
cd ../$KEGGSOURCEDATE
rm -f *_gene_map2.txt
R --slave < ../script/parseGeneMap.R


##From when we had .gene files. (not anymore)
# cat hsa/hsa*.gene|grep "\[EC:[^]]*]" > hsa_ec.txt
# cat mmu/mmu*.gene|grep "\[EC:[^]]*]" > mmu_ec.txt
# cat rno/rno*.gene|grep "\[EC:[^]]*]" > rno_ec.txt
# cat dme/dme*.gene|grep "\[EC:[^]]*]" > dme_ec.txt
# cat sce/sce*.gene|grep "\[EC:[^]]*]" > sce_ec.txt
# cat ath/ath*.gene|grep "\[EC:[^]]*]" > ath_ec.txt
# cat pfa/pfa*.gene|grep "\[EC:[^]]*]" > pfa_ec.txt
# cat dre/dre*.gene|grep "\[EC:[^]]*]" > dre_ec.txt
# cat eco/eco*.gene|grep "\[EC:[^]]*]" > eco_ec.txt
# cat ecs/ecs*.gene|grep "\[EC:[^]]*]" > ecs_ec.txt
# cat cfa/cfa*.gene|grep "\[EC:[^]]*]" > cfa_ec.txt
# cat bta/bta*.gene|grep "\[EC:[^]]*]" > bta_ec.txt
# cat cel/cel*.gene|grep "\[EC:[^]]*]" > cel_ec.txt
# cat ssc/ssc*.gene|grep "\[EC:[^]]*]" > ssc_ec.txt
# cat gga/gga*.gene|grep "\[EC:[^]]*]" > gga_ec.txt
# cat mcc/mcc*.gene|grep "\[EC:[^]]*]" > mcc_ec.txt
# cat xla/xla*.gene|grep "\[EC:[^]]*]" > xla_ec.txt
# cat aga/aga*.gene|grep "\[EC:[^]]*]" > aga_ec.txt
# cat ptr/ptr*.gene|grep "\[EC:[^]]*]" > ptr_ec.txt


cat hsa.list|grep "ec:" > hsa_ec.txt
cat mmu.list|grep "ec:" > mmu_ec.txt
cat rno.list|grep "ec:" > rno_ec.txt
cat dme.list|grep "ec:" > dme_ec.txt
cat sce.list|grep "ec:" > sce_ec.txt
cat ath.list|grep "ec:" > ath_ec.txt
cat pfa.list|grep "ec:" > pfa_ec.txt
cat dre.list|grep "ec:" > dre_ec.txt
cat eco.list|grep "ec:" > eco_ec.txt
cat ecs.list|grep "ec:" > ecs_ec.txt
cat cfa.list|grep "ec:" > cfa_ec.txt
cat bta.list|grep "ec:" > bta_ec.txt
cat cel.list|grep "ec:" > cel_ec.txt
cat ssc.list|grep "ec:" > ssc_ec.txt
cat gga.list|grep "ec:" > gga_ec.txt
cat mcc.list|grep "ec:" > mcc_ec.txt
cat xla.list|grep "ec:" > xla_ec.txt
cat aga.list|grep "ec:" > aga_ec.txt
cat ptr.list|grep "ec:" > ptr_ec.txt


rm -f *_ec2.txt
R --slave < ../script/parseEC.R

## sqlite3 doesn't like multi-character separators, which we have
## in the *.list files, so I changed the data by hand
## in new files called e.g., *ncbi-geneid2.list, and changed genome.sql
## to use simple separators (in a new file genome2.sql)

rm -f genome_src.sqlite
##sqlite3 -bail genome_src.sqlite < ../script/genome.sql
sqlite3 --bail genome_src.sqlite < ../script/genome2.sql

## record data download date
echo "INSERT INTO metadata VALUES('KEGGSOURCENAME', '$KEGGSOURCENAME');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('KEGGSOURCEURL', '$KEGGSOURCEURL');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('KEGGSOURCEDATE', '$KEGGSOURCEDATE');" >> temp_metadata.sql
sqlite3 -bail genome_src.sqlite < temp_metadata.sql
rm -f temp_metadata.sql


