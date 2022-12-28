#!/bin/bash

. ./diycam.config
mkdir -p $upload_dir

# watch a segments file; on modification, process each line found in the file, removing the line once complete
# XXX potential for race condition if ffmpeg writes at the same time that we remove the first line
segmenter() {
	segmentfile=$1
	echo watching $monitor_dir/$segmentfile
	while true; do
		readarray -t segments < $monitor_dir/$segmentfile
		echo > $monitor_dir/$segmentfile
		for segment in ${segments[@]}; do
        		echo found $segment
	     		if [ -n "$segment" ]; then
				process_segment $segment || echo "Processing $segment failed"
			else 
				break
        		fi
		done
		sleep 90
	done
}

# process a segment for events; any detected motion events will be moved to the upload folder
# the original segment video is deleted
process_segment() {
	segment=$1
	segmentdir=${monitor_dir}/$segment-events
        mkdir $segmentdir
	echo "env/bin/dvr-scan -i ${monitor_dir}/$segment -m copy -l ${sensitivity}s -k 17 -tb ${sensitivity}s -d $segmentdir -b CNT"
        env/bin/dvr-scan -i ${monitor_dir}/$segment -m copy -l ${sensitivity}s -k 17 -tb ${sensitivity}s -d $segmentdir -b CNT || exit 1
        # extract thumbnails
        for file in `find $segmentdir -type f`; do
        	echo processing $file
                filename=`basename $file`
                thumbnailname=${filename}_thumbnail.jpg
		thumbnailpath=$segmentdir/$thumbnailname
                # XXX need better way of including sensitivity here
                ffmpeg -hide_banner -loglevel error -i $file -ss 00:00:0$sensitivity -frames:v 1 $thumbnailpath || exit 1
		mv $file $upload_dir
		mv $thumbnailpath $upload_dir
       	done

        mv $segmentdir/* $upload_dir
        rm -fr $segmentdir
        rm ${monitor_dir}/$segment
        echo Processed $segment
}

# kick off a segmenter per camera
for camera in ${!cameras[@]}; do
	echo $camera
	segmenter "segments$camera.txt" &
done
