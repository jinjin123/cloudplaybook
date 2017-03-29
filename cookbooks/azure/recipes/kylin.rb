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

# Setting basedir to store template files
basedir = node[:deploycode][:basedirectory]
username = node[:deployuser]
runtime = node[:deploycode][:runtime][:azure]

# storing kylin variables to be called
if (not (defined?(node[:deploycode][:configuration][:azure][:kylin])).nil?) && (not "#{node[:deploycode][:configuration][:azure][:kylin]}" == "")
  kylin = node[:deploycode][:configuration][:azure][:kylin]
end
identifier = kylin[:identifier]

# Name of docker container is not imaport, just make one
container_name = "#{node[:projectname]}_azure_#{identifier}"
# Aggregating operations into image, default = container_name
image_name = container_name

# Define committing docker images
execute "commit_docker" do
	command "docker stop #{container_name};docker commit #{container_name} #{image_name}_tmp;docker rm #{container_name};docker rmi #{image_name};docker tag #{image_name}_tmp #{image_name};docker rmi #{image_name}_tmp"
    action :nothing
end

## Writing deployment info into host

# Create directory
if (not (defined?(kylin)).nil?) && (not "#{kylin}" == "")
  directory "#{basedir}azure/#{identifier}" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end

  # Setting parameters
  if kylin[:clusterName].eql?("default")
    clusterName = "cluster#{kylin[:identifier]}"
  else
    clusterName = kylin[:clusterName]
  end

  if kylin[:containerName].eql?("default")
    containerName = "container#{kylin[:identifier]}"
  else
    containerName = kylin[:containerName]
  end

  if kylin[:metastoreName].eql?("default")
    metastoreName = "metastore#{kylin[:identifier]}"
  else
    metastoreName = kylin[:metastoreName]
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
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => kylin[:clusterType],
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :location => kylin[:region],
        :metastoreName => metastoreName,
        :sshUserName => kylin[:sshUserName],
        :sshPassword => kylin[:sshPassword],
        :storageAccount => "#{kylin[:identifier]}sa"
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
end

#execute "removeimage_if_exists" do
#    command "if [ `docker images|awk {'print $NF'}|grep \'^#{image_name}$\'|wc -l` == \'1\' ];then docker rmi #{image_name};fi"
#end

## Begin execution of deployment

execute "createimageifnotexist_removecontainerifexist" do
    command "if [ `docker images|awk {'print $1'}|grep \'^#{image_name}$\'|wc -l` != \'1\' ];then docker tag #{runtime[:image]}:#{runtime[:tag]} #{image_name};fi;if [ `docker ps -a|awk {'print $NF'}|grep \'^#{container_name}$\'|wc -l` == \'1\' ];then docker stop #{container_name}||true;docker rm #{container_name}||true;fi"
end

# Reinit azure docker_container
deploymentmode = ""
if (not (defined?(credentials[:username])).nil?) && (not "#{credentials[:username]}" == "")
  deploymentmode = "username"
  if (not (defined?(credentials[:env])).nil?) && (not "#{credentials[:env]}" == "")
    envstring = "--environment #{credentials[:env]}"
  else
    envstring = ""
  end
  execute 'login' do
    command "docker run --name #{container_name} #{image_name} azure login --username #{credentials[:username]} --password #{credentials[:password]} #{envstring}"
      notifies :run, 'execute[commit_docker]', :immediately
  end
elsif (not (defined?(credentials[:token])).nil?) && (not "#{credentials[:token]}" == "")
  deploymentmode = "token"
  directory "#{basedir}azure/#{identifier}/azure" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end
  ruby_block "writetokenfile" do
    block do
      require 'json'
      File.open("#{basedir}azure/#{identifier}/azure/accessTokens.json","w") do |f|
        f.puts(credentials[:token].to_json)
      end
      f.puts("")
      #require 'pp'
      #$stdout = File.open("#{basedir}azure/#{identifier}/azure/accessTokens.json", 'w')
      #pp credentials[:token]
    end
  end
  ruby_block "writeprofilefile" do
    block do
      require 'json'
      File.open("#{basedir}azure/#{identifier}/azure/azureProfile.json","w") do |f|
        f.puts(credentials[:profile].to_json)
      end
      f.puts("")
      #$stdout = File.open("#{basedir}azure/#{identifier}/azure/azureProfile.json", 'w')
      #pp credentials[:profile]
    end
  end
  # execute "writeconfigjson" do
  #   command "echo {\\\"mode\\\"\: \\\"arm\\\"} >> #{basedir}azure/#{identifier}/azure/config.json"
  # end
  execute "writetelemetryjson" do
    command "echo {\\\"telemetry\\\"\: \\\"false\\\"} >> #{basedir}azure/#{identifier}/azure/telemetry.json"
  end
end

if (not (defined?(kylin)).nil?) && (not "#{kylin}" == "")
  mapvolume = ""
  if deploymentmode.eql?("token")
    mapvolume = "-v #{basedir}azure/#{identifier}/azure:$HOME/.azure"
  end
  execute 'config_arm_mode' do
    command "docker run --name #{container_name} #{mapvolume} #{image_name} azure config mode arm || true"
    notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end

  # Create resources group
  execute 'create_resources_group' do
    command "docker run --name #{container_name} #{mapvolume} #{image_name} azure group create -n kylin#{identifier} -l #{kylin[:region]} || true"
    notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end
  # Running deploymentTemplate
  results = "#{basedir}azure/#{identifier}/kylin#{identifier}_deploy.log"
  file results do
    action :delete
  end
  cmd = "docker run #{mapvolume} -v #{basedir}azure/#{identifier}:/templates --name #{container_name} #{image_name} azure group deployment create -g kylin#{identifier} -n kylin#{identifier} -f /templates/deploymentTemplate.#{identifier}.json -e /templates/deploymentTemplate.#{identifier}.parameters.json"
  bash cmd do
    code <<-EOH
    #{cmd} &> #{results}
    EOH
    notifies :run, 'execute[commit_docker]', :immediately
    timeout 21600
  end
end
