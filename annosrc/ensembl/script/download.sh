#!/bin/sh
set -e
. ./env.sh
THIS_YEAR=`date|awk '{print $6}'`


##NOTE! the lack of a current_fasta dir for metazoans means we have to update the mosquito every time.  (WEAK, but at least we can get it)

PARENT_EN_URL="ftp://ftp.ensembl.org/pub/current_README"
LATEST_EN_DATE=`curl -IL $PARENT_EN_URL | grep "Last-Modified" | awk '{print $5 "-" $4 $3}'`

if [ -z "$LATEST_EN_DATE" ]; then
        echo "download.sh: current_fasta directory in $PARENT_EN_URL not found"
        exit 1
fi

if [ "$LATEST_EN_DATE" != "$ENSOURCEDATE" ]; then
        echo "update files in ./current_fasta from $ENSOURCEDATE to $LATEST_EN_DATE"
        sed -i -e "s/ ENSOURCEDATE=.*$/ ENSOURCEDATE=$LATEST_EN_DATE/g" env.sh
        mkdir ../$LATEST_EN_DATE #
        cd ../$LATEST_EN_DATE

        #then get the mapping data for the ensembl maps (http://www.ensembl.org/info/data/download.html)
        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/homo_sapiens/pep/
        gunzip Homo_sapiens.*.pep.all.fa.gz
        mv Homo_sapiens.*.pep.all.fa curHomo_sapiens_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/rattus_norvegicus/pep/
        gunzip Rattus_norvegicus.*.pep.all.fa.gz
        mv Rattus_norvegicus.*.pep.all.fa curRattus_norvegicus_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/mus_musculus/pep/
        gunzip Mus_musculus.*.pep.all.fa.gz
        mv Mus_musculus.*.pep.all.fa curMus_musculus_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/danio_rerio/pep/
        gunzip Danio_rerio.*.pep.all.fa.gz
        mv Danio_rerio.*.pep.all.fa curDanio_rerio_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/canis_familiaris/pep/
        gunzip Canis_familiaris.*.pep.all.fa.gz
        mv Canis_familiaris.*.pep.all.fa curCanis_familiaris_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/bos_taurus/pep/
        gunzip Bos_taurus.*.pep.all.fa.gz
        mv Bos_taurus.*.pep.all.fa curBos_taurus_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/caenorhabditis_elegans/pep/
        gunzip Caenorhabditis_elegans.*.pep.all.fa.gz
        mv Caenorhabditis_elegans.*.pep.all.fa curCaenorhabditis_elegans_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/gallus_gallus/pep/
        gunzip Gallus_gallus.*.pep.all.fa.gz
        mv Gallus_gallus.*.pep.all.fa curGallus_gallus_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/macaca_mulatta/pep/
        gunzip Macaca_mulatta.*.pep.all.fa.gz
        mv Macaca_mulatta.*.pep.all.fa curMacaca_mulatta_pep.fa

#         wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/anopheles_gambiae/pep/
#         gunzip Anopheles_gambiae.*.pep.all.fa.gz
#         mv Anopheles_gambiae.*.pep.all.fa curAnopheles_gambiae_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz ftp://ftp.ensemblgenomes.org/pub/current/metazoa/fasta/anopheles_gambiae/pep/
        gunzip Anopheles_gambiae.*.pep.all.fa.gz
        mv Anopheles_gambiae.*.pep.all.fa curAnopheles_gambiae_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/pan_troglodytes/pep/
        gunzip Pan_troglodytes.*.pep.all.fa.gz
        mv Pan_troglodytes.*.pep.all.fa curPan_troglodytes_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/drosophila_melanogaster/pep/
        gunzip Drosophila_melanogaster.*.pep.all.fa.gz
        mv Drosophila_melanogaster.*.pep.all.fa curDrosophila_melanogaster_pep.fa

        wget -r -l1 -nd -A .pep.all.fa.gz $ENSOURCEURL/saccharomyces_cerevisiae/pep/
        gunzip Saccharomyces_cerevisiae.*.pep.all.fa.gz
        mv Saccharomyces_cerevisiae.*.pep.all.fa curSaccharomyces_cerevisiae_pep.fa



 	##then get the mapping data for the ensembl maps
 	##(http://www.ensembl.org/info/data/download.html)
	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/homo_sapiens/cdna/
	gunzip Homo_sapiens.*.cdna.all.fa.gz
	mv Homo_sapiens.*.cdna.all.fa curHomo_sapiens_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/rattus_norvegicus/cdna/
	gunzip Rattus_norvegicus.*.cdna.all.fa.gz
	mv Rattus_norvegicus.*.cdna.all.fa curRattus_norvegicus_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/mus_musculus/cdna/
	gunzip Mus_musculus.*.cdna.all.fa.gz
	mv Mus_musculus.*.cdna.all.fa curMus_musculus_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/danio_rerio/cdna/
	gunzip Danio_rerio.*.cdna.all.fa.gz
	mv Danio_rerio.*.cdna.all.fa curDanio_rerio_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/canis_familiaris/cdna/
	gunzip Canis_familiaris.*.cdna.all.fa.gz
	mv Canis_familiaris.*.cdna.all.fa curCanis_familiaris_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/bos_taurus/cdna/
	gunzip Bos_taurus.*.cdna.all.fa.gz
	mv Bos_taurus.*.cdna.all.fa curBos_taurus_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/caenorhabditis_elegans/cdna/
	gunzip Caenorhabditis_elegans.*.cdna.all.fa.gz
	mv Caenorhabditis_elegans.*.cdna.all.fa curCaenorhabditis_elegans_cdna.fa

	wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/gallus_gallus/cdna/
	gunzip Gallus_gallus.*.cdna.all.fa.gz
	mv Gallus_gallus.*.cdna.all.fa curGallus_gallus_cdna.fa

        wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/macaca_mulatta/cdna/
        gunzip Macaca_mulatta.*.cdna.all.fa.gz
        mv Macaca_mulatta.*.cdna.all.fa curMacaca_mulatta_cdna.fa

#         wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/anopheles_gambiae/cdna/
#         gunzip Anopheles_gambiae.*.cdna.all.fa.gz
#         mv Anopheles_gambiae.*.cdna.all.fa curAnopheles_gambiae_cdna.fa

        wget -r -l1 -nd -A .cdna.all.fa.gz ftp://ftp.ensemblgenomes.org/pub/current/metazoa/fasta/anopheles_gambiae/cdna/
        gunzip Anopheles_gambiae.*.cdna.all.fa.gz
        mv Anopheles_gambiae.*.cdna.all.fa curAnopheles_gambiae_cdna.fa


        wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/pan_troglodytes/cdna/
        gunzip Pan_troglodytes.*.cdna.all.fa.gz
        mv Pan_troglodytes.*.cdna.all.fa curPan_troglodytes_cdna.fa


        wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/drosophila_melanogaster/cdna/
        gunzip Drosophila_melanogaster.*.cdna.all.fa.gz
        mv Drosophila_melanogaster.*.cdna.all.fa curDrosophila_melanogaster_cdna.fa

        wget -r -l1 -nd -A .cdna.all.fa.gz $ENSOURCEURL/saccharomyces_cerevisiae/cdna/
        gunzip Saccharomyces_cerevisiae.*.cdna.all.fa.gz
        mv Saccharomyces_cerevisiae.*.cdna.all.fa curSaccharomyces_cerevisiae_cdna.fa


        cd ../script

else
        echo "the latest data for the current_fasta directory is still $ENSOURCEDATE"
fi



