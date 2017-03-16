#
# Cookbook Name:: azure
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if (not (defined?(node[:deploycode][:configuration][:azure][:kylin])).nil?)
  include_recipe '::kylin'
end
