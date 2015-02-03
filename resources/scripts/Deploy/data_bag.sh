#!/bin/bash

mkdir -p /home/ec2-user/chef11/chef-repo/data_bags/drupal
if [ ! -f /etc/chef/solo.rb ];
then
  cp /home/ec2-user/chef11/chef-repo/.chef/knife.rb /etc/chef/solo.rb
fi
tar -xvf /home/ec2-user/drupal_data.tar -C /home/ec2-user/chef11/chef-repo/data_bags/
#drupal_encrpty
cd /home/ec2-user/chef11/chef-repo
/opt/chef-server/embedded/bin/knife data bag create drupal
for x in `ls data_bags/*.json`
do
/opt/chef-server/embedded/bin/knife data bag from file drupal $x --secret-file .chef/secret_key
done
#rm .chef/secret_key

mv /home/ec2-user/chef11/chef-repo/data_bags/*.json /home/ec2-user/chef11/chef-repo/data_bags/drupal
