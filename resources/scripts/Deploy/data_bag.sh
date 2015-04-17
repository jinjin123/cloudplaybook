#!/bin/bash

if [ -f /etc/chef/validation.pem ] && [ -f /usr/bin/chef-server-ctl ];then
service nginx stop||true
/usr/bin/chef-server-ctl start
fi

mkdir -p /home/ec2-user/chef11/chef-repo/data_bags/drupal
if [ ! -f /etc/chef/solo.rb ];
then
  cp /home/ec2-user/chef11/chef-repo/.chef/knife.rb /etc/chef/solo.rb
fi
tar -xvf /home/ec2-user/drupal_data.tar -C /home/ec2-user/chef11/chef-repo/data_bags/
cd /home/ec2-user/chef11/chef-repo
/usr/bin/knife data bag create drupal
for x in `ls data_bags/*.json`
  do
  /usr/bin/knife data bag from file drupal $x --secret-file .chef/secret_key
done
rm .chef/secret_key
for x in `/usr/bin/knife data bag show drupal`
  do
  /usr/bin/knife data bag show drupal $x --format json > /home/ec2-user/chef11/chef-repo/data_bags/drupal/$x.json
done
rm /home/ec2-user/chef11/chef-repo/data_bags/*.json

if [ -f /etc/chef/validation.pem ] && [ -f /usr/bin/chef-server-ctl ];then
/usr/bin/chef-server-ctl stop
service nginx start||true
fi

