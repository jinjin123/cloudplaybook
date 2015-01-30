#!/bin/bash

tar -xvf /home/ec2-user/drupal_data.tar -C /home/ec2-user/chef11/chef-repo/data_bags
cd /home/ec2-user/chef11/chef-repo
/opt/chef-server/embedded/bin/knife data bag create drupal
for x in `ls data_bags/*.json`
do
/opt/chef-server/embedded/bin/knife data bag from file drupal $x --secret-file .chef/secret_key
done
#rm .chef/secret_key
