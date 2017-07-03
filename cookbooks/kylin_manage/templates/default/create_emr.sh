#!/bin/bash

# Taking Parameters
CLUSTERNAME=$1
if [ -z ${CLUSTERNAME+x} ];then
  export CLUSTERNAME="KYLIN-"`date +%Y%m%d%H%M%S`
fi

####################
# Define variables
ID=$CLUSTERNAME
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
VpcId=<%= node[:vpc_id] %>
EMRSubet=<%= node[:subnet_id] %>
KEYPAIR=`/home/ec2-user/tools/ec2-metadata -u|grep keyname|cut -d ':' -f2`

CLUSTER_ID=`/usr/bin/aws emr create-cluster \
--applications Name=Hadoop Name=Hive Name=Pig Name=Hue Name=HBase Name=ZooKeeper Name=Phoenix Name=HCatalog \
--emrfs Consistent=true,RetryCount=5,RetryPeriod=30 \
--tags 'name=kyligence-emr' \
--ec2-attributes KeyName=$KEYPAIR,InstanceProfile=EMR_EC2_DefaultRole,SubnetId=$EMRSubet \
--service-role EMR_DefaultRole \
--enable-debugging \
--release-label emr-5.0.0 \
--log-uri "s3n://aws-logs-472319870699-$REGION/elasticmapreduce/" \
--name $CLUSTERNAME \
--instance-groups '[{"InstanceCount":2,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":500,"VolumeType":"gp2"},"VolumesPerInstance":1}],"EbsOptimized":true},"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core instance group - 2"},{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"r3.xlarge","Name":"Master instance group - 1"}]' \
--region $REGION|grep ClusterId|cut -d':' -f2| sed 's/\"\|,\| //g'`

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

# Put cluster master IP into file
MASTER_IP=`/usr/bin/aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types MASTER|grep PrivateIpAddress|cut -d':' -f2| sed 's/\"\|,\| //g'`
echo "{  \"EMR_MASTER\": \"$MASTER_IP\"}" > /etc/chef/parameter_hadoop.json
# update hadoop file script parameter
/usr/bin/chef-solo -o 'recipe[kylin_manage::hadoop_files]' -j /etc/chef/parameter_hadoop.json

# Update security group ingress
# Get source security group ID
SecurityGroupName=`/home/ec2-user/tools/ec2-metadata --security-groups|cut -d':' -f2|sed 's/ //g'`
SourceSecurityGroupID=`/usr/bin/aws ec2 describe-security-groups --filters Name=group-name,Values=$SecurityGroupName|grep GroupId|cut -d':' -f2|sed 's/\"\|,\| //g'|head -1`

# Get master security group ID
MASTER_instance_ID=`/usr/bin/aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types MASTER|grep Ec2InstanceId|cut -d':' -f2|sed 's/\"\|,\| //g'|head -1`
MASTER_SG_ID=`/usr/bin/aws ec2 describe-instances --instance-ids $MASTER_instance_ID| grep GroupId|head -1|cut -d':' -f2|sed 's/\"\|,\| //g'|head -1`

# Get slave security group ID
SLAVE_instance_ID=`/usr/bin/aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types CORE|grep Ec2InstanceId|cut -d':' -f2|sed 's/\"\|,\| //g'|head -1`
SLAVE_SG_ID=`/usr/bin/aws ec2 describe-instances --instance-ids $SLAVE_instance_ID| grep GroupId|head -1|cut -d':' -f2|sed 's/\"\|,\| //g'|head -1`

# open port
/usr/bin/aws ec2 authorize-security-group-ingress --group-id $MASTER_SG_ID --source-group $SourceSecurityGroupID --protocol all --port 0-65535
/usr/bin/aws ec2 authorize-security-group-ingress --group-id $SLAVE_SG_ID --source-group $SourceSecurityGroupID --protocol all --port 0-65535

# update
/root/update_hadoop_files.sh $CLUSTERNAME >> /var/log/cfn-init.log
