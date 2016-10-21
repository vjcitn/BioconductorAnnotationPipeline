## db0 pacakges must be generated and installed before creating OrgDb, ChipDb, etc.

library(AnnotationForge)
outDir = "./20161013_DB0s"
if (!file.exists(outDir)) 
    dir.create(outDir)

## Create db0s:
version <- "3.4.1" 
dbPath = "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/BioconductorAnnotationPipeline/annosrc/db/"
wrapBaseDBPackages(dbPath=dbPath, destDir=outDir, version=version)
