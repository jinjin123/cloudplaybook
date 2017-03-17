#
# Cookbook Name:: azure
# Recipe:: kylin
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# The flow of excution of command:
# 1. Storing everything from a stopped by existing container if not exist, then remove container
# 2. run command into container
# 3. create image from new container
# 4. remove new container
credentials = node[:deploycode][:configuration][:azure][:credentials]
#image = node[:deploycode][:runtime]["azure-cli"][:image]
# Name of docker container is not imaport, just make one
container_name = "#{node[:projectname]}_azure"
# Aggregating operations into image, default = container_name
image_name = container_name

execute "createimageifnotexist_removecontainerifexist" do
    command "if [ `docker images|grep \'^#{image_name}$\'|wc -l` != \'1\' ];then docker commit #{container_name} #{image_name};fi;if [ `docker ps -a|grep \'^#{container_name}$\'|wc -l` == \'1\' ];then docker stop #{container_name}||true;docker rm #{container_name}|fi"
end

# Reinit azure docker_container
if (not (defined?(credentials[:env])).nil?)
	execute 'login_china' do
	  command "docker run --name #{container_name} #{image_name} azure login --username #{credentials[:username]} --password #{credentials[:password]} --environment #{credentials[:env]}"
      notifies :run, 'execute[commit_docker]', :immediately
	end
else
	execute 'login_global' do
	  command "docker run --name #{container_name} #{image_name} azure login --username #{credentials[:username]} --password #{credentials[:password]}"
      notifies :run, 'execute[commit_docker]', :immediately
	end
end

execute "commit_docker" do
	command "docker commit #{container_name} #{image_name}_tmp;docker rm #{container_name};docker rmi #{image_name};docker tag #{image_name}_tmp #{image_name};docker rmi #{image_name}_tmp;docker rm #{container_name}"
    action :nothing
end
