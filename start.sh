#!/bin/sh
sudo start-stop-daemon -SbCvm --pidfile vail.pid -x ~/vail s3 start >vail.`date +"%Y-%m-%d_%H-%M-%S"`.log 2>&1

