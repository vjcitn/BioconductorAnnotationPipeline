## This script is expecting 'outdir' and 'dbBaseDir' to be set; usually called from
## makeTerminalDBPkgs.R.

## occasionally: I get one bad gene record (null gene name in gene_info) here
cat("building FLY_DB\n")
populateDB("FLY_DB", prefix="org.Dm.eg",
         chipSrc = paste0(dbBaseDir, "chipsrc_fly.sqlite"),
         metaDataSrc = metaDataSrc,
         outputDir=outDir)

## occasionally: I get one bad gene record (null gene_id in genes) here
cat("building ARABIDOPSIS_DB\n")
populateDB("ARABIDOPSIS_DB", prefix="org.At.tair",
           chipSrc = paste0(dbBaseDir, "chipsrc_arabidopsis.sqlite"),
           metaDataSrc = metaDataSrc,
           outputDir=outDir)

## NOTE: need PFAM table
cat("building YEAST_DB\n")
populateDB("YEAST_DB", prefix="org.Sc.sgd",
           chipSrc = paste0(dbBaseDir, "chipsrc_yeast.sqlite"),
           metaDataSrc = metaDataSrc,
           outputDir=outDir)

cat("building MARLARIA_DB\n")
populateDB("MALARIA_DB", prefix="org.Pf.plasmo",
             chipSrc = paste0(dbBaseDir, "chipsrc_malaria.sqlite"),
             metaDataSrc = metaDataSrc,
             outputDir=outDir)

## ## #seed = new("AnnDbPkgSeed",Package="org.Pf.plasmo.db", Version="1.0.0", PkgTemplate="MALARIA.DB",AnnObjPrefix="org.Pf.plasmo", biocViews = "AnnotationData, Plasmodium_falciparum")
## ## #makeAnnDbPkg(seed, "org.Pf.plasmo.sqlite"), dest_dir=".")

populateDB("ZEBRAFISH_DB", prefix="org.Dr.eg",
               chipSrc = paste0(dbBaseDir, "chipsrc_zebrafish.sqlite"),
               metaDataSrc = metaDataSrc,
               outputDir=outDir)
cat("building XEBRAFISH_DB\n")

## ## ## seed = new("AnnDbPkgSeed",Package="org.Dr.eg.db", Version="1.0.0", PkgTemplate="ZEBRAFISH.DB",AnnObjPrefix="org.Dr.eg", biocViews = "AnnotationData, Danio_rerio")
## ## ## makeAnnDbPkg(seed, "org.Dr.eg.sqlite"), dest_dir=".")

cat("building ECOLIK12_DB\n")
populateDB("ECOLI_DB", prefix="org.EcK12.eg",
               chipSrc = paste0(dbBaseDir, "chipsrc_ecoliK12.sqlite"),
               metaDataSrc = metaDataSrc,
               outputDir=outDir)

## ## ## ## seed = new("AnnDbPkgSeed",Package="org.EcK12.eg.db", Version="1.0.0", PkgTemplate="ECOLI.DB",AnnObjPrefix="org.EcK12.eg", biocViews = "AnnotationData, Escherichia_coli")
## ## ## ## makeAnnDbPkg(seed, "org.EcK12.eg.sqlite"), dest_dir=".")

cat("building ECOLISaki_DB\n")
populateDB("ECOLI_DB", prefix="org.EcSakai.eg",
               chipSrc = paste0(dbBaseDir, "chipsrc_ecoliSakai.sqlite"),
               metaDataSrc = metaDataSrc,
               outputDir=outDir)

## ## ## seed = new("AnnDbPkgSeed",Package="org.EcSakai.eg.db", Version="1.0.0", PkgTemplate="ECOLI.DB",AnnObjPrefix="org.EcSakai.eg", biocViews = "AnnotationData, Escherichia_coli")
## ## ## makeAnnDbPkg(seed, "org.EcSakai.eg.sqlite"), dest_dir=".")

cat("building CANINE_DB\n")
populateDB("CANINE_DB", prefix="org.Cf.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_canine.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building BOVINE_DB\n")
populateDB("BOVINE_DB", prefix="org.Bt.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_bovine.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building WORM_DB\n")
populateDB("WORM_DB", prefix="org.Ce.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_worm.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building CHICKEN_DB\n")
populateDB("CHICKEN_DB", prefix="org.Gg.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_chicken.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building PIG_DB\n")
populateDB("PIG_DB", prefix="org.Ss.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_pig.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building CHIMP_DB\n")
populateDB("CHIMP_DB", prefix="org.Pt.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_chimp.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building RHESUS_DB\n")
populateDB("RHESUS_DB", prefix="org.Mmu.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_rhesus.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building ANOPHELES_DB\n")
populateDB("ANOPHELES_DB", prefix="org.Ag.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_anopheles.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building XENOPUS_DB\n")
populateDB("XENOPUS_DB", prefix="org.Xl.eg",
            chipSrc = paste0(dbBaseDir, "chipsrc_xenopus.sqlite"),
            metaDataSrc = metaDataSrc,
            outputDir=outDir)

cat("building HUMAN_DB\n")
populateDB("HUMAN_DB", prefix="org.Hs.eg",
           chipSrc = paste0(dbBaseDir, "chipsrc_human.sqlite"),
           metaDataSrc = metaDataSrc,
           outputDir=outDir)

cat("building MOUSE_DB\n")
populateDB("MOUSE_DB", prefix="org.Mm.eg",
           chipSrc = paste0(dbBaseDir, "chipsrc_mouse.sqlite"),
           metaDataSrc = metaDataSrc,
           outputDir=outDir)

cat("building RAT_DB\n")
populateDB("RAT_DB", prefix="org.Rn.eg",
         chipSrc = paste0(dbBaseDir, "chipsrc_rat.sqlite"),
         metaDataSrc = metaDataSrc,
         outputDir=outDir)
