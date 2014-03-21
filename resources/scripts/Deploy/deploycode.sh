#!/bin/bash
export HOME=/root
. /opt/dep/firstry.sp
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=

while getopts u:p:k:g: opt
do
	case $opt in
		u)	buser=$OPTARG;;
		p)	bpwd=$OPTARG;;
		k)	userpem=$OPTARG;;
		g)	giturl=$OPTARG;;
		*)	echo "-$opt not recognized";;
done

#register bitbucket key if not register yet
if [ -e /root/.ssh/gitkey ]
then
	echo "ssh key already registered ,skip register step" >> /var/log/deploy.log
else
	ssh-keygen -N '' -f gitkey
	cp gitkey /root/.ssh/
	cp gitkey.pub /root/.ssh/
	chmod 600 /root/.ssh/gitkey /root/.ssh/gitkey.pub

#register with bitbucket
	key=`cat /root/.ssh/gitkey.pub`
        curl --user $buser:$bpwd -d "key=$key&label=auto_genkey" https://bitbucket.org/api/1.0/users/$buser/ssh-keys
	rm -Rf /opt/dep/temp_src
	mkdir /opt/dep/temp_src
	expect ./firsttry.exp $giturl /opt/dep/temp_src	


#mv key to chef workstation

	cat /root/.ssh/gitkey > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.erb
	cat /root/.ssh/gitkey.pub > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.pub.erb
	cat /root/.ssh/known_hosts > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/known_hosts.erb
	
fi

#update all chef-client using knife

cd /home/ec2-user/chef11/chef-repo
/opt/chef-server/embedded/bin/knife cookbook upload deploycode
/opt/chef-server/embedded/bin/knife ssh "role:chefclient" "sudo chef-client -o 'recipe[deploycode]'"


















