#!/bin/bash
VAR=$1
AZ1=`echo $VAR|cut -d ',' -f1`
AZ2=`echo $VAR|cut -d ',' -f2`
REGION=`echo $VAR|cut -d ',' -f3`
ID=`echo $VAR|cut -d ',' -f4`

# Run checking command
aws ec2 describe-key-pairs --key-name kylin --region $REGION > /dev/null
if [ $? -ne 0 ]
then
    echo "Kylin key doesnt exists, uploading..."
    aws ec2 import-key-pair --key-name kylin --public-key-material --region $REGION file://./ec2key/kylin.pub
    if [ $? -ne 0 ];then 
      echo "Upload of EC2 key pair failed, Please contact system admin"
      exit
    fi
fi
