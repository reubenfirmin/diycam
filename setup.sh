#!/bin/bash

virtualenv env
env/bin/pip install -r requirements.txt
cp diycam.config.sample diycam.config

echo Please do the following to complete setup:
echo 1: make a directory for videos to be created in (the "monitor dir")
echo 2: create a backblace account
echo 3: create a bucket in backblaze, and set up an expiry (e.g. 10 days)
echo 4: create an application key, and give it write only access to the bucket you just created
echo 5: edit diycam.config, and customize with bucket and monitor dir
echo 6: run: env/bin/b2 authorize-account, and plug in the application key
