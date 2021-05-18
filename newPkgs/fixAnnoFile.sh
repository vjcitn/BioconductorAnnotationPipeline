#1/bin/bash


if [ $# -eq 0 ]
  then
      echo "Please include a version number (e.g., 3.12.0) when calling this script!"
      exit 1
fi

version=$1

sed -i "s/3.10.0/$version/g" \
    ~/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT

sed  's/newPipe/newPkgs/g' \
~/R-libraries/AnnotationForge/extdata/GentlemanLab/ANNDBPKG-INDEX.TXT \
| sed \
      's|cpb_anno/AnnotationBuildPipeline/newPkgs/old_code/2015.10.07|BioconductorAnnotationPipeline/newPkgs/sanctionedSqlite|g' \
      > ANNDBPKG-INDEX.TXT
mv ANNDBPKG-INDEX.TXT ~/R-libraries/AnnotationForge/extdata/GentlemanLab/
