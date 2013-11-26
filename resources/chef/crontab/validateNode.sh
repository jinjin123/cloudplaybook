#!/bin/bash

cd /home/ec2-user/chef11/chef-repo
nodes=$( /opt/chef-server/bin/knife node list )
for var in $nodes
do
	#echo $var
	/opt/chef-server/bin/knife ssh name:${var} 'ls' > /home/ec2-user/chef11/sshlog 2>&1
	sshResult=$(cat /home/ec2-user/chef11/sshlog)
	isSubstring=$(echo $sshResult | grep 'Failed' )
	if [[ "$isSubstring" != "" ]]
	then 
		echo $var failed to check in,trying to remove it...
		cd /home/ec2-user/chef11/chef-repo
		/opt/chef-server/bin/knife node delete -y -V ${var}
		echo remove ${var} succeed!
		/opt/chef-server/bin/knife client delete -y -V ${var}
	fi
done

