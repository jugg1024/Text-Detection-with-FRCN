#!/bin/bash

# example Usage: ./fetch_dataset.sh coco-text

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $DIR

#checking md5sum
checkmd5sum() {
  os=`uname -s`
  if [ "$os" = "Linux" ]; then
    checksum=`md5sum $DDIR/$FILE | awk '{ print $1 }'`
  elif [ "$os" = "Darwin" ]; then
    checksum=`cat $DDIR/$FILE | md5`
  fi
  if [ "$checksum" = "$CHECKSUM" ]; then
    echo "Checksum is correct. No need to download."
    DOWNLOAD="no"
  else
    echo "Checksum is incorrect. Need to download again."
    DOWNLOAD="yes"
  fi
}

#checking file exist
checkfile() {
  if [ -f $DDIR/$FILE ]; then
    echo "File already exists."
    if [ "$CHECKSUM" = "nocheck" ]; then
      echo "File is too large. No check is applyed."
      DOWNLOAD="no"
    else
      echo "Checking md5..."
      checkmd5sum
    fi
  fi
}

#download and unzip file
download_file() {
  DDIR=$1
  FILE=$2
  URL=$3
  CHECKSUM=$4
  TYPE=$5
  DOWNLOAD="yes"
  checkfile
  if [ "$DOWNLOAD" = "yes" ]; then
    echo "Downloading $FILE..."
    wget $URL -O $DDIR/$FILE
      echo "Unzipping..."
    cd $DDIR
    if [ "$TYPE" = "zip" ]; then
      unzip $FILE
    elif [ "$TYPE" = "tar" ]; then
      tar zxvf $FILE
    fi
    cd ..    
    echo "Done. Please run this command again to verify that checksum = $CHECKSUM."
  fi
}

if [ "$1" = "coco-text" ]; then
  download_file $1 COCO_Text.zip https://s3.amazonaws.com/cocotext/COCO_Text.zip 5cecfc1081b2ae7fdea75e6c9a9dec3b zip
  download_file $1 train2014.zip http://msvocds.blob.core.windows.net/coco2014/train2014.zip nocheck zip
elif [ "$1" = "hust-tr400" ]; then
  download_file $1 HUST-TR400.zip http://mc.eistar.net/UpLoadFiles/dataset/HUST-TR400.zip f11d974da7f39c7d09addb750baa4e1a zip
fi