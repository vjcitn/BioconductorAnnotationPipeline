#!/bin/sh
set -e
if [ "$GOEXTSOURCEDATE" = "" ]; then
  . ./env.sh
fi

## unpack source data
cd ../$GOEXTSOURCEDATE
sed -i -e "/^!/ {d}" ec2go
sed -i -e "s/ > [^;]* ; / /g" ec2go

## create source sqlite db
rm -f ec2gosrc.sqlite
sqlite3 -bail ec2gosrc.sqlite < ../script/srcdb.sql

## record data download date
echo "INSERT INTO metadata VALUES('GOEXTSOURCEDATE', '$GOEXTSOURCEDATE');" > temp_metadata.sql
echo "INSERT INTO metadata VALUES('GOEXTSOURCENAME', '$GOEXTSOURCENAME');" >> temp_metadata.sql
echo "INSERT INTO metadata VALUES('GOEXTSOURCEURL', '$GOEXTSOURCEURL');" >> temp_metadata.sql
sqlite3 -bail ec2gosrc.sqlite < temp_metadata.sql
rm -f temp_metadata.sql

