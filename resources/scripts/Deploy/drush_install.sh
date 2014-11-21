#!/bin/bash
echo `date` >> /root/runtime.txt
LOG=/root/run.log
export HOME=/root
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=
role=

while getopts u:p:g:d:l:a:b:r: opt
do
	case $opt in
		u)	buser=$OPTARG;;
		p)	bpwd=$OPTARG;;
		g)	giturl=$OPTARG;;
		d)      db_address=$OPTARG;;
		l)      db_name=$OPTARG;;
		a)      db_username=$OPTARG;;
		b)      db_password=$OPTARG;;
                r)      role=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

sudo su;mv /home/ec2-user/bitbucket /root/.ssh/bitbucket 
cd /root
ssh -i /root/.ssh/bitbucket -o StrictHostKeyChecking=no git@bitbucket.org||true
mkdir -p /root/drucloudaws
git clone --depth 1 $giturl /root/drucloudaws >> $LOG
cd /root/drucloudaws/
/root/.composer/vendor/bin/drush site-install drucloud "--db-url=mysql://"$db_username":"$db_password"@"$db_address"/"$db_name --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes >> $LOG
if [ -f sites/default/settings.php ];
then
echo '$'"conf['file_default_scheme'] = 'public';" >> sites/default/settings.php
fi
cd ~/drucloudaws/sites/default
/root/.composer/vendor/bin/drush cc all
cp /root/drucloudaws/sites/default/settings.php /home/ec2-user/chef11/chef-repo/cookbooks/drupalsetting/templates/default/settings.php
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
cd /home/ec2-user/chef11/chef-repo/cookbooks
/opt/chef-server/embedded/bin/knife cookbook upload --all
