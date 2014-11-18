#
# Cookbook Name:: activelamp_drupal
# Recipe:: drush
#
# Copyright (c) 2014 ActiveLAMP, All Rights Reserved.

execute 'install_composer' do
  user "root" 
  group "root" 
  command "curl -sS https://getcomposer.org/installer | php;mv composer.phar /usr/local/bin/composer"
end
composer_home = ::File.expand_path("~#{ node[:activelamp_drupal][:drush][:user] }/.composer")
composer_drush_path = "#{ composer_home }/vendor/bin/drush"

drush_version = node[:activelamp_drupal][:drush][:version] == '7.x' ? 'dev-master' : node[:activelamp_drupal][:drush][:version]

execute 'drupal-make-drush-install' do
  creates composer_drush_path
  command  "#{ node[:activelamp_drupal][:drush][:composer_command] } global require drush/drush:#{ drush_version }"
  user node[:activelamp_drupal][:drush][:user]
  group node[:activelamp_drupal][:drush][:group]
  environment({
    'COMPOSER_HOME' => composer_home
  })
end

link node[:activelamp_drupal][:drush][:install_path] do
  to composer_drush_path
  owner node[:activelamp_drupal][:drush][:user]
  mode '0777'
end
