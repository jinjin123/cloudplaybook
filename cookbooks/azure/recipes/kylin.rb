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

azureaction = node[:deploycode][:configuration][:azure][:action]
# storing kylin variables to be called
if not ((not (defined?(azureaction)).nil?) && (not "#{azureaction}" == ""))
  azureaction = "create"
end

credentials = node[:deploycode][:configuration][:azure][:credentials]

# Setting basedir to store template files
basedir = node[:deploycode][:basedirectory]
username = node[:deployuser]
#runtime = node[:deploycode][:runtime][:azure]

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
# execute "commit_docker" do
# 	command "docker stop #{container_name};docker commit #{container_name} #{image_name}_tmp;docker rm #{container_name};docker rmi #{image_name};docker tag #{image_name}_tmp #{image_name};docker rmi #{image_name}_tmp"
#     action :nothing
# end

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
    accountregion = "china"
  else
    accountregion = "global"
  end
  if (not (defined?(kylin[:storageAccount])).nil?) && (not "#{kylin[:storageAccount]}" == "")
    storageAccount = kylin[:storageAccount]
  else
    storageAccount = "#{kylin[:identifier]}sa"
  end

  template "#{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json" do
    source "deploywithcluster.json.erb"
    variables(
      :accountregion => accountregion
    )
    mode 0644
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end
  template "#{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json" do
    source "deploywithcluster.parameters.json.erb"
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
      :storageAccount => storageAccount
    )
    mode 0644
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end
end

#execute "removeimage_if_exists" do
#    command "if [ `docker images|awk {'print $NF'}|grep \'^#{image_name}$\'|wc -l` == \'1\' ];then docker rmi #{image_name};fi"
#end

## Begin execution of deployment

# execute "createimageifnotexist_removecontainerifexist" do
#     command "if [ `docker images|awk {'print $1'}|grep \'^#{image_name}$\'|wc -l` != \'1\' ];then docker tag #{runtime[:image]}:#{runtime[:tag]} #{image_name};fi;if [ `docker ps -a|awk {'print $NF'}|grep \'^#{container_name}$\'|wc -l` == \'1\' ];then docker stop #{container_name}||true;docker rm #{container_name}||true;fi"
# end

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
    command "azure login --username #{credentials[:username]} --password #{credentials[:password]} #{envstring}"
      # notifies :run, 'execute[commit_docker]', :immediately
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
    # command "docker run --name #{container_name} #{mapvolume} #{image_name} azure config mode arm || true"
    command "azure config mode arm || true"
    # notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end

  # case when azureaction
  if azureaction.eql?("create")
    # Create resources group
    execute 'create_resources_group' do
      # command "docker run --name #{container_name} #{mapvolume} #{image_name} azure group create -n #{identifier} -l #{kylin[:region]} || true"
      command "azure group create -n #{identifier} -l #{kylin[:region]} || :"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    # Running deploymentTemplate
    results = "#{basedir}azure/#{identifier}/#{identifier}_deploy.log"
    file results do
      action :delete
    end
    cmd = "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json -e #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json"
    # cmd = "docker run #{mapvolume} -v #{basedir}azure/#{identifier}:/templates --name #{container_name} #{image_name} azure group deployment create -g #{identifier} -n #{identifier} -f /templates/deploymentTemplate.#{identifier}.json -e /templates/deploymentTemplate.#{identifier}.parameters.json"
    bash cmd do
      code <<-EOH
      #{cmd}
      EOH
      #{cmd} &> #{results}
      # notifies :run, 'execute[commit_docker]', :immediately
      timeout 21600
    end
  elsif azureaction.eql?("removehdi")
    execute 'removehdi_resources_group' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-uninstall-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_uninstall_v0.sh -t edgenode -p #{kylin[:appType]} >> /root/.azure/azure.details.log"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    execute 'removehdi_hdinsight' do
      command "azure hdinsight cluster delete #{clusterName} -g #{identifier} >> /root/.azure/azure.details.log"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("removeall")
    execute 'remove_resources_group' do
      command "sh -c \"echo \\\"y\\\" |azure group delete #{identifier}\" >> /root/.azure/azure.details.log"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("resize")
    execute 'resize_resources_group' do
      command "azure hdinsight cluster resize #{clusterName} -g #{identifier} #{kylin[:clusterWorkerNodeCount]} >> /root/.azure/azure.details.log"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("upgrade") do
    execute 'upgradekap' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-upgrade-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_upgrade_v0.sh -t edgenode -p \"#{kylin[:appType]} #{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{kylin[:metastoreName]}\" >> /root/.azure/azure.details.log"
    end
  end
  end
end
