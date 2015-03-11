#!/bin/bash
LOG=/root/run.log
echo `date` >> $LOG
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
git clone --depth 10 $giturl /root/drucloudaws >> $LOG
cd /root/drucloudaws/

#RESULT=$?
#if [ $RESULT -eq 0 ]; then
#  echo Installation has been successful. >> $LOG
#else
#  echo Installation has been Failed. >> $LOG
#  echo Running retry... >> $LOG
#  sleep 5
#  n=0;until [ $n -ge 5 ];do /root/.composer/vendor/bin/drush site-install drucloud --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes >> $LOG; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done; 
#fi

#n=0;until [ $n -ge 5 ];do ls sites/default/settings.php; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;
/usr/bin/chef-solo -j <(echo '{"drupal_settings":{"web_root":"/root/drucloudaws","web_user":"root","web_group":"root"}, "run_list": "recipe[drupal_settings]"}')
/root/.composer/vendor/bin/drush site-install drucloud --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes >> $LOG 

cd ~/drucloudaws/sites/default
/root/.composer/vendor/bin/drush cc all
/root/.composer/vendor/bin/drush php-eval 'node_access_rebuild();'
