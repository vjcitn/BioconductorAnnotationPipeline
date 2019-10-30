# Bioconductor Annotation Pipeline

The goal of the code in this package is to build the db0, OrgDb, PFAM, GO, and TxDb packages. As of Bioconductor 3.5 we no longer build KEGG, ChipDb, probe or cdf packages. BSGenome, SNPlocs, and XtraSNPlocs packages are build by Herve. The build system is based on a set of bash and R scripts, in various different directories that are called by the top-level `master.sh` script which calls sub-scripts. The following document goes through the steps of running the pipeline in more detail.

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

The first step of the pipeline is to log into the `generateAnnotationsV2` EC2 instance as `ubuntu`. Downloading the resources and generating the annotations will take up over 100GB of disk space on the instance. Be sure to have this amount of space otherwise the process will fail. *Future work:* Decide a minimum amount of required space for the scripts to run.

If the clean up step was preformed last release than there should not be much work to be done here. However, if it was not here are a couple ways to potential clean up the instance:

* Remove old dbs from the `db/` directory and only save the `metadata.sqlite` file (under version control in case it gets deleted). **Do not remove any files from `db/` once the parsing has started.** Products sent there are either needed in a subsequent step or may be the final product. 
* Remove older data downloads from each folder, there should only be one copy/version present. I suggest keeping the previous version for comparison/testing.

## Update R <a name="updater"/>

In order for the packages to be built for the next Bioconductor release, the R version on `ubuntu` will have to be updated. This will be done as `root` and the packages will be installed as `ubuntu`. There is a README.md file on `ubuntu` (`home/ubuntu/downloads/README.md`) with basic instructions on how to do this but I will provide a bit more detail here.

**1. Download the correct version of R**

The R version that was needed at the time this documentation was created was R-3.6. The following command should be changed dependent on which R version is needed.

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

Rename the old R version, e.g. `R-3.5`, to `R.old` and move it into `R-installations/`. Any older versions of R can be removed from `R-installations/`, we want to make sure there is at least one working version of R available if needed. Now rename the new version of R, e.g. `R-3.6`, to `R` so when ever `R` is called this verson of `R` will be deployed (we will also be setting up aliases to help with this). Move the `tar` and `tar.gz` into `downloads/`. **QUESTION:** Can't they just be removed since we can always redownload the `R` version from `CRAN`?

**5. Set up proper aliases**

Open the `.bashrc` file to edit the aliases for R. Make the R library directory a personal personal directory, eg. R-3.6.1, and leave bin to R. **MUST FIX THIS WHEN I CAN GET ON THE INSTANCE**

## Download data <a name="downloaddata"/>

Now that the instance is cleaned up (`BioconductorAnnotationPipline/` - 141G) and the `R` version is updated it is time to start downloading the data needed to create the packages. This can be done by running the command:

```sh
sh src_download.sh
```

The `src_download.sh` script is the 'master' script which calls all data-specific (e.g., go, gene, ensembl, ...) `download.sh` scripts. It's best to run one data type at a time and comment out the rest. If a data type completes, confirm new data have been downloaded in the data-specific directory. If no new data were downloaded, check the timestamp on web site against the `*SOURCEDATE` variable in data-specific `env.sh`. 
## Parse data <a name="parsedata"/>


## Build data <a name="builddata"/>


## Additional scripts <a name="additionalscripts"/>


## Build db0 packages <a name="builddb0pkgs"/>


## Build OrgDb, PFAM.db, and GO.db packages <a name="buildmanypkgs"/>


## Build TxDb packages <a name="buildtxdbpkgs"/>


## Where do they belong? <a name="where"/>


## Clean up <a name="cleanup"/>


## Troubleshooting <a name="troubleshooting"/>


# BioconductorAnnotationPipeline
Code to build Bioconductor annotation packages. See the [wiki](https://github.com/Bioconductor/BioconductorAnnotationPipeline/wiki) for more details.
