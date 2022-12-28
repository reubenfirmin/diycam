#!/bin/bash

. ./diycam.config
mkdir -p $upload_dir

# monitor a directory for new files with a given pattern being written; we avoid touching the most recent file, since ffmpeg is likely writing to it
segmenter() {
	camera=$1
	echo watching $monitor_dir/$camera
	while true; do
		# get all but the last file (which we presume ffmpeg to be processing)
		files=($monitor_dir/cam${camera}_*)
		numfiles=${#files[@]}
		if (( $numfiles >= 1 )); then
			unset files[-1]
		fi	
		# process each of the files we found
		for file in ${files[@]}; do
			segment=`basename $file`
        		echo found $segment
	     		if [ -n "$segment" ]; then
				process_segment $segment || echo "Processing $segment failed"
			else 
				break
        		fi
		done
		# pause and let another camera's output be processed
		sleep 30
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
	segmenter $camera &
done
