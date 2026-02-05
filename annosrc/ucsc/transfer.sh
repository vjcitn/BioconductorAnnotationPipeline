# this script transfers legacy ucsc components that were not obtained via rsync
# so that getsrc.sh can work

# mouse has a cytoBandIdeo that is peculiar
# pig does not seem to have knownToLocusLink or cytoBand?

cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/anopheles/current/cytoBand.txt.gz  anopheles/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/anopheles/current/knownToLocusLink.txt.gz  anopheles/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/anopheles/current/refGene.txt.gz anopheles/current

cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/bovine/current/cytoBand.txt.gz bovine/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/bovine/current/knownToLocusLink.txt.gz bovine/current

cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/canine/current/cytoBand.txt.gz canine/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/canine/current/knownToLocusLink.txt.gz canine/current

ORG=chicken
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current
ORG=chimp
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current
ORG=fish
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current
ORG=fly
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current

ORG=mouse
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/refGene.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBandIdeo.txt.gz $ORG/current

ORG=rat
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current

ORG=rhesus
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current

ORG=worm
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current

ORG=yeast
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/cytoBand.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/knownToLocusLink.txt.gz $ORG/current
cp ~/AnnotationWorkflow/legacy_ucsc_txt/UNZIPPED/$ORG/current/refGene.txt.gz $ORG/current
