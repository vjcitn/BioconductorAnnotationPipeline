#!/bin/sh
set -e

sh src_download.sh;
sh src_parse.sh;
sh src_build.sh;
sh update_individual.sh;
