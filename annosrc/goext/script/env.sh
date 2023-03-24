#!/bin/sh
set -e
export GOEXTSOURCEDATE=2023-Jan01
export GOEXTSOURCENAME="Gene Ontology External Link"
export GOEXTSOURCEURL="ftp://ftp.geneontology.org/pub/go/external2go"
## The above URL times out and may be busted now?
## For 3.13 I just went to the general GO archive at
## release.geneontology.org/2021-02-01/ontology/external2go/
## and downloaded by hand.
## if this issue persists, then we may need to programmatically access the release dir instead...
