#!/bin/bash
host=
pem=
user=ec2-user
cmd=
userpem=
buser=
bpwd=
giturl=
rolename=
while getopts h:u:p:c:v:m:n:g:r: opt
do 
	case $opt in
		h)	host=$OPTARG;;
		u)	user=$OPTARG;;
		p)	pem=$OPTARG;;
		c)	cmd=$OPTARG;;
		m)	buser=$OPTARG;;
		n)	bpwd=$OPTARG;;
		g)	giturl=$OPTARG;;
		r)	rolename=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

echo $pem > temp.pem
chmod 400 temp.pem
#chown -R webapp:webapp temp.pem
ssh -i temp.pem -t -o 'StrictHostKeyChecking no' $user@$host "sudo bash /opt/dep/deploycode.sh -u $buser -p $bpwd -k $userpem -g $giturl -r $rolename"

chmod 755 temp.pem
rm -rf temp.pem


