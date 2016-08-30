#!/bin/bash

####################
# Define variables
ID="KYLIN-"`date +%Y%m%d%H%M%S`
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
VpcId=<%= node[:vpc_id] %>
EMRSubet=<%= node[:subnet_id] %>
KEYPAIR=`/home/ec2-user/tools/ec2-metadata -u|grep keyname|cut -d ':' -f2`

CLUSTER_ID=`/usr/bin/aws emr create-cluster \
--applications Name=Hadoop Name=Hive Name=Pig Name=Hue Name=HBase Name=ZooKeeper Name=Phoenix Name=HCatalog \
--tags 'name=kyligence-emr' \
--ec2-attributes KeyName=$KEYPAIR,InstanceProfile=EMR_EC2_DefaultRole,SubnetId=$EMRSubet \
--service-role EMR_DefaultRole \
--enable-debugging \
--release-label emr-5.0.0 \
--log-uri "s3n://aws-logs-810803377174-$REGION/elasticmapreduce/" \
--name 'Kyligence_Enterprise_demo_architecture' \
--instance-groups '[{"InstanceCount":2,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core instance group - 2"},{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master instance group - 1"}]' \
--region $REGION|cut -d':' -f2| sed 's/\"\|,\| //g'`

# Check status and return until success or failed
STATUS=`/usr/bin/aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types MASTER|grep \"State\"|cut -d':' -f2| sed 's/\"\|,\| //g'`
echo -ne "MapReduce creation in progress."
while [ "$STATUS" != "RUNNING" ]
do
  sleep 5
  echo -ne "."
  STATUS=`/usr/bin/aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types MASTER|grep \"State\"|cut -d':' -f2| sed 's/\"\|,\| //g'`
  if [ "$STATUS" == "AWAITING_FULFILLMENT" ];then
    echo "AWAITING_FULFILLMENT is responsed, please contact administrator"
    exit
  fi
done

# Print success message
echo "Creation of EMR completed, you can run update hadoop file"

