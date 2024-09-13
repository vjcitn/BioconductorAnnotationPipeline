#!/bin/bash
set -e
if [ "$EGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

echo "unpacking gene source data ..."
cd ../$EGSOURCEDATE


## unpack source data
## New code here, as of 2024/03/19
## simply un-gzipping these big files and
## then reading excess data into the genesrc.sqlite db
## is wasteful of compute cycles, so we just extract the
## species we care about

## Also, column 13 (the assembly column) for some species appears
## to get expanded from space to tab delimited, which is a problem
## that I would like to avoid, since it results in a > 17 column file

## also note that previously we used tax_id 180454 for anopheles, which is for
## Anophelese gambiae PEST, which is a particular strain, and is no longer in
## NCBI files, so we switch to 7165, which is A. gambiae species

for f in gene2*gz; do
    out=${f/.gz/}
    zcat $f | awk '!/^#/' |
	awk 'BEGIN{
    	val[10090]	
    	val[10116]
    	val[7165]
    	val[3702]
    	val[386585]
    	val[511145]
    	val[559292]
    	val[6239]
    	val[7227]
    	val[7955]
    	val[8355]
    	val[9031]
    	val[9544]
    	val[9598]
    	val[9606]
    	val[9615]
    	val[9823]
    	val[9913]
	}	
	$1 in val' - > $out
done

echo "unpacking gene_info ..."
zcat gene_info.gz | awk '!/^#/' |
    awk 'BEGIN{
        val[10090]
        val[10116]
        val[7165]
        val[3702]
        val[386585]
        val[511145]
        val[559292]
        val[6239]
        val[7227]
        val[7955]
        val[8355]
        val[9031]
        val[9544]
        val[9598]
        val[9606]
        val[9615]
        val[9823]
        val[9913]
        }
        $1 in val' - > gene_info


## Do the remaining files as normal

echo "unpacking gene_refseq_uniprotkb_collab ..."
zcat gene_refseq_uniprotkb_collab.gz | awk '!/^#/' | cut -f 1-2 > gene_refseq_uniprotkb_collab
echo "unpacking gene_orthologs ..."
zcat gene_orthologs.gz | awk '!/^#/' | cut -f 1,2,4,5 > tmp
awk '{print $3"\t"$4"\t"$1"\t"$2}' tmp > tmp2
cat tmp tmp2 > gene_orthologs
rm tmp*
echo "extracting taxonomic names ..."
tar xvfz new_taxdump.tar.gz names.dmp
echo "removing mim2gene_medgen comments"
sed -i -e "/^#.*$/ {d}" mim2gene_medgen
echo "fixing txid mappings ..."
awk -F'|' '{if($4 ~ /scientific name/) print toupper($1$2)}' names.dmp |
    tr -s '\t' | sed 's/"//g' | sed 's/ /_/g' |  cut -f 1-2 > names.txt

## remove version numbers from accession numbers, e.g. NP_047184.1 -> NP_047184
echo "remove versions from accessions ..."
sed -i -e "s/\.[0-9]*\t/\t/g" gene2refseq
sed -i -e "s/\.[0-9]*\t/\t/g" gene2accession
sed -i -e "s/\.[0-9]*\t/\t/g" gene_refseq_uniprotkb_collab

## split cytogenetic band info via ";", ",", "|", "and", "or"
## split chromosome info via "|"
echo "process cytogentic bands and chromosome info ..."
rm -f gene_cytogenetic.tab
rm -f gene_chromosome.tab
rm -f gene_synonym.tab
rm -f gene_dbXrefs.tab
R --slave < ../script/parseAlias.R

## create source sqlite db
echo "creating source sqlite db ..."
rm -f genesrc.sqlite
sqlite3 -bail genesrc.sqlite < ../script/srcdb.sql

## create Orthology.eg sqlite db
echo "creating Orthology.eg sqlite db ..."
rm -f Orthology.eg.sqlite
sqlite3 -bail Orthology.eg.sqlite < ../script/src_orthology.sql

## record data download date
echo "inserting data download date ..."
echo "INSERT INTO metadata VALUES('EGSOURCEDATE', '$EGSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('EGSOURCENAME', '$EGSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('EGSOURCEURL', '$EGSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail genesrc.sqlite < temp_metadata.sql
sqlite3 -bail Orthology.eg.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
echo "done!"
