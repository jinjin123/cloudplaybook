#!/bin/bash
# This script is running by crontab to clear the dummy node exists in chef-server after auto-scaling

source /root/.bashrc
cd /home/ec2-user/chef12
NODE_LIST=`/usr/bin/knife node list`

for x in $NODE_LIST
do
echo $x
/usr/bin/knife ssh "name:*" "echo \"exists!\"" > /tmp/check_chef.txt
if [ ! `cat /tmp/check_chef.txt|grep exists|wc -l` -eq 1 ];
then
echo $x
#/usr/bin/knife node delete $x -y
fi
done

#if [ -f /tmp/check_chef.txt ];
#then
#  rm /tmp/check_chef.txt
#fi
