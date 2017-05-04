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

azure = node[:deploycode][:configuration][:azure]

azureaction = azure[:action]
# storing kylin variables to be called
if not ((not (defined?(azureaction)).nil?) && (not "#{azureaction}" == ""))
  azureaction = "create"
end

credentials = azure[:credentials]

# Setting basedir to store template files
basedir = node[:deploycode][:basedirectory]
username = node[:deployuser]
#runtime = node[:deploycode][:runtime][:azure]

# storing kylin variables to be called
if (not (defined?(azure[:kylin])).nil?) && (not "#{azure[:kylin]}" == "")
  kylin = azure[:kylin]
end
identifier = kylin[:identifier]

# Check what scheme, "allinone" or "separated" to be deployed
if (not (defined?(azure[:scheme])).nil?) && (not "#{azure[:scheme]}" == "")
  scheme = azure[:scheme]
else
  scheme = "allinone"
end

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

  if kylin[:region].downcase.include?("china")
    accountregion = "china"
  else
    accountregion = "global"
  end

  # Check scheme that to be deployed

  if scheme.eql?("allinone")

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
  elsif scheme.eql?("separated")

    # Setting vnetName if not set
    vnetName = "vnet#{kylin[:identifier]}"
    if (not (defined?(kylin[:vnetName])).nil?) && (not "#{kylin[:vnetName]}" == "")
      if ! kylin[:vnetName].eql?("default")
        vnetName = kylin[:vnetName]
      end
    end
    # Setting subnet1Name if not set
    subnet1Name = "subnet1#{kylin[:identifier]}"
    if (not (defined?(kylin[:subnet1Name])).nil?) && (not "#{kylin[:subnet1Name]}" == "")
      if ! kylin[:subnet1Name].eql?("default")
        subnet1Name = kylin[:subnet1Name]
      end
    end
    # Setting subnet2Name if not set
    subnet2Name = "subnet2#{kylin[:identifier]}"
    if (not (defined?(kylin[:subnet2Name])).nil?) && (not "#{kylin[:subnet2Name]}" == "")
      if ! kylin[:subnet2Name].eql?("default")
        subnet2Name = kylin[:subnet2Name]
      end
    end
    # Setting storageaccount1 if not set
    storageaccount1 = "sa1#{kylin[:identifier]}"
    if (not (defined?(kylin[:storageaccount1])).nil?) && (not "#{kylin[:storageaccount1]}" == "")
      if ! kylin[:storageaccount1].eql?("default")
        storageaccount1 = kylin[:storageaccount1]
      end
    end

    # Setting storageaccount2 if not set
    storageaccount2 = "sa2#{kylin[:identifier]}"
    if (not (defined?(kylin[:storageaccount2])).nil?) && (not "#{kylin[:storageaccount2]}" == "")
      if ! kylin[:storageaccount2].eql?("default")
        storageaccount1 = kylin[:storageaccount2]
      end
    end

    # Creating vnet json
    template "#{basedir}azure/#{identifier}/vnet.#{identifier}.json" do
      source "vnet.json.erb"
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
    template "#{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json" do
      source "vnet.parameters.json.erb"
      variables(
        :vnetName => vnetName,
        :subnet1Name  => subnet1Name,
        :subnet2Name => subnet2Name
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end

    # Create storageAcount templates
    template "#{basedir}azure/#{identifier}/storageaccount.#{identifier}.json" do
      source "storageaccount.json.erb"
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
    template "#{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json" do
      source "storageaccount.parameters.json.erb"
      variables(
        :storageAccountName => storageaccount1
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
    template "#{basedir}azure/#{identifier}/storageaccount2.#{identifier}.parameters.json" do
      source "storageaccount.parameters.json.erb"
      variables(
        :storageAccountName => storageaccount2
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end

    # Creating SQLserver
    template "#{basedir}azure/#{identifier}/sqlserver.#{identifier}.json" do
      source "sqlserver.json.erb"
      variables(
        :accountregion => accountregion,
        :storageAccountName => storageaccount1
      )
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
  # mapvolume = ""
  # if deploymentmode.eql?("token")
  #   mapvolume = "-v #{basedir}azure/#{identifier}/azure:$HOME/.azure"
  # end
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
    # results = "#{basedir}azure/#{identifier}/#{identifier}_deploy.log"
    # file results do
    #   action :delete
    # end
    # cmd = "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json -e #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json"
    # # cmd = "docker run #{mapvolume} -v #{basedir}azure/#{identifier}:/templates --name #{container_name} #{image_name} azure group deployment create -g #{identifier} -n #{identifier} -f /templates/deploymentTemplate.#{identifier}.json -e /templates/deploymentTemplate.#{identifier}.parameters.json"
    # bash cmd do
    #   code <<-EOH
    #   #{cmd}
    #   EOH
    #   #{cmd} &> #{results}
    #   # notifies :run, 'execute[commit_docker]', :immediately
    #   timeout 21600
    # end
    if scheme.eql?("allinone")
      execute 'create_deployment' do
        command "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json -e #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json >> /root/.azure/azure.err"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
    elsif scheme.eql?("separated")
      execute 'create_vnet' do
        command "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/vnet.#{identifier}.json -e #{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json >> /root/.azure/azure.err"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      execute 'create_storageaccount1' do
        command "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json -vv >> /root/.azure/azure.err"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      execute 'create_storageaccount2' do
        command "azure group deployment create -g #{identifier} -n #{identifier} -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount2.#{identifier}.parameters.json -vv >> /root/.azure/azure.err"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
    end
  elsif azureaction.eql?("removehdi")
    execute 'removehdi_resources_group' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-uninstall-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_uninstall_v0.sh -t edgenode -p #{kylin[:appType]} >> /root/.azure/azure.err"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    execute 'removehdi_hdinsight' do
      command "azure hdinsight cluster delete #{clusterName} -g #{identifier} >> /root/.azure/azure.err"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("removeall")
    execute 'remove_resources_group' do
      command "sh -c \"echo \\\"y\\\" |azure group delete #{identifier}\" >> /root/.azure/azure.err"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("resize")
    execute 'resize_resources_group' do
      command "azure hdinsight cluster resize #{clusterName} -g #{identifier} #{kylin[:clusterWorkerNodeCount]} >> /root/.azure/azure.err"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
  elsif azureaction.eql?("upgrade")
    execute 'upgradekap' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-upgrade-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_upgrade_v0.sh -t edgenode -p \"#{kylin[:appType]} #{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{kylin[:metastoreName]}\" >> /root/.azure/azure.err"
      ignore_failure true
    end
  end
end
