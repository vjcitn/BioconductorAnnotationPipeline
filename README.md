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
have this amount of space otherwise the process will fail. It never hurts to do 
a pull of the repo to be sure everything is up to date before running the 
pipeline.

```sh
git pull
``` 

**TODO:** Decide on a minimum amount of required space for the scripts to run.

The clean up step should have been performed at the end of the pipeline 
during the last release, but if it was not here are a couple ways to 
potentially clean up the instance:

* Remove old files from the `db/` directory and only save the
`metadata.sqlite` and the map_counts.sqlite files (under version
control in case they get deleted). **Do not remove any files from
`db/` once the parsing has started.** Products sent there are either
needed in a subsequent step or may be the final product.  * Remove
older data downloads from each folder, there should only be one
version present. It is suggested to keep the previous version for
comparison/ testing.

[Back to top](#top)

## Update R <a name="updater"/>

In order for the packages to be built for the next Bioconductor release, the 
R version on `ubuntu` may have to be updated. This should be done as `root` 
and the packages will be installed as `ubuntu`. There is a README.md file 
(`home/ubuntu/downloads/README.md`) with basic instructions on how to do this 
but the following will provide some additional details.

**1. Download the correct version of R**

For the Spring release, download R-devel. For the Fall release
download the latest patched release version.

```sh
wget https://cran.r-project.org/src/base/R-4/<correct R-version>
```

**2. Extract the tar file**

```sh
tar zxf <correct R-version>
```

**3. Change into the directory and make**

```sh
cd <correct R-version>
sudo ./configure --enable-R-shlib 
make
```
R is run directly from this directory, so no need to do `make
install`, or to point to a prefix dir.

**4. Clean up  the installations**

Previous versions of R can be deleted, but it may be advantageous to
keep the one from the last build.

**5. Set up proper aliases**

Since we run R from the build dir, open `.bashrc` and adjust the alias
to point to the current version of R, as well as the library
dir. Mostly this means edit the last part of this alias, which points to the R build dir.

```sh
alias R='R_LIBS_USER=~/R-libraries ~/R-4.0.2/bin/R'
```


**6. Install packages**

Run the following commands to install the packages that are needed for this 
pipeline to work properly.

```r
chooseCRANmirror()
install.packages("BiocManager")
```
We always build using Bioc-devel. If building in Spring using R-devel,
do

```r
library(BiocManager)
BiocManager::install(ask = FALSE)
```
for the Fall build it's slightly different

```r
library(BiocManager)
useDevel(TRUE)
BiocManager::install(ask = FALSE)
```

**FIXME:** In any of the R files that are run in the pipeline call a package to 
be loaded, and the R installation is non-standard, there will have to be a 
`.libPath()` declared for the created library. There seems to be an issue when 
calling the shell command and it not calling the right lib path.

[Back to top](#top)

## Download data <a name="downloaddata"/>

Now that the instance is cleaned up (`BioconductorAnnotationPipline/` - 141G) 
and the R version is updated it is time to start downloading the data 
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
	+ unigene is now defunct, and we just put the old data into
the databases. Kept now simply for backwards compatibility.
	+ ftp://ftp.ncbi.nih.gov/repository/UniGene/
	+ Last downloads are from 2013. 
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
available in another file in the directory but it will take some investigation.
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

There are 2 additional scripts that need to be run after the data is built. The 
first script is run by:

```sh
sh copyLatest.sh
```

This script inserts database schema version in the GO, PFAM, KEGG and YEAST 
databases. The next script, which is found in `map_counts/scripts/`:

```sh
sh getdb.sh
```

is used to check the quality of the intermediate sql databases. This script 
counts tables in a subset of the `chipsrc` databases. These numbers are then 
recorded in the existing `map_counts.sqlite` file. The data is compared to 
numbers from the last release. There is a warning that is issued for 
discrepancies >10%. Remember `map_counts.sqlite` is under version control so 
there are records of data loss/gain over the releases.

At this point all code changes should be commit to git. No data files should be 
added.

[Back to top](#top)

## Build db0 packages <a name="builddb0pkgs"/>

Now that all the data is built, it is time to start building the annotation 
packages that will be part of the Bioconductor release. All the code needed to 
build these packages are located in `BioconductorAnnotationPipeline/newPipe/`.
Within in this directory there are 3 packages that are needed. Since these are 
clones of the repos, a git pull for each of the packages should be done to be 
sure the most up to date version is utilized.

```sh
cd AnnotationDbi
git pull
cd ..

cd AnnotationForge
git pull
cd ..

cd GenomicFeatures
git pull
cd ..
```

**QUESTION:** `AnnotaionForge` and `GenomicFeatures` versions are different on 
Daniel's annotation instance because we don't push changes to these packages. 
Would it be the worst case to push changes if the files aren't used else where 
in the package. Or maybe we just make a local copy of the file that keeps track 
of the change and we can push to our repo?
 
The first set of packages that should be built are the db0 packages, e.g., 
`human.db0`, `mouse.db0`.

**1. Make edits to makeDbZeros.R**

There are two variables in the R script that should be updated. The `outDir` 
should be set to a valid date for when the script is being run. This will 
become the name of the directory that will house the db0 packages being created. 
The `version` should be a valid version depending on what the Bioconductor 
release will be, e.g., for the October 2019 Bioconductor 3.10 release `version` 
was set to "3.10.0". This will become the version for all the db0 packages.
 
**2. Run makeDbZeros.R**

```sh
R --slave < makeDbZeros.R
```

This script creates the db0 packages by calling 
`AnnotationForge::sqlForge_wrapBaseDBPkgs.R`. 

**3. Build, check, and install db0 packages**

Each of the db0 packages in `BioconductorAnnotationPipeline/newPipe/XXXXXXXX_DB0s/`
need to be built and checked using `R CMD build` and `R CMD check`. 

If all the packages build and check without error then the packages should be 
installed using `R CMD INSTALL`. 

**4. Spot check**

The `chipmapsrc_mouse.sqlite` file in the new `mouse.db0` package should have 
8 tables:

```r
> library(mouse.db0)
> library(RSQLite)
> dat1 <- system.file("extdata", file = "chipmapsrc_mouse.sqlite", package = "mouse.db0")
> con1 <- dbConnect(drv=RSQLite::SQLite(), dbname = dat1)
> dbListTables(con1)
[1] "EGList"             "accession"          "accession_unigene"
[4] "image_acc_from_uni" "metadata"           "refseq"
[7] "sqlite_stat1"       "unigene"
```

The `chipsrc_mouse.sqlite` file in the new `mouse.db0` package should have 32 
tables:

```r
> dat2 <- system.file("extdata", file = "chipsrc_mouse.sqlite", package = "mouse.db0")
> con2 <- dbConnect(drv=RSQLite::SQLite(), dbname = dat2)
> dbListTables(con2)
 [1] "accessions"            "chrlengths"            "chromosome_locations"
 [4] "chromosomes"           "cytogenetic_locations" "ec"
 [7] "ensembl"               "ensembl2ncbi"          "ensembl_prot"
[10] "ensembl_trans"         "gene_info"             "gene_synonyms"
[13] "genes"                 "go_bp"                 "go_bp_all"
[16] "go_cc"                 "go_cc_all"             "go_mf"
[19] "go_mf_all"             "kegg"                  "map_counts"
[22] "map_metadata"          "metadata"              "mgi"
[25] "ncbi2ensembl"          "pfam"                  "prosite"
[28] "pubmed"                "refseq"                "sqlite_stat1"
[31] "unigene"               "uniprot"
```

The only things that need to be kept in the db0 package directory is the tarball 
files created by `R CMD build`. The repos and the check logs can all be deleted.

**5. Empty table check**

Another test that can be done is to check that the tables actually got 
populated properly. This can be done by looking for empty tables within each of 
the db0 packages and confirming if they were previously empty or not. A function 
has been written to ease the implementation of this test over all of the db0 
packages. See the function and example below that demonstrates this test for the 
`anopheles.db0` package.

```r
# The created function
> library(RSQLite)
> tbl_check <- function(pkg_name) {
+ if(!(pkg_name %in% rownames(installed.packages())))
+     BiocManager::install(pkg_name)
+ library(pkg_name, character.only = TRUE)
+
+ species <- gsub(".db0", "", pkg_name)
+
+ dat1 <- system.file("extdata", file = paste0("chipmapsrc_", species, ".sqlite"),
+     package = pkg_name)
+ if (nzchar(dat1)) {
+     con1 <- dbConnect(drv=RSQLite::SQLite(), dbname = dat1)
+     sql1 <- paste("SELECT COUNT(*) FROM", dbListTables(con1), ";")
+     lst1 <- sapply(sql1, function(sql) dbGetQuery(con1, sql))
+     dbDisconnect(con1)
+
+     cat("The empty tables in the chipmapsrc file", "\n")
+     names(lst1[which(lst1 == 0)])
+ } else
+     cat("There is no chipmapsrc file for this species")
+
+ dat2 <- system.file("extdata", file = paste0("chipsrc_", species, ".sqlite"),
+     package = pkg_name)
+ if (nzchar(dat2)) {
+     con2 <- dbConnect(drv=RSQLite::SQLite(), dbname = dat2)
+     sql2 <- paste0("SELECT COUNT(*) FROM ", dbListTables(con2), ";")
+     lst2 <- sapply(sql2, function(sql) dbGetQuery(con2, sql))
+     dbDisconnect(con2)
+
+     cat("\nThe empty tables in the chipsrc file", "\n")
+     names(lst2[which(lst2 == 0)])
+ } else
+     cat("\nThere is no chipsrc file for this species")
+ }
> tbl_check("anopheles.db0")
The empty tables in the chipmapsrc file

The empty tables in the chipsrc file
[1] "SELECT COUNT(*) FROM ncbi2ensembl;.COUNT(*)"
```

Once the empty tables are discovered, like the `ncbi2ensembl` table in the 
chipsrc file for the `anopheles.db0` package, the tables should be compared to 
a local version of the current release verison of the package. This will 
indicate whether the table has been empty or if this was a bug introduced in 
this particular run of the pipeline. If this is a bug then some debugging will 
have to be done to figure out what went wrong during this run of the pipeline 
before making the packages available and/or creating other packages off this 
wrong information.

**6. Build, check, and install AnnotationForge**

Since `AnnotationForge` suggests the use of `human.db0`, it should be built,
checked, and installed once the new db0 packages are installed. This can done by
using `R CMD build`, `R CMD check`, and `R CMD INSTALL`.

[Back to top](#top)

## Build OrgDb, PFAM.db, and GO.db packages <a name="buildmanypkgs"/>

In order for the OrgDb, PFAM.db, and GO.db packages to get built the db0 
packages must be built first. If the db0 packages have not bee built yet, please 
refer to the [Build db0 packages](#builddb0pkgs) section above.

**1. Update version of packages**

Modify `Version` and potentially the `DBfile` path to the sqlite file for the 
21 OrgDb packages, GO.db, and PFAM.db within the 
`AnnotationForge/inst/extdata/Gentlemanlab/ANNDBPKG-INDEX.TXT` file. The changes 
to this file **should not be pushed**.

**2. Build, check, and install new AnnotationForge**

`R CMD build`, `R CMD check`, and `R CMD INSTALL` the modified `AnnotationForge`
package. This must be done before building the OrgDb, PFAM.db, and GO.db 
packages because the new versions are in the template in `AnnotationForge` that 
was just modified.

**3. Make edits to makeTerminalDBPkgs.R**

In the `makeTerminalDBPkgs.R` file the `dateDir` should be set to a valid date 
for when the script is being run. This will become the name of the directory 
that will house the OrgDbs, PFAM.db, and GO.db packages that are being created. 

There is code in this file that will create the TxDb packages but it should not 
be run yet. There for an `if (FALSE) {...}` statement should be used where `...` 
is the code to make the TxDb packages.

**4. Run makeTerminalDBPkgs.R**

Run the portion of `makeTerminalDBPkgs.R` that generates the OrgDbs, PFAM.db, 
and GO.db packages.

```r
R --slave < makeTerminalDBPkgs.R
```

**5. Build, check, and install the new packages**

`R CMD build`, `R CMD check`, and `R CMD INSTALL` the new `GO.db` package before 
building and checking the OrgDbs. Continue building, checking, and installing 
for all of the OrgDbs and PFAM.db.

**6. Spot check**

Open an R session and load a newly created OrgDb object, e.g., `org.Hs.eg.db`, to 
ensure that all resources are up-to-date. Specifically, check the GO and ENSEMBL 
download dates in the metadata of the object. These should be more recent than 
the last release. 

```r
> library(org.Hs.eg.db)
> org.Hs.eg.db
OrgDb object:
| DBSCHEMAVERSION: 2.1
| Db type: OrgDb
| Supporting package: AnnotationDbi
| DBSCHEMA: HUMAN_DB
| ORGANISM: Homo sapiens
| SPECIES: Human
| EGSOURCEDATE: 2019-Jul10
| EGSOURCENAME: Entrez Gene
| EGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
| CENTRALID: EG
| TAXID: 9606
| GOSOURCENAME: Gene Ontology
| GOSOURCEURL: ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/
| GOSOURCEDATE: 2019-Jul10
| GOEGSOURCEDATE: 2019-Jul10
| GOEGSOURCENAME: Entrez Gene
| GOEGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
| KEGGSOURCENAME: KEGG GENOME
| KEGGSOURCEURL: ftp://ftp.genome.jp/pub/kegg/genomes
| KEGGSOURCEDATE: 2011-Mar15
| GPSOURCENAME: UCSC Genome Bioinformatics (Homo sapiens)
| GPSOURCEURL:
| GPSOURCEDATE: 2019-Sep3
| ENSOURCEDATE: 2019-Jun24
| ENSOURCENAME: Ensembl
| ENSOURCEURL: ftp://ftp.ensembl.org/pub/current_fasta
| UPSOURCENAME: Uniprot
| UPSOURCEURL: http://www.UniProt.org/
| UPSOURCEDATE: Mon Oct 21 14:24:25 2019

Please see: help('select') for usage information
```

**7. Build other packages**

The final test for these new OrgDbs, PFAM.db, and GO.db packages are to build, 
check, and install `AnnotationDbi` and `AnnotationForge` with `R CMD build`, 
`R CMD check`, and `R CMD INSTALL`.

Much like the db0 packages, the only products that need to remain in the OrgDb 
directory are the tarball files from `R CMD build`. Everything else can be 
removed.

[Back to top](#top)

## Build TxDb packages <a name="buildtxdbpkgs"/>

**1. Identify which tracks should be updated**

Information should be compared between what is currently available on 
[Bioconductor](https://www.bioconductor.org/packages/release/BiocViews.html#___TxDb) 
 devel and what is currently available on the 
[UCSC Genome Browser](https://genome.ucsc.edu/cgi-bin/hgGateway). For example, 
for the package `TxDb.Hsapiens.UCSC.hg38.knownGene` on the UCSC Genome Browser 
human should be selected, then under 'Human Assembly' the Dec. 2013 
(GRCh38/hg38) option should be selected, then press 'Go'. Under 'Genes and Gene 
Predictions' select 'GENCODE v32' (this is what is selected for known gene 
information). The 'Date last updated' should be checked. If this date is newer 
than the last release then this package needs to be updated. This should be 
repeated for all of the packages available on Bioconductor. 

It is also important to identify tracks that may not be availabe yet on 
Bioconductor because these may be new packages that can be added. 

**NOTE:** If any of the new tracks that aren't available yet on Bioconductor are 
have NCBI Ref Seq data, then let Herve know so he can edit the code in 
`GenomicFeatures`.

**2. Modify makeTxDb.R**

Once the packages that should be updated and/or created are identified, then 
a script in `GenomicFeatures` should be updated. Modify 
`GenomicFeatures/inst/script/makeTxDb.R` as appropriate. **DO NOT** push the 
changes to this code.

`GenomicFeatures` must be built, checked, and installed so that the updated 
version is used when running the script in step 4. 

**3. Edit makeTerminalDBPkgs.R**

Now the code to create the TxDb should be run and the code that made the 
OrgDbs should be included in the `if (FALSE) {...}` statement. The `dateDir` 
should be set to a valid date for when the script is being run. This will become 
the name of the directory that will house the TxDbs. The `version` should be a 
valid version depending on what the release is for Bioconductor. 

**4. Run makeTerminalDBPkgs.R**

Run the portion of `makeTerminalDBPkgs.R` that generates the TxDb packages.

```sh
R --slave < makeTerminalDBPkgs.R
```

**5. Build, check, and install TxDb packages**

Run `R CMD build`, `R CMD check`, and `R CMD INSTALL` for all of the newly 
created TxDb packages. Load a few of the packages in an R session and check the 
dates to be sure that the appropriately dated packages are being used.

Like the other packages that were created the only files that need to remain in 
the TxDb directory are the tarball files from `R CMD build`, everything else 
can be deleted. 

[Back to top](#top)

## Where do they belong? <a name="where"/>

The tarball files for all the db0, OrgDb, PFAM.db, GO.db, and TxDb packages 
created from `R CMD build` need to get on the linux builder for the release. The 
following example shows how to do this for the 3.10 release of Bioconductor.

**1. Log onto the builder**

For the 3.10 release, the builder is `malbec1` so log onto this user as 
`biocadmin`. This will change between `malbec1` and `malbec2` from release to 
release, edit accordingly. Then change into the `sandbox` directory.

```sh
ssh biocadmin@malbec1.bioconductor.org

cd sandbox
```

**2. Copy the tarball files over**

The files from the EC2 instance need to get copied over to `malbec1:sandbox/`. 
The public IP for the EC2 instance will change each time it is stopped and 
restarted, edit accordingly.

```sh
scp -r ubuntu@18.209.179.34:/home/ubuntu/BioconductorAnnotationPipeline/newPipe/20191011_DB0s/ .
```

This should be repeated for the OrgDb and TxDb directories that were created in 
the previous steps.

**3. Check file sizes**

It is good practice to be sure files were copied over correctly. This can be 
done by using `cksum` of a file on the instance and comparing it to the `cksum`
of the same file on `malbec1:sandbox/`. For example,

```sh
# on EC2 instance
cd newPipe/20191011_DB0s/
cksum human.db0_3.10.0.tar.gz

# on malbec1:sandbox/
cksum human.db0_3.10.0.tar.gz
```

The two numbers produced from cksum should be the same. This mean that all of 
the information was copied over from the instance to the builder.

**4. Copy the files to contrib/**

Once it is clear all the information has been copied over correctly then the 
files can be copied over to their final destination.

```sh
# on malbec1:sandbox/
cd 20191011_DB0s
scp -r . /home/biocadmin/PACKAGES/3.10/data/annotation/src/contrib
```

**5. Check file sizes again**

Repeat `cksum` on the files, comparing between the `malbec1:sandbox/` copy and 
the `/home/biocadmin/PACKAGES/3.10/data/annotation/src/contrib/` copy.

**6. Remove old versions**

For the new annotation packages, there should be older versions already present 
on the builder. These old versions should be removed. Be sure to only remove 
versions that are getting replaced because once they are removed they can't be 
recovered again.

**7. Run crontab job**

The final step is to run a crontab job on the builder, but isn't part of this 
pipeline. For further instructions on how to accomplish this step please see the 
**NAME OF FILE** at https://github.com/Bioconductor/BBS/tree/master/Doc.

Once the crontab job has completed, the landing pages have been updated on devel 
(which will become release), and the VIEWS have been updated than announce the 
new annotation packages are available.

[Back to top](#top)

## Clean up <a name="cleanup"/>

All data has been created and all packages have been built, it's time to clean 
up! Run through each section of this pipeline and remove any unnecessary copies 
of data. Below is a list of areas that can be cleaned before stopping the EC2 
instance.

* `BioconductorAnnotationPipeline/annosrc/`
	+ `db/` -  everything besides the `metadatasrc.sqlite` file
	+ `ensembl/` - any outdated data
	+ `gene/` - any outdated data
	+ `go/` - any outdated data
	+ `goext/` - any outdated data
	+ `inparanoid/` - any outdated data
	+ `pfam/` - any outdated data
	+ `plasmoDB/` - any outdated data
	+ `tair/` - any outdated data
	+ `ucsc/` - any outdated data
	+ `unigene/` - any outdated data
	+ `yeast/` - any outdated data

* `BioconductorAnnotationPipeline/newPipe/`
	+ any outdated `XXXXXXXX_DB0s/`
	+ any outdated `XXXXXXXX_OrgDbs/`
	+ any outdated `XXXXXXXX_TxDbs/`
* `malbec1:sandbox/` (or `malbec2:sandbox/` depending on release)
	+ any outdated `XXXXXXXX_DB0s/`
	+ any outdated `XXXXXXXX_OrgDbs/`
	+ any outdated `XXXXXXXX_TxDbs/`

[Back to top](#top)

## Troubleshooting <a name="troubleshooting"/>

This section will help to explain some areas of trouble while running the 
pipeline. Some issues might have happened by chance and therefore weren't 
documented here. Troubleshooting will continue to be updated as persistent 
issues arise.

### Downloading data

**1. Connectivity issues**

Since the download step accesses online resources, there are possiblities for 
connectivity issues. The only solution for this is to try to rerun the download 
script. For example, when running the download script for 'ucsc' there was an 
error due to a connectivity issue. The first step in the script is to test if 
the directory is present, if not it creates the directory and downloads the 
data. If the directory is already present nothing is downloaded. When the 'ucsc' 
script errored out, it was trying to access data for 'human'. The directory 
'2019-Jun6' was created and no data was downloaded because of a connectivity 
issue. When trying to rerun the script, it is assumed the data was already 
downloaded since the directory is present. To avoid missed data, the created 
directory should be removed and the `GPSOURCEDATE` in `script/env.sh` should be 
set to back to the last release date. 

[Back to top](#top)
