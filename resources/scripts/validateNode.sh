#!/bin/bash

cd /home/ec2-user/chef11/chef-repo
nodes=$( /opt/chef-server/bin/knife node list )
for var in $nodes
do
	
	/opt/chef-server/bin/knife ssh name:${var} 'ls' > /home/ec2-user/chef11/sshlog 2>&1
	sshResult=$(cat /home/ec2-user/chef11/sshlog)
	isSubstring=$(echo $sshResult | grep 'Failed' ) 
	isSubstring2=$(echo $sshResult | grep 'FATAL')
	#check1=$(expr index $sshResult 'Failed')
	#check2=$(expr index $sshResult 'Fatal')
	#echo $check1$check2
	if [[ "$isSubstring" != "" ]] || [[ "$isSubstring2" != "" ]]
	then 
		echo $var failed to check in,trying to remove it...
		cd /home/ec2-user/chef11/chef-repo
		/opt/chef-server/bin/knife node delete -y -V ${var}
		echo remove ${var} succeed!
		/opt/chef-server/bin/knife client delete -y -V ${var}
	fi
done

