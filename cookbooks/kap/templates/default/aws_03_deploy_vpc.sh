#!/bin/bash
#####################
# DEFINE VARIABLE
#ID="KYLIN-"`date +%Y%m%d%H%M%S`
#AZ1=`./01_awscheck_zone.sh | head -1`
#AZ2=`./01_awscheck_zone.sh | tail -1`
#REGION=`cat ~/.aws/config | grep region | awk -F " " '{print $3}'`
VAR=$1
AZ1=`echo $VAR|cut -d ',' -f1`
AZ2=`echo $VAR|cut -d ',' -f2`
REGION=`echo $VAR|cut -d ',' -f3`
ID=`echo $VAR|cut -d ',' -f4`

#####################
# Create VPC
aws cloudformation create-stack --stack-name $ID-vpc --template-body file://./templates/vpc.template --parameters ParameterKey=AZ1,ParameterValue=$AZ1 ParameterKey=AZ2,ParameterValue=$AZ2 --region $REGION

#####################
# Check status and return until success or failed
STATUS=`aws cloudformation describe-stacks --stack-name $ID-vpc --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
echo -ne "Creation in progress."
while [[ "$STATUS" != *"CREATE_COMPLETE"* ]]
do
  sleep 5
  echo -ne "."
  STATUS=`aws cloudformation describe-stacks --stack-name $ID-vpc --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
  if [ "$STATUS" == "ROLLBACK_COMPLETE" ];then
    echo "Creation failed, Rollback completed"
    exit
  fi
done

# Print stack details
echo "Creation of VPC completed"
#aws cloudformation describe-stacks --stack-name $ID-vpc --region $REGION

# Pass VPC stack id to next script
#echo $ID-vpc > temp_vpc_id.txt
