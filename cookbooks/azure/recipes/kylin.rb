#
# Cookbook Name:: azure
# Recipe:: kylin
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

credentials = node[:deploycode][:configuration][:azure][:credentials]
image = node[:deploycode][:runtime]["azure-cli"][:image]
# Name of docker container is not imaport, just make one
container_name = "azure"

# Reinit azure docker_container
if (not (defined?(credentials[:env])).nil?)
	execute 'login_china' do
	  command "docker rm #{container_name};docker run --name #{container_name} #{image} azure login --username #{credentials[:username]} --password #{credentials[:password]} --environment #{credentials[:env]}"
      notifies :run, 'execute[commit_docker]', :immediately
	end
else
	execute 'login_global' do
	  command "docker rm #{container_name};docker run --name #{container_name} #{image} azure login --username #{credentials[:username]} --password #{credentials[:password]}"
      notifies :run, 'execute[commit_docker]', :immediately
	end
end

execute "commit_docker" do
	command "docker commit #{container_name} #{container_name}_tmp;docker rm #{container_name};docker commit #{container_name}_tmp #{container_name};docker rm #{container_name}_tmp"
    action :nothing
end
