#!/bin/bash
LOG=/root/run.log
export HOME=/root
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=

while getopts u:p:g:d:l:a:b: opt
do
	case $opt in
		u)	buser=$OPTARG;;
		p)	bpwd=$OPTARG;;
		g)	giturl=$OPTARG;;
		d)      db_address=$OPTARG;;
		l)      db_name=$OPTARG;;
		a)      db_username=$OPTARG;;
		b)      db_password=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

sudo su;if [ -f /home/ec2-user/bitbucket ];then cp /home/ec2-user/bitbucket /root/.ssh/bitbucket;fi 
cd /root
chmod 400 /root/.ssh/bitbucket
ssh -i /root/.ssh/bitbucket -o StrictHostKeyChecking=no git@bitbucket.org||true
mkdir -p /root/drucloudaws
git clone --depth 1 $giturl /root/drucloudaws
cd /root/drucloudaws/
/root/.composer/vendor/bin/drush site-install drucloud "--db-url=mysql://"$db_username":"$db_password"@"$db_address"/"$db_name --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes --debug
#RESULT=$?
#if [ $RESULT -eq 0 ]; then
#  echo Installation has been successful.
#else
#  echo Installation has been Failed.
#  echo Running retry... >> $LOG
#  sleep 5
#  n=0;until [ $n -ge 5 ];do /root/.composer/vendor/bin/drush site-install drucloud --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes >> $LOG; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done; 
#fi

n=0;until [ $n -ge 5 ];do ls sites/default/settings.php; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;
/usr/bin/chef-solo -j <(echo '{"drupal_settings":{"web_root":"/root/drucloudaws","web_user":"root","web_group":"root"}, "run_list": "recipe[drupal_settings]"}')

cd /root/drucloudaws/sites/default
source /root/.bashrc
/root/.composer/vendor/bin/drush cc all 
/root/.composer/vendor/bin/drush php-eval 'node_access_rebuild();'
/opt/dep/disable_modules.sh -h /root -r /root/drucloudaws -u root