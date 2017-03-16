#
# Cookbook Name:: azure
# Recipe:: kylin
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

credentials = node[:deploycode][:configuration][:azure][:credentials]
image = node[:deploycode][:runtime][:azure-cli][:image]