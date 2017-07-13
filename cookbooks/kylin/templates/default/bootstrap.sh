#!/bin/bash
service sshd start

export KYLIN_HOME=/usr/local/kap

# Run once to initialize kylin
$KYLIN_HOME/bin/kylin.sh stop

$KYLIN_HOME/bin/kylin.sh start

# Creating sample cube
$KYLIN_HOME/bin/sample.sh

# if [[ $1 == "-d" ]]; then
#   while true; do sleep 1000; done
# fi
#
# if [[ $1 == "-bash" ]]; then
#   /bin/bash
# fi
