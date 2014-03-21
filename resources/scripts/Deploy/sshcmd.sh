#!/bin/bash
host=
pem=
user=ec2-user
cmd=
userpem=
buser=
bpwd=
giturl=
while getopts h:u:p:c:v:m:n:g: opt
do 
	case $opt in
		h)	host=$OPTARG;;
		u)	user=$OPTARG;;
		p)	pem=$OPTARG;;
		c)	cmd=$OPTARG;;
		v)	rootDir=$OPTARG;;
		m)	druuser=$OPTARG;;
		n)	drupwd=$OPTARG;;
		g)	giturl=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

echo $pem | ssh -i /dev/stdin $user@$host "sudo bash /opt/dep/deploycode.sh -u $buser -p $bpwd -k $userpem -g $giturl"

