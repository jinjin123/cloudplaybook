#!/bin/bash

# Taking VPC ID as parameter
VPCSTACKNAME=$1
SECURITYGROUPIDS=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=`aws cloudformation describe-stacks --stack-name $VPCSTACKNAME --query 'Stacks[*].Outputs[*]' --output text|grep VpcId|  awk {'print $NF'}` --query 'SecurityGroups[*].{Name:GroupId}' --output text)

for x in $SECURITYGROUPIDS
do
  echo "This is $x"
  aws ec2 describe-security-groups --group-ids $x --query 'SecurityGroups[*].IpPermissions[*]' > ./temp.txt
  sed '1,1d' ./temp.txt > temp.out1
  sed '$d' ./temp.out1 > ./temp.txt
  a="aws ec2 revoke-security-group-ingress --group-id $x --ip-permissions "
  b=`cat ./temp.txt`
  command=$a"'"$b"'"
  eval $command
  rm -f ./temp.txt temp.out1
  aws ec2 describe-security-groups --group-ids $x --query 'SecurityGroups[*].IpPermissionsEgress[*]' > ./temp.txt
  sed '1,1d' ./temp.txt > temp.out1
  sed '$d' ./temp.out1 > ./temp.txt
  a="aws ec2 revoke-security-group-egress --group-id $x --ip-permissions "
  b=`cat ./temp.txt`
  command=$a"'"$b"'"
  eval $command
  rm -f ./temp.txt temp.out1
  aws ec2 delete-security-group --group-id $x
done

for x in $SECURITYGROUPIDS
do
  aws ec2 delete-security-group --group-id $x
done

aws ec2 delete-vpc --vpc-id `aws cloudformation describe-stacks --stack-name $VPCSTACKNAME --query 'Stacks[*].Outputs[*]' --output text|grep VpcId|  awk {'print $NF'}`
