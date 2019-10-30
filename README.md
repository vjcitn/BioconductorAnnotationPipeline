# Bioconductor Annotation Pipeline <a name="top"/>

The goal of the code in this package is to build the db0, OrgDb, PFAM, GO, 
and TxDb packages. As of Bioconductor 3.5 we no longer build KEGG, ChipDb, 
probe or cdf packages. BSGenome, SNPlocs, and XtraSNPlocs packages are built 
by Herve. 

The build system is based on a set of bash and R scripts, in various 
different directories that are called by the top-level `master.sh` script 
which calls sub-scripts. The following document goes through the steps of 
running the pipeline in more detail.

### Table of Contents
+ [Pipeline prep](#pipelineprep)
+ [Update R](#updater)
+ [Download data](#downloaddata)
+ [Parse data](#parsedata)
+ [Build data](#builddata)
+ [Additonal scripts](#additionalscripts)
+ [Build db0 packages](#builddb0pkgs)
+ [Build OrgDb, PFAM.db, and GO.db packages](#buildmanypkgs)
+ [Build TxDb packages](#buildtxdbpkgs)
+ [Where do they belong?](#where)
+ [Clean up](#cleanup)
+ [Troubleshooting](#troubleshooting)

## Pipeline prep <a name="pipelineprep"/>

The first step of the pipeline is to log onto the `generateAnnotationsV2` EC2 
instance as `ubuntu`. Downloading the data and generating the annotation 
packages will take up over 100GB of disk space on the instance. Be sure to 
have this amount of space otherwise the process will fail. 

**TODO:** Decide a minimum amount of required space for the scripts to run.

The clean up step should have been performed at the end of the pipeline 
during the last release, but if it was not here are a couple ways to 
potentially clean up the instance:

* Remove old dbs from the `db/` directory and only save the `metadata.sqlite` 
file (under version control in case it gets deleted). **Do not remove any 
files from `db/` once the parsing has started.** Products sent there are 
either needed in a subsequent step or may be the final product. 
* Remove older data downloads from each folder, there should only be one 
version present. It is suggested to keep the previous version for comparison/
testing.

[Back to top](#top)

## Update R <a name="updater"/>

In order for the packages to be built for the next Bioconductor release, the 
R version on `ubuntu` will have to be updated. This will be done as `root` 
and the packages will be installed as `ubuntu`. There is a README.md file 
(`home/ubuntu/downloads/README.md`) with basic instructions on how to do this 
but the following will provide a bit more detail.

**1. Download the correct version of R**

The R version that was needed at the time this documentation was created was 
R-3.6. The following command should be changed dependent on which R version 
is needed.

```sh
wget https://cran.r-project.org/src/base/R-3/R-3.6.1.tar.gz
```

**2. Extract the tar file**

```sh
tar zxf R-3.6.1.tar.gz
```

**3. Change into the directory and make/install**

```sh
cd R-3.6.1
sudo ./configure --enable-R-shlib --prefix=/usr/local
sudo make
sudo make install
```

**4. Clean up  the installations**

Rename the old R version, e.g. `R-3.5`, to `R.old` and move it into 
`R-installations/`. Any older versions of R can be removed from 
`R-installations/`, we want to make sure there is at least one working 
version of R available if needed. Now rename the new version of R, e.g. 
`R-3.6`, to `R` so when ever `R` is called this verson will be deployed (we 
will also be setting up aliases to help with this). Move the `tar` and 
`tar.gz` into `downloads/`. 

**QUESTION:** Could the `tar` and `tar.gz` just be removed since they can 
always be redownload from `CRAN`?

**5. Set up proper aliases**

Open the `.bashrc` file to edit the aliases for R. Make the R library 
directory a personal directory, eg. R-3.6.1, and leave bin to R. 

**ADD MORE DETAIL WHEN INSTANCE IS TURNED BACK ON**

[Back to top](#top)

## Download data <a name="downloaddata"/>

Now that the instance is cleaned up (`BioconductorAnnotationPipline/` - 141G) 
and the `R` version is updated it is time to start downloading the data 
needed to create the packages. This can be done by running the command:

```sh
sh src_download.sh
```

There are data-specific directories that contain their own specific 
`script/download.sh` scripts. These data-specific scripts are called by the 
'master' `src_download.sh` script. The script can be run as a whole or it can 
be run one data type at a time. To run it one data type at a time use an 
`if false; then ... fi` statement, where `...` are the download scripts that 
should not be run.

In order to monitor that the download script is running properly, it is good 
practice to know which of the data-specific directories will get new data 
downloaded to the them. This can be achieved by checking the timestamp on the 
website against the `*SOURCEDATE` variable in the data-specific `env.sh` 
script. If the website has a newer date than the `*SOURCEDATE`, new data will 
be downloaded. Besides differences in dates, if any manual updates are made 
to the data-specific `env.sh` script than new data will be downloaded. 
Additional information for each of the data-specific directories, along with 
the variable(s) that should be checked, are listed below.

**Data-specific directories:**
* go
	+ ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/
	+ Appears to be current, now updated weekly.
	+ Check `GOSOURCEDATE` in `go/script/env.sh`.
* unigene
	+ ftp://ftp.ncbi.nih.gov/repository/UniGene/
	+ Last downloads are from 2013. Website documentation indicates data 
are updated more frequently via the web interface; not sure why the ftp 
archives are so old.
	+ Check `UGSOURCEDATE_*` for each of the organisms in 
`unigene/script/env.sh`.
* gene
	+ ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
	+ Updated daily.
	+ Used to create organism specific sqlite data. We only keep 
gene2accession and gene2unigene mapping data extracted from both Entrez Gene 
and UniGene used to generate the probe to Entrez Gene mapping for individual 
chips.
	+ Check `EGSOURCEDATE` in `gene/script/env.sh`.
* goext
	+ http://www.geneontology.org/external2go
	+ Maps GO to external classification systems (other vocabularies).
	+ Check `GOEXTSOURCEDATE` in `goext/script/env.sh`.
* ucsc
	+ ftp://hgdownload.cse.ucsc.edu/goldenPath/
	+ Source code ranges from 2010-present because genome update occur at 
different times.
	+ Check `GPSOURCEDATE_*` for each of the organisms in 
`ucsc/script/env.sh`.
	+ Manually update `BUILD_*` with the most current build for each of 
the organisms in `ucsc/script/env.sh`.
* yeast
	+ http://downloads.yeastgenome.org/
	+ Check `YGSOURCEDATE` in `yeast/script/env.sh`.
* ensembl
	+ ftp://ftp.ensembl.org/pub/current_fasta
	+ Download fasta cdna and pep files.
	+ Check `ENSOURCEDATE` in `ensembl/script/env.sh`.
* plasmoDB
	+ http://plasmodb.org/common/downloads/release-28/Pfalciparum3D7/txt/
	+ We are using release 28 (March 2016) and the most current version 
is 31 (March 2017). We use version 28 because that is the last time the 
PlasmoDB-28_Pfalciparum3D7Gene.txt file was provided and that's what the code 
is set up to parse. 
	+ **TODO:** Don't see a clear replacement - the information might be 
available in another file in the directory bt it will take some investigation.
	+ Check `PLASMOSOURCEDATE` in `plasmoDB/script/env.sh`.
* pfam
	+ ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release
	+ Protein families represented by multiple sequence alignments.
	+ Check `PFAMSOURCEDATE` in `pfam/script/env.sh`.
* inparanoid
	+ http://inparanoid.sbc.su.se/download/old_versions/History
	+ Frozen at version 6.1 (2007), it looks like the last version was 8.0 
(2013). Not sure worth updating, probably better to find a more current 
replacement.
	+ The scripts in this directory update flybase which is still active.
	+ ftp://ftp.flybase.net/releases/current/precomputed_files/genes/
	+ Check `FBSOURCEDATE` in `inparanoid/script/env.sh`.
	+ Manually update `FILE` in `inparanoid/script/env.sh`.
* tair
	+ ftp://ftp.arabidopsis.org
	+ Last download was April 2015 (TAIR10).
	+ Download script is not run but the parse and build are to run so 
the most current GO gets inserted. Last release was April 2015. Used to build 
`db0` and `OrgDb` packages. Data are static but for Bioconductor 3.3 packages 
were rebuilt and reversioned.
	+ **TODO:** If another release doesn't come out before Fall 2016 ask 
on bioc-devel if we want to keep this.
	+ Check `TAIRSOURCEDATE` in `tair/script/env.sh`.
* KEGG
	+ KEGG data are no longer available for download.
	+ **TODO:** Look into replacing it with `KEGGREST` package.

When the `src_download.sh` script is done running, confirm that the new data 
has been downloaded by checking for the date-specific directory. If no new 
data was downloaded and it should have been, check the 
[Troubleshooting](#troubleshooting) section of this README file for further 
instructions.

For the Bioconductor 3.10 release, the `go`, `gene`, `ucsc`, and `ensembl` 
directories had new data downloaded to them. After running the 
`src_download.sh` script was run, 5G of information was added to the pipeline 
(`BioconductorAnnotationPipeline/` - 146G).

[Back to top](#top)

## Parse data <a name="parsedata"/>

The next step in the pipeline is to run the parse scripts. This can be done by 
running the command:

```sh
sh src_parse.sh
```

The `src_parse.sh` script calls data-specific `getsrc.sh` scripts which calls 
data-specific `srcdb.sql` (or `srcdb_*` if there are many organisms). This step 
will either

* parse the download data,
* create databases to be used in the build step (e.g. `ensembl.sqlite`), or
* produce the final database product (e.g. `PFAM.sqlite`). 

Keep in mind that once this step has started no files should be removed from 
`db/` since these products may be needed in a subsequent step and/or may be a 
final product. The parsing step is quite simple but will take a long time to 
run. See the [Troubleshooting](#troubleshooting) section of this README file for 
advice if things happen to go wrong.

The parsing step adds a lot of data to `BioconductorAnnotationPipeline/`. For 
the Bioconductor 3.10 release, the parse step increased the data by 49G 
(`BioconductorAnnotationPipeline/` - 195G).

[Back to top](#top)

## Build data <a name="builddata"/>

After parsing the data it's time to build the data. To build the data the 
following command is run:

```sh
src_build.sh
```

The `src_build.sh` script calls data-specific `getdb.sh` and `temp_metadata.sql` 
scripts. In the two previous scripts, the order that the data-specific scripts 
did not matter because they were all independent of each other. For this build 
script, **the order matters** since products of certain scripts are needed for 
other scripts to work.

The products from the build step are the `chipsrc*.sqlite` and 
`chipmapsrc*.sqlite` databases in `db/`.

**TODO:** I think more comments could be added to track the progress along the 
way.

Refer to the [Troubleshooting](#troubleshooting) section of this README file for 
advice if the build step goes awry.

The build step will add about 66G of data to the pipeline. For the Bioconductor 
3.10 release, at the end of the building step the 
`BioconductorAnnotationPipeline/` was up to 261G.

[Back to top](#top)

## Additional scripts <a name="additionalscripts"/>


[Back to top](#top)

## Build db0 packages <a name="builddb0pkgs"/>


[Back to top](#top)

## Build OrgDb, PFAM.db, and GO.db packages <a name="buildmanypkgs"/>


[Back to top](#top)

## Build TxDb packages <a name="buildtxdbpkgs"/>


[Back to top](#top)

## Where do they belong? <a name="where"/>


[Back to top](#top)

## Clean up <a name="cleanup"/>


[Back to top](#top)

## Troubleshooting <a name="troubleshooting"/>

<!--- Section about troubleshooting data download -->

<!--- Section about troubleshooting data parsing -->

<!--- Section about troubleshooting data building -->

[Back to top](#top)

# BioconductorAnnotationPipeline
Code to build Bioconductor annotation packages. See the [wiki](https://github.com/Bioconductor/BioconductorAnnotationPipeline/wiki) for more details.
