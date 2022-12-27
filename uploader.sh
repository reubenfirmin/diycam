#!/bin/bash

. ./diycam.config

while true; do
     for file in `find $upload_dir -type f`; do
             filename=`basename $file`
	     env/bin/b2 upload-file --quiet $bucket $file $filename > /dev/null || exit 1
	     rm $file
     done
     sleep 10
     echo -n .
done
