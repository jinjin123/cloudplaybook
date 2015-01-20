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

#echo $role > role.txt
#echo $giturl > giturl.txt
#echo $buser > buser.txt
#echo $bpwd > bpwd.tt
#echo $userpem > userpem.pem

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
# Register key to Bitbucket
        php register.php $buser $bpwd
        rm -f gitkey gitkey.pub
fi

# Move key to chef workstation
cat /root/.ssh/gitkey > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.erb
cat /root/.ssh/gitkey.pub > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.pub.erb
echo "" > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/known_hosts.erb

# Replace the git repo entry in deploycode's Attribute
sed -i "/gitrepo/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
export TEMP=`cat /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb|grep localsourcefolder`
sed -i "/localsourcefolder/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
echo 'default[:deploycode][:gitrepo] = "'$giturl'"' >> /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
echo $TEMP >>/home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb

# Prepare pem
#mkdir -p /home/ec2-user/.pem
#echo $userpem > /home/ec2-user/.pem/drucloud.pem
#mv  /home/ec2-user/drucloud.pem /home/ec2-user/.pem/drucloud.pem
#chmod 600 /home/ec2-user/.pem/drucloud.pem
#chown root:root /home/ec2-user/.pem/drucloud.pem 

# Configure knife to access client machine
#echo "knife[:ssh_user] = 'ec2-user'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb
#echo "knife[:identity_file] = '/home/ec2-user/.pem/drucloud.pem'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb
#echo "configure knife ssh success"
	
#update all chef-client using knife

cd /home/ec2-user/chef11/chef-repo
sleep 1 
/opt/chef-server/embedded/bin/knife cookbook upload deploycode
sleep 10 
n=0;until [ $n -ge 5 ];do /opt/chef-server/embedded/bin/knife ssh "role:$role" "sudo chef-client -o 'recipe[deploycode]'"; [ $? -eq 0 ] && break;n=$[$n+1];sleep 10;done;
#n=0;until [ $n -ge 5 ];do cat /home/ec2-user/chef11/chef-repo/cookbooks/drupalsetting/templates/default/settings.php; [ $? -eq 0 ] && break;n=$[$n+1];sleep 60;done;
n=0;until [ $n -ge 5 ];do /opt/chef-server/embedded/bin/knife ssh "role:$role" "sudo chef-client -o 'recipe[drupalsetting]'"; [ $? -eq 0 ] && break;n=$[$n+1];sleep 10;done;
