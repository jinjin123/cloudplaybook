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

if [ -f /home/ec2-user/bitbucket ];then sudo cp /home/ec2-user/bitbucket /root/.ssh/bitbucket;fi 
cd /root
sudo chmod 400 /root/.ssh/bitbucket
sudo ssh -i /root/.ssh/bitbucket -o StrictHostKeyChecking=no git@bitbucket.org||true
sudo mkdir -p /root/drucloudaws
sudo git clone --depth 10 $giturl /root/drucloudaws

cd /root/drucloudaws/sites/default
echo "Command to run drush install:"
echo /root/.composer/vendor/bin/drush site-install drucloud "--db-url=mysql://"$db_username":"$db_password"@"$db_address"/"$db_name --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes --debug -r /root/drucloudaws
sudo /root/.composer/vendor/bin/drush site-install drucloud "--db-url=mysql://"$db_username":"$db_password"@"$db_address"/"$db_name --account-name=admin --account-pass=admin --site-name="drucloudaws" --yes --debug -r /root/drucloudaws|| true 
n=0;until [ $n -ge 5 ];do ls /root/drucloudaws/sites/default/settings.php; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;
sudo /usr/bin/chef-solo -j <(echo '{"drupal_settings":{"web_root":"/root/drucloudaws","web_user":"root","web_group":"root"}, "run_list": "recipe[drupal_settings]"}') || true

cd /root/drucloudaws/sites/default
sudo source /root/.bashrc
sudo /root/.composer/vendor/bin/drush cc all 
sudo /root/.composer/vendor/bin/drush php-eval 'node_access_rebuild();'
sudo /opt/dep/disable_modules.sh -h /root -r /root/drucloudaws -u root