#
# Cookbook Name:: drupal_settings
# Attributes:: default
#
# Copyright 2013, David Radcliffe
#

default['drupal_settings']['secretpath'] = '/etc/chef/secret_key'
default['drupal_settings']['system_user'] = 'ec2-user'
default['drupal_settings']['web_root'] = '/var/www/html'
default['drupal_settings']['web_user'] = 'nginx'
default['drupal_settings']['web_group'] = 'nginx'
