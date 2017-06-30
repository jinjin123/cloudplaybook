#!/bin/bash
BOOT_HOME=`pwd`

VAR=$1
AZ1=`echo $VAR|cut -d ',' -f1`
AZ2=`echo $VAR|cut -d ',' -f2`
REGION=`echo $VAR|cut -d ',' -f3`
ID=`echo $VAR|cut -d ',' -f4`
KEYPAIR=`echo $VAR|cut -d ',' -f5`
###Need input VPC id here###
#VPC_STACKNAME=`cat ./temp_vpc_id.txt`
VPC_STACKNAME=$ID"-vpc"
STACKOUTPUT=`aws cloudformation describe-stacks --stack-name $VPC_STACKNAME --region $REGION|grep OutputValue|sed 's/"OutputValue": "//g'| sed 's/ //g'|sed 's/"//g'`

if [ $? -ne 0 ]
then
    echo "Checking VPC status failed"
    exit
fi

####################
# DEFINE VARIABLE
#ID="KYLIN-"`date +%Y%m%d%H%M%S`
#AZ1=`./01_awscheck_zone.sh | head -1`
#AZ2=`./01_awscheck_zone.sh | tail -1`
#REGION=`cat ~/.aws/config | grep region | awk -F " " '{print $3}'`
VpcSecurityGroup=sg-`echo ${STACKOUTPUT#*sg-} | cut -d" " -f1| cut -d"," -f1`
VpcId=vpc-`echo ${STACKOUTPUT#*vpc-} | cut -d" " -f1| cut -d"," -f1`
ScalingSubnet=subnet-`echo ${STACKOUTPUT#*subnet-} | cut -d":" -f1| cut -d"," -f1`

if [ x$VpcId == x"vpc-" ]
then
    echo "Checking VPC status failed"
    exit
fi

####################
# KEEP DEFAULT UNLESS NECESSARY
####################
# DEFINE FILE LOCATION for bitbucket setup
SSHKEY=$BOOT_HOME/credentials/gitkey
SSHPUB=$BOOT_HOME/credentials/gitkey.pub
SSHKNOWNHOSTS=$BOOT_HOME/credentials/knownhost
EC2KEYPAIR=$BOOT_HOME/credentials/kylin.pem

####################
# Get values from credentials
SSHKey=$(cat $SSHKEY)
SSHPub=$(cat $SSHPUB)
SSHKnownHosts=$(cat $SSHKNOWNHOSTS)
EC2keypair=$(cat $EC2KEYPAIR)

####################
# BootDev branch name
BRANCH=docker-general-kyligence
# keypair name
#KEYPAIR=kylin

####################
# Create chef server
aws cloudformation create-stack \
--stack-name $ID-chefserver \
--capabilities CAPABILITY_IAM \
--template-body file://$BOOT_HOME/templates/chefServer.template \
--on-failure DO_NOTHING \
--region $REGION \
--parameters \
ParameterKey=BootCloudBranch,ParameterValue=$BRANCH \
ParameterKey=ChefSubnet,ParameterValue=$ScalingSubnet \
ParameterKey=ChefVpc,ParameterValue=$VpcId \
ParameterKey=GlusterMountUrl,ParameterValue='1.2.3.4' \
ParameterKey=ec2accesskey,ParameterValue="\"$EC2keypair\"" \
ParameterKey=GlusterVolume,ParameterValue=glt0 \
ParameterKey=InstanceType,ParameterValue=t2.small \
ParameterKey=KeyName,ParameterValue=$KEYPAIR \
ParameterKey=ServerTagName,ParameterValue=$ID-mgmt \
ParameterKey=StackName,ParameterValue=$ID-chefserver \
ParameterKey=SSHKey,ParameterValue="\"$SSHKey\"" \
ParameterKey=SSHPub,ParameterValue="\"$SSHPub\"" \
ParameterKey=SSHKnownHosts,ParameterValue="\"$SSHKnownHosts\"" \
ParameterKey=SSHLocation,ParameterValue="0.0.0.0/0" \
ParameterKey=VpcSecurityGroup,ParameterValue=$VpcSecurityGroup \
ParameterKey=Action,ParameterValue="create" \
ParameterKey=clustername,ParameterValue=$ID

#####################
# Check status and return until success or failed
STATUS=`aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
echo -ne "Creation in progress."
while [[ "$STATUS" != *"CREATE_COMPLETE"* ]]
do
  sleep 5
  echo -ne "."
  STATUS=`aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
  if [ "$STATUS" == "ROLLBACK_COMPLETE" ];then
    echo "Creation failed, Rollback completed"
    exit
  fi
done

# Print stack details
echo "Creation of Chef Server completed"
aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION
