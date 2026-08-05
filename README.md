# Building GO.db

This repository contains the scripts used to assemble the SQLite inputs and package sources needed to create `GO.db` for Bioconductor.

The current refactor organizes the work into three stages:

1. `download` fetches upstream source data.
2. `model` parses those sources and builds canonical SQLite intermediates under `annosrc/db/`.
3. `package` generates package source trees in `newPkgs/`.

`GO.db` is the first package flow documented against that staged layout.

## What `make GO.db` does

The top-level Makefile exposes the documented entry points:

```sh
make help
make download
make download-ucsc
make model
make model-parse
make model-build
make model-parse-ucsc
make model-build-go-db2
make package PKG_DATE=20260805 PKG_VERSION=3.23.0
make GO.db PKG_DATE=20260805 PKG_VERSION=3.23.0
```

`make GO.db` is an alias for the current OrgDb-family packaging flow. That flow creates the `GO.db` package source tree together with the other OrgDb outputs emitted by `newPkgs/makeTerminalDBPkgs.R`.

The target does not currently produce an installed package by itself. It stops after generating the package source directories under `newPkgs/<PKG_DATE>_OrgDbs/`. You still need to run `R CMD build`, `R CMD check`, and `R CMD INSTALL` on the generated `GO.db` package.

The `download` stage is now stamped per source. If one upstream source fails, rerunning `make download` resumes at the first unfinished source instead of rerunning the entire download stage. You can also run a single source explicitly, for example:

```sh
make download-ucsc
```

The `model` stage is also stamped per source for both parse and build sub-stages. If one model source fails, rerunning `make model` resumes from the first unfinished source. You can run targeted model sources with:

```sh
make model-parse-ucsc
make model-build-go-db2
```

## Prerequisites

You need a machine with enough disk for the raw downloads and intermediate databases. The historical pipeline notes suggest planning for well over 100GB.

You also need the following tools available on `PATH`:

- `make`
- `sh`
- `sqlite3`
- `R`
- `Rscript`

The R installation needs Bioconductor packages required by the legacy parsing and packaging scripts. At minimum, the current notes and scripts reference these packages:

- `BiocManager`
- `AnnotationDbi`
- `AnnotationForge`
- `GSEABase`
- `dplyr`
- `stringi`
- `graph`
- `RBGL`
- `tidyr`

The package stage also expects an installed `AnnotationForge` tree with an editable `ANNDBPKG-INDEX.TXT`. By default, the pipeline looks for that file here:

```sh
$HOME/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT
```

If your `AnnotationForge` installation lives elsewhere, override it when invoking `make`:

```sh
make GO.db ANNOTATIONFORGE_INDEX=/path/to/ANNDBPKG-INDEX.TXT
```

## Repository layout relevant to GO.db

- `annosrc/src_download.sh` drives the raw data acquisition stage.
- `annosrc/src_parse.sh` parses downloaded sources into intermediate files.
- `annosrc/src_build.sh` builds the SQLite databases consumed by the package step.
- `annosrc/copyLatest.sh` copies selected SQLite products into `newPkgs/sanctionedSqlite/` and adds `DBSCHEMAVERSION` metadata.
- `newPkgs/fixAnnoFile.sh` rewrites the installed `AnnotationForge` package index to use the current version and sanctioned SQLite directory.
- `newPkgs/makeDbZeros.R` creates the db0 package sources required before OrgDb-family package generation.
- `newPkgs/makeTerminalDBPkgs.R` generates the `GO.db`, `PFAM.db`, `Orthology.eg.db`, and `org.*.db` package source trees.

## End-to-end process

### 1. Clone the repository

```sh
git clone https://github.com/Bioconductor/BioconductorAnnotationPipeline.git
cd BioconductorAnnotationPipeline
```

If you are testing a feature branch, check out that branch before building.

### 2. Build the raw and modeled inputs

Run the staged pipeline through the model step:

```sh
make download
make model
```

This drives the existing shell scripts in `annosrc/` and leaves the modeled SQLite outputs in `annosrc/db/`.

If you want a single visible entry point for the packaging-oriented flow, `make GO.db` also depends on these stages and will run them automatically when their stage stamps are missing.

If a download fails partway through, fix the source-specific problem and rerun either `make download` or the corresponding `make download-<source>` target. The same resume behavior applies to the model stage via `make model` and `make model-<substage>-<source>`.

### 3. Build the db0 prerequisite packages

The current pipeline still requires the db0 package family to be generated and installed before the OrgDb-family packaging step. That requirement comes directly from `newPkgs/makeTerminalDBPkgs.R`, which starts with this note:

