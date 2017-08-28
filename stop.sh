#!/bin/bash
sudo start-stop-daemon --pidfile vail.pid -K
if [ -f vail.migrate ] ; then
    sudo start-stop-daemon  --pidfile vail-migrate.pid -K
fi

