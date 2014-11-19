#!/bin/bash
LOG=run.log
export HOME=/root
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=
role=

while getopts u:p:k:g:d:l:a:b: opt
do
	case $opt in
		u)	buser=$OPTARG;;
		p)	bpwd=$OPTARG;;
		k)	userpem=$OPTARG;;
		g)	giturl=$OPTARG;;
		d)      db_address=$OPTARG;;
		l)      db_name=$OPTARG;;
		a)      db_username=$OPTARG;;
		b)      db_password=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

sudo su;mv /home/ec2-user/bitbucket /root/.ssh/bitbucket 
cd ~
mkdir -p drucloudaws
git clone --depth 1 $giturl drucloudaws >> $LOG
/root/.composer/vendor/bin/drush site-install drucloud --db-url=mysql://$db_username:$db_password@$db_address/$db_name --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes >> $LOG
if [ -f $FILE ];
then
echo "$conf['file_default_scheme'] = 'public';" >> sites/drucloudaws/settings.php
fi 
