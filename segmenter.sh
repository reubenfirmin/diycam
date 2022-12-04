#!/bin/bash

. ./diycam.config
echo watching ${monitor_dir}/segments.txt

while true; do
       	inotifywait ${monitor_dir}/segments.txt -e modify	
        segment=$( tail -n 1 ${monitor_dir}/segments.txt )
        echo found $segment
        if [ -n "$segment" ]; then
		segmentdir=${monitor_dir}/$segment-events
                mkdir $segmentdir
		echo "env/bin/dvr-scan -i ${monitor_dir}/$segment -m ffmpeg -l ${sensitivity}s -tb ${sensitivity}s -d $segmentdir"
                env/bin/dvr-scan -i ${monitor_dir}/$segment -m ffmpeg -l ${sensitivity}s -tb ${sensitivity}s -d $segmentdir || exit 1
		# upload event videos, extract thumbnails
                for file in `find $segmentdir -type f`; do
			echo processing $file
			filename=`basename $file`
			thumbnailname=${filename}_thumbnail.jpg
			# XXX need better way of including sensitivity here
			echo "ffmpeg -i $file -ss 00:00:0$sensitivity -frames:v 1 $segmentdir/${thumbnailname}"
			ffmpeg -i $file -ss 00:00:0$sensitivity -frames:v 1 $segmentdir/${thumbnailname} || exit 1
                        env/bin/b2 upload-file $bucket $file $filename || exit 1
                        env/bin/b2 upload-file $bucket $segmentdir/$thumbnailname $thumbnailname || exit 1
                done
                rm -fr $segmentdir
                rm ${monitor_dir}/$segment
                echo Processed $segment
                echo 'new' > ${monitor_dir}/segments.txt
        fi
done
echo hello

