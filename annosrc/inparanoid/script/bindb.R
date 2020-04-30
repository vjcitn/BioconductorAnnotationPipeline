
.libPaths("~/R-libraries")
library(InparanoidBaseBuilder)
debug(InparanoidBaseBuilder:::makeINP_DB)
debug(InparanoidBaseBuilder:::popInpTab)

makeDBs(dataDir = ".",
        metaDir = "/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/db")




