
.libPaths("~/R-3.6.1")
library(InparanoidBaseBuilder)
debug(InparanoidBaseBuilder:::makeINP_DB)
debug(InparanoidBaseBuilder:::popInpTab)

makeDBs(dataDir = ".",
        metaDir = "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db")




