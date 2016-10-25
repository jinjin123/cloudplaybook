#
# Cookbook Name:: drupal_settings
# Attributes:: default
#
# Copyright 2013, David Radcliffe
#

default['drupal_settings']['secretpath'] = '/etc/chef/secret_key'
default['drupal_settings']['system_user'] = 'ec2-user'
default['drupal_settings']['web_root'] = '/var/www/html'
default['drupal_settings']['web_user'] = 'ec2-user'
default['drupal_settings']['web_group'] = 'ec2-user'
default['drupal_settings']['search_default_module'] = 'apachesolr_search'
default['drupal_settings']['search_node'] = '0'
default['drupal_settings']['web_user_home'] = '/home/ec2-user'