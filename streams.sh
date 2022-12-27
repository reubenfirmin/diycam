#!/bin/bash

. ./diycam.config

# ffmpeg can die if there is corruption from the camera; if that happens, restart it
keep_alive() {
	camera=$1
        camera_ip=${cameras[$camera]}
	while true; do
		ffmpeg -rtsp_transport tcp -i rtsp://$camera_creds@$camera_ip/video/1 -map 0 -c:v h264 -preset:v ultrafast -reset_timestamps 1 -f segment -segment_time 300 -strftime 1 -segment_list ${monitor_dir}/segments$camera.txt $monitor_dir/cam${camera}_out%Y%m%d_%H%M%S.mp4
	done
}

# for each declared camera, record the video stream and write segments
for camera in ${!cameras[@]}; do
        camera_ip=${cameras[$camera]}
        keep_alive camera &
	# offset streams to offset processing
	sleep 60
done

