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

while getopts r:f:d:n:m:w: opt
do
        case $opt in
                r)      region=$OPTARG;;
                f)      file_id=$OPTARG;;
                d)      db_address=$OPTARG;;
                n)      db_name=$OPTARG;;
                m)      db_user=$OPTARG;;
                w)      db_passwd=$OPTARG;;
                *)      echo "-$opt not recognized";;
        esac
done

# Get the SQL file from S3
/usr/bin/s3cmd get "s3://gamecloud-"$region"/"$file_id ./sql --force

# Apply the SQL file to mySQL DB
/usr/bin/mysql -h $db_address -u $db_name "-p"$db_passwd < "./sql/"$file_id