```r
## NOTE: Install new db0 packages before running this script.
```

At the moment, `newPkgs/makeDbZeros.R` still contains hard-coded values for the output directory, version, and `annosrc/db/` path. Before running it, update these values so they match your checkout and target Bioconductor version.

The script currently looks like this at the top level:

```r
.libPaths("~/R-libraries")
library(AnnotationForge)
outDir = "./20240923_DB0s"
version <- "3.20.0"
dbPath = "/home/ubuntu/BioconductorAnnotationPipeline/annosrc/db/"
wrapBaseDBPackages(dbPath=dbPath, destDir=outDir, version=version)
```

After editing those values, run:

```sh
cd newPkgs
R --slave < makeDbZeros.R
```

Then build, check, and install the generated db0 packages before moving on. `GO.db` generation depends on those packages already being available to R.

### 4. Generate the GO.db package sources

Once the modeled SQLite databases exist and the db0 packages are installed, run the packaging target:

```sh
make GO.db PKG_DATE=20260805 PKG_VERSION=3.23.0
```

That target currently performs these steps:

1. Rewrites the installed `AnnotationForge` index using `newPkgs/fixAnnoFile.sh`.
2. Copies `GO.sqlite`, `PFAM.sqlite`, `KEGG.sqlite`, `YEAST.sqlite`, and `Orthology.eg.sqlite` into `newPkgs/sanctionedSqlite/` using `annosrc/copyLatest.sh`.
3. Creates the `org.*.sqlite` intermediates in `newPkgs/sanctionedSqlite/` by sourcing `newPkgs/EGPkgs.R` from `newPkgs/makeTerminalDBPkgs.R`.
4. Generates the package source directories in `newPkgs/<PKG_DATE>_OrgDbs/`.

The generated `GO.db` package source tree will be here:

```sh
newPkgs/<PKG_DATE>_OrgDbs/GO.db
```

### 5. Build, check, and install GO.db

From the package output directory, build and validate the package in the normal R package toolchain:

```sh
cd newPkgs/20260805_OrgDbs
R CMD build GO.db
R CMD check GO.db_3.23.0.tar.gz
R CMD INSTALL GO.db_3.23.0.tar.gz
```

Adjust the version in the tarball name if you are building a different Bioconductor release.

Historically the pipeline built and installed `GO.db` before continuing with the other OrgDb outputs. That remains a sensible order if you are debugging packaging issues.

### 6. Smoke test the installed package

At minimum, verify that the package installs and loads:

```sh
R -q -e 'library(GO.db)'
```

If you want a slightly stronger check through the supported accessor layer, you can also exercise `AnnotationDbi` against the installed package:

```sh
R -q -e 'library(GO.db); library(AnnotationDbi); print(head(keys(GO.db, keytype = "GOID")))'
```

## Useful variables

The Makefile accepts these overrides for the GO.db flow:

- `PKG_DATE`: names the package output directory under `newPkgs/`
- `PKG_VERSION`: version string passed to the package-generation wrapper
- `ANNOTATIONFORGE_INDEX`: path to `ANNDBPKG-INDEX.TXT`
- `RSCRIPT_BIN`: alternate `Rscript` executable if needed
- `SANCTIONED_SQLITE_DIR`: alternate location for the copied packaging SQLite files

Example:

```sh
make GO.db \
	PKG_DATE=20260805 \
	PKG_VERSION=3.23.0 \
	ANNOTATIONFORGE_INDEX=$HOME/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT
```

## Cleaning generated outputs

To remove Make stage stamps and the package outputs for the selected `PKG_DATE`, run:

```sh
make clean PKG_DATE=20260805
```

This also removes `newPkgs/sanctionedSqlite/`, so do not use it if you need to inspect those copied SQLite intermediates.

## Current limitations

- `make GO.db` wraps the existing OrgDb-family packaging script; it does not yet isolate `GO.db` as a standalone package-generation job.
- The db0 prerequisite is still manual. `newPkgs/makeDbZeros.R` needs local edits before it can be run in a fresh checkout.
- The pipeline still depends on legacy scripts and external data sources that may require manual intervention when upstream URLs or file formats change.

## Related design notes

The staged build layout and package-interface direction for this refactor are documented in `docs/adr/`:

- `docs/adr/0001-build-boundaries.md`
- `docs/adr/0002-annotationdbi-interface.md`
- `docs/adr/0003-makefile-orchestration.md`
- `docs/adr/0004-environment-deprecation.md`
