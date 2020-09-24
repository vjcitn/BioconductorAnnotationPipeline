#!/bin/sh
set -e
export PLASMOSOURCEDATE=2020-Aug19
export PLASMOSOURCENAME="Plasmo DB"
export PLASMOSOURCEURL="http://plasmodb.org/common/downloads/Current_Release/Pfalciparum3D7/txt"
## FIXME
## This is really convoluted and probably fragile
export FILE=`curl -s -L  $PLASMOSOURCEURL | grep "GeneAlias" | grep -o -E 'href="([^"#]+)"' | sed 's/href=//g' | cut -d'"' -f 2`


