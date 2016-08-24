#!/bin/bash
service sshd start

export KYLIN_HOME=/usr/local/kylin

$KYLIN_HOME/bin/kylin.sh stop

$KYLIN_HOME/bin/kylin.sh start

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
