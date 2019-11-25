## db0 packages must be generated and installed before creating OrgDb, ChipDb, etc.
.libPaths("~/R-3.6.1")
library(AnnotationForge)
outDir = "./20191021_DB0s"
if (!file.exists(outDir)) 
    dir.create(outDir)

## Create db0s:
version <- "3.10.1"
dbPath = "/home/ubuntu/BioconductorAnnotationPipeline/annosrc/db/"
wrapBaseDBPackages(dbPath=dbPath, destDir=outDir, version=version)
