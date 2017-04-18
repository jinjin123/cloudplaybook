#!/bin/bash

CHEF_PATH=~/root/tools
CHEFSERVER_ADDR=172.16.103.110
NODE_NAME=pddruapp01
VALIDATE_NAME=root
ENV=zkfprod

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

yum install gem -y
/usr/bin/gem sources --add https://gems.ruby-china.org --remove https://rubygems.org

yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/kmod-20-9.el7.x86_64.rpm
yum install -y http://mirror.centos.org/centos/7/updates/x86_64/Packages/initscripts-9.49.37-1.el7_3.1.x86_64.rpm

yum install -y http://mirror.centos.org/centos/7/updates/x86_64/Packages/systemd-219-30.el7_3.8.x86_64.rpm
yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libsepol-2.5-6.el7.x86_64.rpm
yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libselinux-utils-2.5-6.el7.x86_64.rpm
yum install -y http://mirror.centos.org/centos/7/updates/x86_64/Packages/policycoreutils-2.5-11.el7_3.x86_64.rpm
yum install http://mirror.centos.org/centos/7/updates/x86_64/Packages/selinux-policy-3.13.1-102.el7_3.16.noarch.rpm -y
yum install http://mirror.centos.org/centos/7/updates/x86_64/Packages/selinux-policy-targeted-3.13.1-102.el7_3.16.noarch.rpm -y
