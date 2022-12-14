# DIY Security Cam

This is a project to tie together tools that allow a Linux machine to become a DIY security camera. You can use anything from a laptop camera to a USB webcam to an IP security camera as the source. It supports multiple cameras, and currently will upload sections of the video containing significant motion to a cloud storage location.

# Structure

There is very little rocket science here. 

We use ffmpeg to record the video stream from the camera source(s). We tell ffmpeg to segment the stream, meaning that every N seconds it will dump out a new video file.

We watch for new segments being dumped out, and then run dvr-scan, an open source Python package, which looks for motion in the video that we just captured. We can configure how many seconds of motion constitutes an event worth paying attention to; this will need to be tuned, as it will vary tremendously based on what your camera is pointed at. dvr-scan will dump out a separate video per sequence of motion in the segment video.

Finally, we clean up the source segment video, and do something with the motion sequence videos that we just produced. Typically, we may want to upload the event cameras to the cloud (backblaze is implemented) for offsite backup; we may want to trigger notifications based on certain conditions (although if motion is expected, then probably not.)

# To Run

* Run setup.sh, and follow instructions

* Enter parameters enter diycam.config - at minimum, directories to use, and locations of your camera(s)

* Run ./streams.sh to start recording your camera streams

* Run ./segmenter.sh to watch for segments to be produced and kick off processing

* Run ./uploader.sh to upload motion events to backblaze

# Needs

To be a robust solution, at least the following needs to be done:

a) Turn this into a supervisor controlled service, so that if it crashes for whatever reason it restarts.

b) Make this resilient to network outages; i.e. dump events to be uploaded into a separate folder, and have a separate job responsible for uploading from that folder.

# Possibilities

* It should be possible to add tesseract OCR for license plate scanning. This could be enabled/disabled per source.

* Add a very simple UI, and package everything together to be more easily installable.

* Detect network cameras.

* Detect USB cameras.

* Motion boundaries within streams, a la ZoneMinder?

* Machine learning for what types of events we care about, vs what kinds we don't?? (ImageAI looks promising here, but not yet implemented).


