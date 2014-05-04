#!/bin/bash
export HOME=/root
#. /opt/dep/firstry.sp
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=
role=

while getopts u:p:k:g:r: opt
do
	case $opt in
		u)	buser=$OPTARG;;
		p)	bpwd=$OPTARG;;
		k)	userpem=$OPTARG;;
		g)	giturl=$OPTARG;;
		r)      role=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

if [ -e buser.txt ]
then
        $current_buser=`cat buser.txt`
else
        $current_buser="notset";
fi

echo $role > role.txt
echo $giturl > giturl.txt
echo $buser > buser.txt
echo $bpwd > bpwd.tt
echo $userpem > userpem.pem

#register bitbucket key if not register yet
if [ -e /root/.ssh/gitkey ] && [ "$current_buser" == "$buser" ]
then
        echo "ssh key already registered ,skip register step" >> /var/log/deploy.log
else
	#Remove old key if any
	rm -f /root/.ssh/gitkey
	rm -f /root/.ssh/gitkey.pub
	
	#Generate new key
        ssh-keygen -N '' -f gitkey
        cp gitkey /root/.ssh/
        cp gitkey.pub /root/.ssh/
        chmod 600 /root/.ssh/gitkey /root/.ssh/gitkey.pub
#register with bitbucket
        php register.php $buser $bpwd
        rm -f gitkey gitkey.pub
fi

#mv key to chef workstation

	cat /root/.ssh/gitkey > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.erb
	cat /root/.ssh/gitkey.pub > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.pub.erb
	echo "" > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/known_hosts.erb

#replace xxxxxxxx with git url
#Remove the line with xxxxxxxx, and replace giturl for cater re-run of deploy
sed -i "/gitrepo/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
export TEMP=`cat /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb|grep localsourcefolder`
sed -i "/localsourcefolder/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
echo 'default[:deploycode][:gitrepo] = "'$giturl'"' >> /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
echo $TEMP >>/home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb

#prepare pem
mkdir -p /home/ec2-user/.pem
#echo $userpem > /home/ec2-user/.pem/drucloud.pem
mv  /home/ec2-user/drucloud.pem /home/ec2-user/.pem/drucloud.pem
chmod 600 /home/ec2-user/.pem/drucloud.pem
chown root:root /home/ec2-user/.pem/drucloud.pem 


echo "knife[:ssh_user] = 'ec2-user'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb
echo "knife[:identity_file] = '/home/ec2-user/.pem/drucloud.pem'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb

echo "configure knife ssh success"
	
#update all chef-client using knife

cd /home/ec2-user/chef11/chef-repo
/opt/chef-server/embedded/bin/knife cookbook upload deploycode
/opt/chef-server/embedded/bin/knife ssh "role:$role" "sudo chef-client -o 'recipe[deploycode]'"
