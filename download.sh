#!/usr/bin/env bash

if [[ -z "$MAXMIND_KEY" ]]; then
  echo "MAXMIND_KEY is not found"
  exit 1
fi

FOLDER="tmp/maxmind"
FILE="$FOLDER/GeoLite2-City.mmdb.tar.gz"
TARGET_FOLDER="db/maxminddb/"

mkdir -p $FOLDER

URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&suffix=tar.gz&license_key=$MAXMIND_KEY"
  mkdir -p $TARGET_FOLDER && curl $URL -o $FILE \
  && tar xvf $FILE -C $FOLDER \
  && find $FOLDER -mindepth 2 -name "*.mmdb" -print -exec mv {} $TARGET_FOLDER \;

echo "Maxmind GeoLite2-City.mmdb was downloaded to $TARGET_FOLDER"

URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=$MAXMIND_KEY"
FILE="$FOLDER/GeoLite2-City.csv.zip"
TARGET_FOLDER="db/GeoLite2-City"

mkdir -p $TARGET_FOLDER \
  && curl $URL -o $FILE \
  && unzip $FILE -d $FOLDER \
  && find $FOLDER -mindepth 2 -name "*.csv" -print -exec mv {} $TARGET_FOLDER \;

echo "GeoLite2-City csv database was downloaded to $TARGET_FOLDER"

rm -rf $FOLDER
echo "Done!"

