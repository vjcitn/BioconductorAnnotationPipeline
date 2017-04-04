#!/bin/sh
set -e

SRC_BASE=`pwd`

# NOTE: Valerie does not use this script. It is not well documented
# exactly which dbs are build in the parse stage and moved to db/.
# If you remove an essential db from db/ you need to re-run all
# parse scripts.

# this script is used before src_build.sh to clean
# out the old crufty DBs inside of ./db
# this is important so I am automating this step

# NOTE IT IS MAY NOT BE A GOOD IDEA TO REMOVE 
# the genesrc etc files since these are
# NEEDED by the steps in build (and made by parse) so if you must clean those,
# THEN DO IT in the prev step.

# HOWEVER, these files *should* NORMALLY be copied in fresh by the getdb script
# so just REMEMBER to comment out this script when re-running segments of the
# parse script (instead of the whole thing)



cd $SRC_BASE/db
rm -f chipmapsrc_*
rm -f chipsrc_*
rm -f hom.*
rm -f genesrc.sqlite
rm -f GO.sqlite
rm -f GO_ORGANISM_SPEC.sqlite
rm -f megaGO.sqlite
rm -f plasmoDBSrc.sqlite
rm -f gosrc.sqlite
rm -f gpsrc.sqlite
rm -f humanCHRLOC.sqlite
rm -f mouseCHRLOC.sqlite
rm -f ratCHRLOC.sqlite
rm -f YEAST.sqlite
rm -f KEGG.sqlite
rm -f keggsrc.sqlite
rm -f gpsrc.sqlite
rm -f ipisrc.sqlite
rm -f chrlength.sqlite


cd $SRC_BASE
