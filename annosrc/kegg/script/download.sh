#!/bin/sh
set -e
BASE_URL=ftp://ftp.genome.jp/pub/kegg
THIS_YEAR=`date|awk '{print $6}'`
LATEST_PATHWAY=`curl --fail -s -L --disable-epsv $BASE_URL/pathway/|grep "map_title.tab"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
LATEST_GENOME=`curl --fail -s -L --disable-epsv $BASE_URL/|grep "genes"|awk '{print $8 "-" $6 $7}'|sed -e "s/^[0-9]*:[0-9]*-/$THIS_YEAR-/g"`
. ./env.sh

if [ "$LATEST_PATHWAY" != "$PATHNAMESOURCEDATE" ]; then
  echo "update pathway name list (map_title.tab) from $PATHNAMESOURCEDATE to $LATEST_PATHWAY"
  sed -i -e "s/ PATHNAMESOURCEDATE=.*$/ PATHNAMESOURCEDATE=$LATEST_PATHWAY/g" env.sh    
  mkdir -p ../$LATEST_PATHWAY
  cd ../$LATEST_PATHWAY
  curl --fail --disable-epsv -O $BASE_URL/pathway/map_title.tab
  cd ../script  
  #sh getsrc1.sh
else
  echo "the latest pathway name list (map_title.tab) is still $LATEST_PATHWAY"
fi

if [ "$LATEST_GENOME" != "$KEGGSOURCEDATE" ]; then
  echo "update genome and pathway information from $KEGGSOURCEDATE to $LATEST_GENOME"
  sed -i -e "s/ KEGGSOURCEDATE=.*$/ KEGGSOURCEDATE=$LATEST_GENOME/g" env.sh    
  mkdir -p ../$LATEST_GENOME
  cd ../$LATEST_GENOME
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/hsa/hsa_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/hsa/hsa_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/mmu/mmu_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/mmu/mmu_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/rno/rno_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/rno/rno_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/sce/sce_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/sce/sce_mips-sce.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/ath/ath_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/ath/ath_tigr-ath.list
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/ath/ath_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/dme/dme_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/dme/dme_flybase-dme.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/pfa/pfa_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/pfa/pfa_plasmodb-pfa.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/dre/dre_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/dre/dre_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/eco/eco_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/eco/eco_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/ecs/ecs_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/ecs/ecs_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/cfa/cfa_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/cfa/cfa_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/bta/bta_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/bta/bta_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/cel/cel_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/cel/cel_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/ssc/ssc_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/ssc/ssc_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/gga/gga_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/gga/gga_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/mcc/mcc_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/mcc/mcc_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/xla/xla_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/xla/xla_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/aga/aga_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/aga/aga_ncbi-geneid.list
  curl --fail --disable-epsv -O $BASE_URL/pathway/organisms/ptr/ptr_gene_map.tab
  curl --fail --disable-epsv -O $BASE_URL/genes/organisms/ptr/ptr_ncbi-geneid.list


## In summer of 2009 KEGG decided to stop supporting .gene files.
## Instead they want me to parse the .html files.  I can either do
## this, but their .list file looks more promising...

#   mkdir hsa; cd hsa; wget --glob=on $BASE_URL/pathway_gif/organisms/hsa/hsa*.gene; cd ..
#   mkdir mmu; cd mmu; wget --glob=on $BASE_URL/pathway_gif/organisms/mmu/mmu*.gene; cd ..
#   mkdir rno; cd rno; wget --glob=on $BASE_URL/pathway_gif/organisms/rno/rno*.gene; cd ..
#   mkdir sce; cd sce; wget --glob=on $BASE_URL/pathway_gif/organisms/sce/sce*.gene; cd ..
#   mkdir ath; cd ath; wget --glob=on $BASE_URL/pathway_gif/organisms/ath/ath*.gene; cd ..
#   mkdir dme; cd dme; wget --glob=on $BASE_URL/pathway_gif/organisms/dme/dme*.gene; cd ..
#   mkdir pfa; cd pfa; wget --glob=on $BASE_URL/pathway_gif/organisms/pfa/pfa*.gene; cd ..
#   mkdir dre; cd dre; wget --glob=on $BASE_URL/pathway_gif/organisms/dre/dre*.gene; cd ..
#   mkdir eco; cd eco; wget --glob=on $BASE_URL/pathway_gif/organisms/eco/eco*.gene; cd ..
#   mkdir ecs; cd ecs; wget --glob=on $BASE_URL/pathway_gif/organisms/ecs/ecs*.gene; cd .. 
#   mkdir cfa; cd cfa; wget --glob=on $BASE_URL/pathway_gif/organisms/cfa/cfa*.gene; cd .. 
#   mkdir bta; cd bta; wget --glob=on $BASE_URL/pathway_gif/organisms/bta/bta*.gene; cd ..
#   mkdir cel; cd cel; wget --glob=on $BASE_URL/pathway_gif/organisms/cel/cel*.gene; cd ..
#   mkdir ssc; cd ssc; wget --glob=on $BASE_URL/pathway_gif/organisms/ssc/ssc*.gene; cd ..
#   mkdir gga; cd gga; wget --glob=on $BASE_URL/pathway_gif/organisms/gga/gga*.gene; cd ..
#   mkdir mcc; cd mcc; wget --glob=on $BASE_URL/pathway_gif/organisms/mcc/mcc*.gene; cd ..
#   mkdir xla; cd xla; wget --glob=on $BASE_URL/pathway_gif/organisms/xla/xla*.gene; cd ..
#   mkdir aga; cd aga; wget --glob=on $BASE_URL/pathway_gif/organisms/aga/aga*.gene; cd ..
#   mkdir ptr; cd ptr; wget --glob=on $BASE_URL/pathway_gif/organisms/ptr/ptr*.gene; cd ..


## Now we get the .list files
wget --glob=on $BASE_URL/pathway/organisms/hsa/hsa.list; 
wget --glob=on $BASE_URL/pathway/organisms/mmu/mmu.list; 
wget --glob=on $BASE_URL/pathway/organisms/rno/rno.list; 
wget --glob=on $BASE_URL/pathway/organisms/sce/sce.list; 
wget --glob=on $BASE_URL/pathway/organisms/ath/ath.list; 
wget --glob=on $BASE_URL/pathway/organisms/dme/dme.list; 
wget --glob=on $BASE_URL/pathway/organisms/pfa/pfa.list; 
wget --glob=on $BASE_URL/pathway/organisms/dre/dre.list; 
wget --glob=on $BASE_URL/pathway/organisms/eco/eco.list; 
wget --glob=on $BASE_URL/pathway/organisms/ecs/ecs.list;  
wget --glob=on $BASE_URL/pathway/organisms/cfa/cfa.list;  
wget --glob=on $BASE_URL/pathway/organisms/bta/bta.list; 
wget --glob=on $BASE_URL/pathway/organisms/cel/cel.list; 
wget --glob=on $BASE_URL/pathway/organisms/ssc/ssc.list; 
wget --glob=on $BASE_URL/pathway/organisms/gga/gga.list; 
wget --glob=on $BASE_URL/pathway/organisms/mcc/mcc.list; 
wget --glob=on $BASE_URL/pathway/organisms/xla/xla.list; 
wget --glob=on $BASE_URL/pathway/organisms/aga/aga.list; 
wget --glob=on $BASE_URL/pathway/organisms/ptr/ptr.list;


  cd ../script  
  #sh getsrc2.sh
else
  echo "the latest genome and pathway information is still $LATEST_GENOME"
fi

