#
# Cookbook Name:: drucloud_config
# Attributes:: default
#
# Copyright 2013, David Radcliffe
#

default['drucloud_config']['drupal_root'] = '/var/www/html'
default['drucloud_config']['drupal_user'] = 'nginx'
default['drucloud_config']['drupal_group'] = 'nginx'
default['drucloud_config']['drush_path'] = '/var/lib/nginx/.composer/vendor/bin/'
default['drucloud_config']['drucloud_package'] = 'Package'
