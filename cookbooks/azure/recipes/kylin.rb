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

if (not (defined?(credentials[:env])).nil?)
	execute 'login_china' do
	  command "docker run -it #{image} \'azure login --username #{credentials[:username]} --password #{credentials[:password]} --environment #{credentials[:env]}\'"
	end
else
	execute 'login_global' do
	  command "docker run -it #{image} \'azure login --username #{credentials[:username]} --password #{credentials[:password]}\'"
	end
end