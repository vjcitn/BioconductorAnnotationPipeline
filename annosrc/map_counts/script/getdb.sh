#!/bin/sh
# set -e


##The following should get run each time that we make new packages.

R --slave < updateMapCounts.R

##You may need to not copy this into the ../../db if you are just testing the scripts, but normally you will want to. 
cp map_counts.sqlite ../../db


##Only check in the map_counts.sqlite once you have a record to preserve for next time.


