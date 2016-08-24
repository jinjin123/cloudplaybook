#
# Cookbook Name:: drucloud_config
# Attributes:: default
#
# Copyright 2013, David Radcliffe
#

default['drucloud_config']['drupal_root'] = '/var/www/html'
default['drucloud_config']['drupal_user'] = 'ec2-user'
default['drucloud_config']['drupal_group'] = 'ec2-user'
default['drucloud_config']['drupal_user_home'] = '/home/ec2-user/'
default['drucloud_config']['drush_path'] = '/home/ec2-user/.composer/vendor/bin'
default['drucloud_config']['drucloud_package'] = 'recommend'
