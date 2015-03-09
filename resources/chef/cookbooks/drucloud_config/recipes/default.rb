#
# Cookbook Name:: drucloud_config
# Recipe:: default
#
# Copyright 2015, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#

bash "disable_for_running_this_cookbook" do
   cwd "#{node['drucloud_config']['drupal_root']}/sites/default"
end
