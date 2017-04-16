#!/bin/bash

CHEF_PATH=~/root/tools
CHEFSERVER_ADDR=ec2-52-80-22-204.cn-north-1.compute.amazonaws.com.cn
NODE_NAME=ttdruapp01
VALIDATE_NAME=ec2-user
ENV=testing

# Run installation of binary
mkdir -p $CHEF_PATH
cp ./packages/chef-12.5.1-1.el7.x86_64.rpm $CHEF_PATH/chef-12.5.1-1.el7.x86_64.rpm
rpm -ivh $CHEF_PATH/chef-12.5.1-1.el7.x86_64.rpm

# putting config file
mkdir -p /etc/chef
cp ./config/client.rb /etc/chef/client.rb
sed -i "s/CHEFSERVER_ADDR/$CHEFSERVER_ADDR/" /etc/chef/client.rb
sed -i "s/NODE_NAME/$NODE_NAME/" /etc/chef/client.rb
sed -i "s/VALIDATE_NAME/$VALIDATE_NAME/" /etc/chef/client.rb

# putting keys
cp ./keys/$ENV/validation.pem /etc/chef/validation.pem
cp ./keys/$ENV/$VALIDATE_NAME.pem /etc/chef/$VALIDATE_NAME.pem
chmod 644 /etc/chef/validation.pem
