#!/bin/bash
sudo start-stop-daemon -SbCvm --pidfile vail.pid -x ~/vail s3 start >vail.`date +"%Y-%m-%d_%H-%M-%S"`.log 2>&1
[ "${migrate_start}" == "true" ] && touch vail.migrate
if [ -f vail.migrate ] ; then
    sudo start-stop-daemon -SbCvm --pidfile vail-migrate.pid -x ~/vail migrate start >vail.migrate.`date +"%Y-%m-%d_%H-%M-%S"`.log 2>&1
fi

