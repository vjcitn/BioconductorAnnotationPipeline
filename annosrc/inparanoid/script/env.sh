#!/bin/sh
set -e
#HVM is human vs mouse etc.
export IPHVMSOURCEDATE=29-Apr-2008
export IPSOURCENAME="Inparanoid Orthologs"
export IPSOURCEURL="http://inparanoid.sbc.su.se/download/current/sqltables/"

# #FOR NOW, we want to place the ensembl and flybase sources here where they are used,
# #BUT these might be moved someday, so I will try to keep things insulated
# export ENSOURCEDATE=
# export ENSOURCENAME="Ensembl"
# export ENSOURCEURL="ftp://ftp.ensembl.org/pub/current_fasta"

export FBSOURCEDATE=2025-May
export FBSOURCENAME="Flybase"
export FBSOURCEURL="ftp://ftp.flybase.net/releases/current/precomputed_files/genes/"
export FBSOURCEURL="https://s3ftp.flybase.org/releases/current/precomputed_files/genes/"
export FILE=`curl --fail -s -L $FBSOURCEURL | grep "fbgn_fbtr_fbpp_fb" | awk '{print $NF}'`

export FILE=https://s3ftp.flybase.org/releases/current/precomputed_files/genes/fbgn_fbtr_fbpp_fb_2025_05.tsv.gz
export UZFILE=`basename $FILE | sed 's/\.gz//'`
