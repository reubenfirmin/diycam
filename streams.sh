#!/bin/bash

. ./diycam.config

# ffmpeg can die if there is corruption from the camera; if that happens, restart it
keep_alive() {
	camera=$1
        camera_input=${cameras[$camera]}

	# TODO not sure how universal this is
	if [[ $camera_input == *"rtsp"* ]]; then
		transport_option="-rtsp_transport tcp"
	fi

	while true; do
		ffmpeg $transport_option -i $camera_input -map 0 -c:v h264 -preset:v ultrafast -reset_timestamps 1 -f segment -segment_time $segment_length -strftime 1 $monitor_dir/cam${camera}_%Y%m%d_%H%M%S.mp4
	done
}

# for each declared camera, record the video stream and write segments
for camera in ${!cameras[@]}; do
        keep_alive $camera &
	sleep $stream_offset 
done

