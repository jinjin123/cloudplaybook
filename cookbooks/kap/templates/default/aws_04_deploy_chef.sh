#!/bin/bash
BOOT_HOME=`pwd`

VAR=$1
AZ1=`echo $VAR|cut -d ',' -f1`
AZ2=`echo $VAR|cut -d ',' -f2`
REGION=`echo $VAR|cut -d ',' -f3`
ID=`echo $VAR|cut -d ',' -f4`
KEYPAIR=`echo $VAR|cut -d ',' -f5`
ADMINUSER=`echo $VAR|cut -d ',' -f6`
ADMINPASSWORD=`echo $VAR|cut -d ',' -f7`
APPTYPE=`echo $VAR|cut -d ',' -f8`
KYACCOUNTTOKEN=`echo $VAR|cut -d ',' -f9`
KAPAGENTID=`echo $VAR|cut -d ',' -f10`
INSTANCECOUNT=`echo $VAR|cut -d ',' -f11`
KAPURL=`echo $VAR|cut -d ',' -f12`
KYANALYZERURL=`echo $VAR|cut -d ',' -f13`
ZEPPELINURL=`echo $VAR|cut -d ',' -f14`
VPCTODEPLOY=`echo $VAR|cut -d ',' -f15`
SUBNETID=`echo $VAR|cut -d ',' -f16`
VPCSECURITYGROUP=`echo $VAR|cut -d ',' -f17`


if [ -z "$VPCTODEPLOY" ] && [ -z "$SUBNETID"];
then
  ###Need input VPC id here###
  #VPC_STACKNAME=`cat ./temp_vpc_id.txt`
  VPC_STACKNAME=$ID"-vpc"
  STACKOUTPUT=`aws cloudformation describe-stacks --stack-name $VPC_STACKNAME --region $REGION|grep OutputValue|sed 's/"OutputValue": "//g'| sed 's/ //g'|sed 's/"//g'`

  if [ $? -ne 0 ]
  then
      echo "Checking VPC status failed"
      exit
  fi

  VpcSecurityGroup=sg-`echo ${STACKOUTPUT#*sg-} | cut -d" " -f1| cut -d"," -f1`
  VpcId=vpc-`echo ${STACKOUTPUT#*vpc-} | cut -d" " -f1| cut -d"," -f1`
  ScalingSubnet=subnet-`echo ${STACKOUTPUT#*subnet-} | cut -d":" -f1| cut -d"," -f1`

  if [ x$VpcId == x"vpc-" ]
  then
      echo "Checking VPC status failed"
      exit
  fi
else
  VpcId=$VPCTODEPLOY
  ScalingSubnet=$SUBNETID
  # Creating new SecurityGroup for deployment
  if [ ! -z $VPCSECURITYGROUP ]
  then
    VpcSecurityGroup=$VPCSECURITYGROUP
  else
    VpcSecurityGroup=$(aws ec2 create-security-group --description "Open up SSH access and all ports to itself" --group-name "$ID-VpcSecurityGroup" --vpc-id $VpcId --output text)
  fi
  aws ec2 authorize-security-group-ingress --group-id $VpcSecurityGroup --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]' || true
  aws ec2 authorize-security-group-egress --group-id $VpcSecurityGroup  --ip-permissions '[{"IpProtocol": "all", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]' || true
  COMMAND="aws ec2 authorize-security-group-ingress --group-id $VpcSecurityGroup --ip-permissions '[{\"IpProtocol\": \"-1\", \"IpRanges\": [], \"UserIdGroupPairs\":[{\"GroupId\": \"$VpcSecurityGroup\"}] }]'"
  eval $COMMAND || true

  # Adding ingress into EMR Security Group
  COMMAND="aws ec2 describe-security-groups --query 'SecurityGroups[? VpcId == \`VPCID\` ].[GroupName, GroupId]' --output text | grep ElasticMapReduce | awk {'print \$2'}"
  RESULTCOMMAND=\"${COMMAND/VPCID/$VpcId}\";
  eval GROUPLIST=\$$RESULTCOMMAND || true
  for x in $GROUPLIST
  do
    COMMAND="aws ec2 authorize-security-group-ingress --group-id $x --ip-permissions '[{\"IpProtocol\": \"-1\", \"IpRanges\": [], \"UserIdGroupPairs\":[{\"GroupId\": \"$VpcSecurityGroup\"}] }]'"
    eval $COMMAND || true
  done

  # Putting DNS enable to be true, and forcing command result to be true
  aws ec2 modify-vpc-attribute --vpc-id $VpcId --enable-dns-support "{\"Value\":true}" || true
fi

echo "VpcId = "$VpcId
echo "ScalingSubnet = "$ScalingSubnet
echo "VpcSecurityGroup = "$VpcSecurityGroup

####################
# KEEP DEFAULT UNLESS NECESSARY
####################
# Trouble shooting for key
echo "BootHome = "$BOOT_HOME

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
ParameterKey=clustername,ParameterValue=$ID \
ParameterKey=adminuser,ParameterValue=$ADMINUSER \
ParameterKey=adminpassword,ParameterValue=$ADMINPASSWORD \
ParameterKey=apptype,ParameterValue=$APPTYPE \
ParameterKey=kyaccountToken,ParameterValue=$KYACCOUNTTOKEN \
ParameterKey=kapagentid,ParameterValue=$KAPAGENTID \
ParameterKey=InstanceCount,ParameterValue=$INSTANCECOUNT \
ParameterKey=kapurl,ParameterValue=$KAPURL \
ParameterKey=kyanalyzerurl,ParameterValue=$KYANALYZERURL \
ParameterKey=zeppelinurl,ParameterValue=$ZEPPELINURL \

#####################
# Check status and return until success or failed
STATUS=`aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
echo -ne "Creation in progress."
while [[ "$STATUS" != *"CREATE_COMPLETE"* ]]
do
  sleep 5
  echo -ne "."
  STATUS=`aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION|grep StackStatus|awk {'print $2'}|sed 's/\"\|,//g'`
  if [ "$STATUS" == "ROLLBACK_COMPLETE" ] || [ "$STATUS" == "CREATE_FAILED" ];then
    echo "Creation failed, Rollback completed"
    exit
  fi
done

# Print stack details
echo "Creation of Chef Server completed"
aws cloudformation describe-stacks --stack-name $ID-chefserver --region $REGION
