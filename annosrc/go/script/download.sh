#!/bin/sh
set -e
. ./env.sh

LATEST=`curl --fail --silent --range 0-100 $GOSOURCEURL | head -n 2 | tail -n 1 | awk '{print $2}'`
LATEST_DATE=`basename $LATEST`
TARGET_DIR="../$LATEST_DATE"
TARGET_FILE="$TARGET_DIR/$(basename "$GOSOURCEURL")"

if [ -z "$LATEST_DATE" ]; then
       echo "download.sh: latest date from $GOSOURCEURL not found"
       exit 1
fi

if [ "$LATEST_DATE" != "$GOSOURCEDATE" ]; then
        echo "update $GOSOURCENAME from $GOSOURCEDATE to $LATEST_DATE"
        sed -i -e "s/ GOSOURCEDATE=.*$/ GOSOURCEDATE=$LATEST_DATE/g" env.sh
        mkdir -p "$TARGET_DIR"
        if [ -f "$TARGET_FILE" ]; then
                echo "$GOSOURCENAME file already present at $TARGET_FILE"
        else
                curl --fail -o "$TARGET_FILE" "$GOSOURCEURL"
        fi
else
        echo "the latest $GOSOURCENAME is still $LATEST_DATE"
        mkdir -p "$TARGET_DIR"
        if [ -f "$TARGET_FILE" ]; then
                echo "$GOSOURCENAME file already present at $TARGET_FILE"
        else
                echo "$GOSOURCENAME file missing for current date; downloading"
                curl --fail -o "$TARGET_FILE" "$GOSOURCEURL"
        fi
fi
