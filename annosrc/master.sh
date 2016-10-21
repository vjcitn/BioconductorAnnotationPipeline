#!/bin/sh
set -e

## Reccomend running individually vs all at once ...
sh src_download.sh;
sh src_parse.sh;
sh src_build.sh;
