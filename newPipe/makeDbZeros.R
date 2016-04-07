## db0 pacakges must be generated and installed before creating OrgDb, ChipDb, etc.

library(AnnotationForge)
outDir = "./2016.03.23_DB0s"
if (!file.exists(outDir)) 
    dir.create(outDir)
metaDataSrc = "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db/metadatasrc.sqlite"

## Calls 
wrapBaseDBPackages(dbPath = sub("metadatasrc.sqlite", "", metaDataSrc),
                   destDir = outDir,
                   version = "3.3.0")
