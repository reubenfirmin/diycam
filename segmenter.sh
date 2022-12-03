#!/bin/bash

while inotifywait -e modify segments.txt; do 
	segment=$( tail -n 1 segments.txt )
	echo found $segment
	mkdir $segment-events
	env/bin/dvr-scan -i $segment -m ffmpeg -l 3s -d $segment-events
	rm $segment
	echo Processed $segment
	echo 'new' > segments.txt
done
