#!/bin/bash
#be care when modify this file,some sript may modify this file depends on line number
#dbcmd=drop database if exists xxx;create database xxx;grant all privileges on xxx.* to 'username'@'%' identified by 'password'
dburl=drucloud.c0ao1k8qfl2y.ap-northeast-1.rds.amazonaws.com
dbuser=drucloud
dbpwd=drucloud
dbcmd=
rootDir=/var/app/drupal
druuser=druuser
drupwd=drupwd
drudb=drusample
profilename=standard
while getopts h:u:p:c:r:a:b:d:s: opt
do 
	case $opt in
		h)	dburl=$OPTARG;;
		u)	dbuser=$OPTARG;;
		p)	dbpwd=$OPTARG;;
		c)	dbcmd=$OPTARG;;
		r)	rootDir=$OPTARG;;
		a)	druuser=$OPTARG;;
		b)	drupwd=$OPTARG;;
		d)	drudb=$OPTARG;;
		s)  profilename=$OPTARG;;
		*)	echo "-$opt not recognized";;
	esac
done

result=`mysql -h$dburl -u$dbuser -p$dbpwd -Dinformation_schema -e"select count(1) from SCHEMATA where SCHEMA_NAME='$drudb'" -N`
if [ "$result" == "1" ]; then
	echo "attention: a database already exist named $drudb,installation stoped!"
	exit 0
fi

dbcmd="drop database  if exists $drudb;create database $drudb;grant all privileges on $drudb.* to '$druuser'@'%' identified by '$drupwd'"

mysql -h$dburl -u$dbuser -p$dbpwd -e"$dbcmd"


# please change below config files before deployment.
drush site-install $profilename \
  --root=$rootDir \
  --db-url=mysql://$druuser:$drupwd@$dburl/$drudb \
  --db-su=$dbuser \
  --db-su-pw=$dbpwd \
  --account-name=admin \
  --account-pass=admin \
  --site-name="Mobingi feature Platform" --yes