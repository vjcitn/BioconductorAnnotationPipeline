#!/bin/sh
# set -e

## Run this each time new packages are generated.
R --slave < updateMapCounts.R
R --slave < compareDates.R
