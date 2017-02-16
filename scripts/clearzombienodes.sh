#!/bin/bash
# This script is running by crontab to clear the dummy node exists in chef-server after auto-scaling

source /root/.bashrc
cd /home/ec2-user/chef12
NODE_LIST=`/usr/bin/knife node list`
CLIENT_LIST=`/usr/bin/knife client list| grep -v admin`

for x in $NODE_LIST 
do
  echo $x
  /usr/bin/knife ssh "name:$x" "echo \"exists!\"" > /tmp/check_chef.txt
  if [ ! `cat /tmp/check_chef.txt|grep exists|wc -l` -eq 1 ];
  then
    export ADDRESS=`/usr/bin/knife node show $x -a fqdn|grep fqdn|awk {'print $2'}`
    ping -c 1 $ADDRESS >> /dev/null
    if [ $? -ne 0 ]; then    
      echo $x" does not exists! Will be removed."
      /usr/bin/knife node delete $x -y
    else
      echo $x" Ping success!"
    fi
  else
    echo $x" exists!"
  fi
done

for x in $CLIENT_LIST 
do
  echo $x
  /usr/bin/knife ssh "name:$x" "echo \"exists!\"" > /tmp/check_chef.txt
  if [ ! `cat /tmp/check_chef.txt|grep exists|wc -l` -eq 1 ];
  then
    export ADDRESS=`/usr/bin/knife node show $x -a fqdn|grep fqdn|awk {'print $2'}`
    ping -c 1 $ADDRESS >> /dev/null
    if [ $? -ne 0 ]; then
      echo $x" does not exists! Will be removed."
      /usr/bin/knife client delete $x -y
    else
      echo $x" Ping success!"
    fi
  else
    echo $x" exists!"
  fi
done

if [ -f /tmp/check_chef.txt ];
then
  rm /tmp/check_chef.txt
fi
