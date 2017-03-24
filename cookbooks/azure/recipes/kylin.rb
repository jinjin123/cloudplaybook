#
# Cookbook Name:: azure
# Recipe:: kylin
#
# Copyright 2017, Kylin
#
# All rights reserved - Do Not Redistribute
#

# The flow of excution of command:
# 1. Storing everything from a stopped by existing container if not exist, then remove container
# 2. run command into container
# 3. create image from new container
# 4. remove new container
# So in any point of time, on host there shld be no container exists but image is upto date

credentials = node[:deploycode][:configuration][:azure][:credentials]
#image = node[:deploycode][:runtime]["azure-cli"][:image]
# Name of docker container is not imaport, just make one
container_name = "#{node[:projectname]}_azure"
# Aggregating operations into image, default = container_name
image_name = container_name
# Setting basedir to store template files
basedir = node[:deploycode][:basedirectory]
username = node[:deployuser]

# storing kylin variables to be called
if (not (defined?(node[:deploycode][:configuration][:azure][:kylin])).nil?) && (not "#{node[:deploycode][:configuration][:azure][:kylin]}" == "")
  kylin = node[:deploycode][:configuration][:azure][:kylin]
end

#execute "removeimage_if_exists" do
#    command "if [ `docker images|awk {'print $NF'}|grep \'^#{image_name}$\'|wc -l` == \'1\' ];then docker rmi #{image_name};fi"
#end

execute "createimageifnotexist_removecontainerifexist" do
    command "if [ `docker images|awk {'print $NF'}|grep \'^#{image_name}$\'|wc -l` != \'1\' ];then docker commit #{container_name} #{image_name};fi;if [ `docker ps -a|awk {'print $NF'}|grep \'^#{container_name}$\'|wc -l` == \'1\' ];then docker stop #{container_name}||true;docker rm #{container_name}||true;fi"
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
	command "docker stop #{container_name};docker commit #{container_name} #{image_name}_tmp;docker rm #{container_name};docker rmi #{image_name};docker tag #{image_name}_tmp #{image_name};docker rmi #{image_name}_tmp"
    action :nothing
end

if (not (defined?(kylin)).nil?) && (not "#{kylin}" == "")
  identifier = kylin[:identifier]
  directory "#{basedir}azure/#{identifier}" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end

  if kylin[:region].downcase.include?("china")
    template "#{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json" do
      source "deploywithcluster_cn.json"
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
    template "#{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json" do
      source "deploywithcluster_cn.parameters.json.erb"
      variables(
        :appType => kylin[:appType],
        :clusterName  => kylin[:clusterName],
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => kylin[:clusterType],
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => kylin[:containerName],
        :edgeNodeSize => kylin[:edgeNodeSize],
        :location => kylin[:region],
        :metastoreName => kylin[:metastoreName],
        :sshUserName => kylin[:sshUserName],
        :sshPassword => kylin[:sshPassword],
        :storageAccount => kylin[:storageAccount]
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
  else
    template "#{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json" do
      source "deploywithcluster.json"
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
  end

  # Create resources group
  execute 'create_resources_group' do
    command "docker run --name #{container_name} #{image_name} azure group create -n kylin#{identifier} -l #{kylin[:region]} || true"
    notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end
  # Running deploymentTemplate
  results = "#{basedir}azure/#{identifier}/kylin#{identifier}_deploy.log"
  file results do
    action :delete
  end
  cmd = "docker run -v #{basedir}azure/#{identifier}:/templates --name #{container_name} #{image_name} azure group deployment create -g kylin#{identifier} -n kylin#{identifier} -f /templates/deploymentTemplate.#{identifier}.json -e /templates/deploymentTemplate.#{identifier}.parameters.json"
  bash cmd do
    code <<-EOH
    #{cmd} &> #{results}
    EOH
    notifies :run, 'execute[commit_docker]', :immediately
  end
end
