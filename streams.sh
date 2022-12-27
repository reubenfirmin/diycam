#!/bin/bash

. ./diycam.config

# for each declared camera, record the video stream and write segments
for camera in ${!cameras[@]}; do
	camera_ip=${cameras[$camera]}
	ffmpeg -hwaccel cuda -rtsp_transport tcp -i rtsp://$camera_creds@$camera_ip/video/1 -map 0 -c:v libx264 -reset_timestamps 1 -f segment -segment_time 300 -segment_list ${monitor_dir}/segments$camera.txt &
done
