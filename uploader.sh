#!/bin/bash

. ./diycam.config

while true; do
     date=$(date '+%Y%m%d')     
     for file in `find $upload_dir -type f`; do
             filename=`basename $file`
	     cam=`echo $filename | cut -d "_" -f 1`
	     path=$date/$cam/$filename
	     echo $path
	     env/bin/b2 upload-file --quiet $bucket $file $path > /dev/null || exit 1
	     rm $file
     done
     sleep 10
     echo -n .
done
