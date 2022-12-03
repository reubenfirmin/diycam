#!/bin/bash

ffmpeg -f v4l2 -framerate 60 -video_size 1280x720 -input_format mjpeg -i /dev/video0 -f segment -segment_time 300 -segment_list segments.txt trig%05d.mp4
