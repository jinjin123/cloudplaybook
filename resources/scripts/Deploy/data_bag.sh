#!/bin/bash

mkdir -p /home/ec2-user/chef11/chef-repo/data_bags/drupal
tar -xvf /home/ec2-user/drupal_data.tar -C /home/ec2-user/chef11/chef-repo/data_bags
cd /home/ec2-user/chef11/chef-repo
/opt/chef-server/embedded/bin/knife data bag create drupal
for x in `ls data_bags/drupal/*.json`
do
/opt/chef-server/embedded/bin/knife data bag from file drupal $x --secret-file .chef/secret_key
done
#rm .chef/secret_key
/usr/bin/chef-solo -o 'recipe[nginx]'
/usr/bin/chef-solo -j <(echo '{"drupal_settings":{"web_root":"/root/drucloudaws"}, "run_list": "recipe[drupal_settings]"}')
