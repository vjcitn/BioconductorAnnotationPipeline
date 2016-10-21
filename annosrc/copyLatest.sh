#!/bin/sh
#set -e

## Copy select dbs to newPipe/ and insert schema version.

BASEVERSION=2.1

COPYFROM=/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/BioconductorAnnotationPipeline/annosrc/db/
COPYTO=/home/ubuntu/cpb_anno/AnnotationBuildPipeline/annosrc/BioconductorAnnotationPipeline/newPipe/sanctionedSqlite

cp ${COPYFROM}GO.sqlite ${COPYTO}
cp ${COPYFROM}PFAM.sqlite ${COPYTO}
cp ${COPYFROM}KEGG.sqlite ${COPYTO}
cp ${COPYFROM}YEAST.sqlite ${COPYTO}

cd ${COPYTO}
for file in `ls *.sqlite`
do
 echo "INSERT INTO metadata VALUES('DBSCHEMAVERSION', '$BASEVERSION');" > temp_metadata.sql
 sqlite3 -bail $file < temp_metadata.sql
 rm -f temp_metadata.sql
done
