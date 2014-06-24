#!/bin/bash
export HOME=/root
#. /opt/dep/firstry.sp
cd /opt/dep
mkdir -p sql

region=
file_id=
db_address=
db_name=
db_user=
db_passwd=
way=

while getopts r:f:d:n:m:w:l: opt
do
        case $opt in
                r)      region=$OPTARG;;
                f)      file_id=$OPTARG;;
                d)      db_address=$OPTARG;;
                n)      db_name=$OPTARG;;
                m)      db_user=$OPTARG;;
                w)      db_passwd=$OPTARG;;
                l)      way=$OPTARG
                *)      echo "-$opt not recognized";;
        esac
done

if [ $way == 'file' ];then
# Get the SQL file from S3
/usr/bin/s3cmd get "s3://gamecloud-"$region"/"$file_id ./sql --force
# Apply the SQL file to mySQL DB
/usr/bin/mysql -h $db_address -u $db_user "-p"$db_passwd $db_name < "./sql/"$file_id
elif [ $way == 'url' ];then
# Stream the remote SQL file to MySQL
curl $file_id | /usr/bin/mysql -h $db_address -u $db_user "-p"$db_passwd $db_name
fi;
