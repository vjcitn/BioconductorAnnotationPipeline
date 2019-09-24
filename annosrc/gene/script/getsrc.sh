#!/bin/sh
set -e
if [ "$EGSOURCEDATE" = "" ]; then
  . ./env.sh
fi

## unpack source data
echo "unpacking gene source data ..."
cd ../$EGSOURCEDATE
echo "unpacking gene2go ..."
gunzip -c gene2go.gz > gene2go
echo "unpacking gene2pubmed ..."
gunzip -c gene2pubmed.gz > gene2pubmed
echo "unpacking gene2refseq ..."
gunzip -c gene2refseq.gz > gene2refseq
echo "unpacking gene2accession ..."
gunzip -c gene2accession.gz > gene2accession
echo "unpacking gene_info ..."
gunzip -c gene_info.gz > gene_info
echo "unpacking gene_refseq_uniprotkb_collab ..."
gunzip -c gene_refseq_uniprotkb_collab.gz > gene_refseq_uniprotkb_collab

## remove comments
echo "remove comments ..."
echo "removing gene2go comments"
sed -i -e "/^#.*$/ {d}" gene2go
echo "removing gene_info comments"
sed -i -e "/^#.*$/ {d}" gene_info
echo "removing gene2refseq comments"
sed -i -e "/^#.*$/ {d}" gene2refseq
echo "removing gene2accession comments"
sed -i -e "/^#.*$/ {d}" gene2accession
echo "removing gene2unigene comments"
sed -i -e "/^#.*$/ {d}" gene2unigene
echo "removing gene2pubmed comments"
sed -i -e "/^#.*$/ {d}" gene2pubmed
echo "removing mim2gene_medgen comments"
sed -i -e "/^#.*$/ {d}" mim2gene_medgen
echo "removing gene_refseq_uniprotkb_collab comments"
sed -i -e "/^#.*$/ {d}" gene_refseq_uniprotkb_collab
echo "done removing comments"

## trim the gene_info file of extraneous cols
echo "trim gene_info file ..."
perl -ne 'BEGIN {@cols=(0 .. 13)}' -e 's/\r?\n//; @F=split /\t/, $_; print join("\t", @F[@cols]), "\n"' gene_info > temp_gene_info
rm -f gene_info
mv temp_gene_info gene_info

## remove version numbers from accession numbers, e.g. NP_047184.1 -> NP_047184
echo "remove versions from accessions ..."
sed -i -e "s/\.[0-9]*\t/\t/g" gene2refseq
sed -i -e "s/\.[0-9]*\t/\t/g" gene2accession

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

## record data download date
echo "inserting data download date ..."
echo "INSERT INTO metadata VALUES('EGSOURCEDATE', '$EGSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('EGSOURCENAME', '$EGSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('EGSOURCEURL', '$EGSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail genesrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql
echo "done!"

