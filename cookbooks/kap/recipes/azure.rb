#
# Cookbook Name:: kap
# Recipe:: azure
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
require File.expand_path('../comm.rb', __FILE__)

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

# Adding custom log
processlog = "#{basedir}progress.log"
returnflagfile = "/tmp/kap_process_success"

#runtime = node[:deploycode][:runtime][:azure]

# storing kylin variables to be called
if (not (defined?(azure[:kylin])).nil?) && (not "#{azure[:kylin]}" == "")
  kylin = azure[:kylin]
end
identifier = kylin[:identifier]

#function: output result log of important operation to processlog
def result_log(identifier, message, processlog, returnflagfile)
  logprefix = get_log_prefix(identifier)
  execute "operation_success" do
    command "echo '#{logprefix} #{message} result:[success]' >> #{processlog}"
    only_if { ::File.exist?(returnflagfile)}
  end
  execute "operation_failed" do
    command "echo '#{logprefix} #{message} result:[failed]' >> #{processlog}"
    not_if { ::File.exist?(returnflagfile)}
  end
  file "#{returnflagfile}" do
    action :delete
    ignore_failure true
  end
end

# just put the message to procees log without check the returnflagfile
def result_pure_log(identifier, message, processlog)
  logprefix = get_log_prefix(identifier)
  execute "result_pure_log" do
    command "echo '#{logprefix} #{message}' >> #{processlog}"
  end
end

# Removing token and
execute "removecredentials" do
  command "rm -rf /root/.azure/*"
  ignore_failure true
end

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

  ## Setting of variables
  kaptoken = ''
  if (not (defined?(kylin[:kaptoken])).nil?) && (not "#{kylin[:kaptoken]}" == "")
    kaptoken = kylin[:kaptoken]
  end
  kapagentid = ""
  if (not (defined?(kylin[:kapagentid])).nil?) && (not "#{kylin[:kapagentid]}" == "")
    kapagentid = kylin[:kapagentid]
  end

  # Check scheme that to be deployed
  if scheme.eql?("allinone")
    # Setting parameters
    clusterName = "cluster#{kylin[:identifier]}"
    if (not (defined?(kylin[:clusterName])).nil?) && (not "#{kylin[:clusterName]}" == "")
      if ! kylin[:clusterName].eql?("default")
        clusterName = kylin[:clusterName]
      end
    end

    containerName = "container#{kylin[:identifier]}"
    if (not (defined?(kylin[:containerName])).nil?) && (not "#{kylin[:containerName]}" == "")
      if ! kylin[:containerName].eql?("default")
        containerName = kylin[:containerName]
      end
    end

    metastoreName = "metastore#{kylin[:identifier]}"
    if (not (defined?(kylin[:metastoreName])).nil?) && (not "#{kylin[:metastoreName]}" == "")
      if ! kylin[:metastoreName].eql?("default")
        metastoreName = kylin[:metastoreName]
      end
    end

    if (not (defined?(kylin[:storageAccount])).nil?) && (not "#{kylin[:storageAccount]}" == "")
      storageAccount = kylin[:storageAccount]
    else
      storageAccount = "#{kylin[:identifier]}sa"
    end

    sshUserName = "admintest"
    if (not (defined?(kylin[:sshUserName])).nil?) && (not "#{kylin[:sshUserName]}" == "")
      if ! kylin[:sshUserName].eql?("default")
        sshUserName = kylin[:sshUserName]
      end
    end
    sshPassword = "Kyligence2016"
    if (not (defined?(kylin[:sshPassword])).nil?) && (not "#{kylin[:sshPassword]}" == "")
      if ! kylin[:sshPassword].eql?("default")
        sshPassword = kylin[:sshPassword]
      end
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
        :sshUserName => sshUserName,
        :sshPassword => sshPassword,
        :storageAccount => storageAccount,
        :kaptoken => kaptoken,
        :kapagentid => kapagentid
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
  elsif scheme.eql?("allinonevnet")
    clusterType1 = "hbase"
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
    storageaccount1 = "#{kylin[:identifier]}sa"
    if (not (defined?(kylin[:storageaccount])).nil?) && (not "#{kylin[:storageaccount]}" == "")
      if ! kylin[:storageaccount].eql?("default")
        storageaccount1 = kylin[:storageaccount]
      end
    end
    if (not (defined?(kylin[:storageaccount1])).nil?) && (not "#{kylin[:storageaccount1]}" == "")
      if ! kylin[:storageaccount1].eql?("default")
        storageaccount1 = kylin[:storageaccount1]
      end
    end
    sqlvirtualMachinesname = "sqlvm#{kylin[:identifier][0...10]}"
    if (not (defined?(kylin[:sqlvirtualMachinesname])).nil?) && (not "#{kylin[:sqlvirtualMachinesname]}" == "")
      if ! kylin[:sqlvirtualMachinesname].eql?("default")
        sqlvirtualMachinesname = kylin[:sqlvirtualMachinesname]
      end
    end

    sqlnetworkInterfacesname = "sqlnetint#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlnetworkInterfacesname])).nil?) && (not "#{kylin[:sqlnetworkInterfacesname]}" == "")
      if ! kylin[:sqlnetworkInterfacesname].eql?("default")
        sqlnetworkInterfacesname = kylin[:sqlnetworkInterfacesname]
      end
    end

    sqlnetworkSecurityGroupsname = "sqlnetsg#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlnetworkSecurityGroupsname])).nil?) && (not "#{kylin[:sqlnetworkSecurityGroupsname]}" == "")
      if ! kylin[:sqlnetworkSecurityGroupsname].eql?("default")
        sqlnetworkSecurityGroupsname = kylin[:sqlnetworkSecurityGroupsname]
      end
    end

    sqlpublicIPAddressesipname = "sqlpublicip#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlpublicIPAddressesipname])).nil?) && (not "#{kylin[:sqlpublicIPAddressesipname]}" == "")
      if ! kylin[:sqlpublicIPAddressesipname].eql?("default")
        sqlpublicIPAddressesipname = kylin[:sqlpublicIPAddressesipname]
      end
    end

    sshUserName = "admintest"
    if (not (defined?(kylin[:sshUserName])).nil?) && (not "#{kylin[:sshUserName]}" == "")
      if ! kylin[:sshUserName].eql?("default")
        sshUserName = kylin[:sshUserName]
      end
    end
    sshPassword = "Kyligence2016"
    if (not (defined?(kylin[:sshPassword])).nil?) && (not "#{kylin[:sshPassword]}" == "")
      if ! kylin[:sshPassword].eql?("default")
        sshPassword = kylin[:sshPassword]
      end
    end

    clusterName = "cluster#{kylin[:identifier]}"
    if (not (defined?(kylin[:clusterName])).nil?) && (not "#{kylin[:clusterName]}" == "")
      if ! kylin[:clusterName].eql?("default")
        clusterName = kylin[:clusterName]
      end
    end
    containerName = "container#{kylin[:identifier]}"
    if (not (defined?(kylin[:containerName])).nil?) && (not "#{kylin[:containerName]}" == "")
      if ! kylin[:containerName].eql?("default")
        containerName = kylin[:containerName]
      end
    end

    metastoreName = "metastore#{kylin[:identifier]}"
    if (not (defined?(kylin[:metastoreName])).nil?) && (not "#{kylin[:metastoreName]}" == "")
      if ! kylin[:metastoreName].eql?("default")
        metastoreName = kylin[:metastoreName]
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

    template "#{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json" do
      source "sqlserver.parameters.json.erb"
      variables(
        :sqlvirtualMachinesname => sqlvirtualMachinesname,
        :sqldatabaseName => clusterName,
        :adminUsername => sshUserName,
        :adminPassword => sshPassword
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end

    template "#{basedir}azure/#{identifier}/singlehdi.#{identifier}.json" do
      source "singlehdi.json.erb"
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
    # Creating first cluster, hbase HDI node
    storageaccount2 = ""
    template "#{basedir}azure/#{identifier}/singlehdi.parameters.#{identifier}.json" do
      source "singlehdi.parameters.json.erb"
      variables(
        :appType => kylin[:appType],
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => clusterType1,
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :location => kylin[:region],
        :metastoreName => metastoreName,
        :sshUserName => sshUserName,
        :sshPassword => sshPassword,
        :storageAccount1 => storageaccount1,
        :sqlvirtualMachinesname => sqlvirtualMachinesname,
        :vnetName => vnetName,
        :subnet1Name => subnet1Name,
        :databaseName => clusterName,
        :kaptoken => kaptoken,
        :kapagentid => kapagentid
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end

  elsif scheme.eql?("separated")

    clusterType1 = "hbase"
    clusterType2 = "hadoop"

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
    storageaccount1 = "#{kylin[:identifier]}sa"
    if (not (defined?(kylin[:storageaccount])).nil?) && (not "#{kylin[:storageaccount]}" == "")
      if ! kylin[:storageaccount].eql?("default")
        storageaccount1 = kylin[:storageaccount]
      end
    end
    if (not (defined?(kylin[:storageaccount1])).nil?) && (not "#{kylin[:storageaccount1]}" == "")
      if ! kylin[:storageaccount1].eql?("default")
        storageaccount1 = kylin[:storageaccount1]
      end
    end
    # Setting storageaccount2 if not set
    storageaccount2 = "#{kylin[:identifier]}saw"
    if (not (defined?(kylin[:storageaccount])).nil?) && (not "#{kylin[:storageaccount]}" == "")
      if ! kylin[:storageaccount].eql?("default")
        storageaccount2 = kylin[:storageaccount]
      end
    end
    if (not (defined?(kylin[:storageaccount2])).nil?) && (not "#{kylin[:storageaccount2]}" == "")
      if ! kylin[:storageaccount2].eql?("default")
        storageaccount2 = kylin[:storageaccount2]
      end
    end

    sqlvirtualMachinesname = "sqlvm#{kylin[:identifier][0...10]}"
    if (not (defined?(kylin[:sqlvirtualMachinesname])).nil?) && (not "#{kylin[:sqlvirtualMachinesname]}" == "")
      if ! kylin[:sqlvirtualMachinesname].eql?("default")
        sqlvirtualMachinesname = kylin[:sqlvirtualMachinesname]
      end
    end

    sqlnetworkInterfacesname = "sqlnetint#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlnetworkInterfacesname])).nil?) && (not "#{kylin[:sqlnetworkInterfacesname]}" == "")
      if ! kylin[:sqlnetworkInterfacesname].eql?("default")
        sqlnetworkInterfacesname = kylin[:sqlnetworkInterfacesname]
      end
    end

    sqlnetworkSecurityGroupsname = "sqlnetsg#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlnetworkSecurityGroupsname])).nil?) && (not "#{kylin[:sqlnetworkSecurityGroupsname]}" == "")
      if ! kylin[:sqlnetworkSecurityGroupsname].eql?("default")
        sqlnetworkSecurityGroupsname = kylin[:sqlnetworkSecurityGroupsname]
      end
    end

    sqlpublicIPAddressesipname = "sqlpublicip#{kylin[:identifier]}"
    if (not (defined?(kylin[:sqlpublicIPAddressesipname])).nil?) && (not "#{kylin[:sqlpublicIPAddressesipname]}" == "")
      if ! kylin[:sqlpublicIPAddressesipname].eql?("default")
        sqlpublicIPAddressesipname = kylin[:sqlpublicIPAddressesipname]
      end
    end

    sshUserName = "admintest"
    if (not (defined?(kylin[:sshUserName])).nil?) && (not "#{kylin[:sshUserName]}" == "")
      if ! kylin[:sshUserName].eql?("default")
        sshUserName = kylin[:sshUserName]
      end
    end
    sshPassword = "Kyligence2016"
    if (not (defined?(kylin[:sshPassword])).nil?) && (not "#{kylin[:sshPassword]}" == "")
      if ! kylin[:sshPassword].eql?("default")
        sshPassword = kylin[:sshPassword]
      end
    end

    clusterName = "cluster#{kylin[:identifier]}"
    if (not (defined?(kylin[:clusterName])).nil?) && (not "#{kylin[:clusterName]}" == "")
      if ! kylin[:clusterName].eql?("default")
        clusterName = kylin[:clusterName]
      end
    end

    clusterName2 = "write#{clusterName}"
    if (not (defined?(kylin[:clusterName2])).nil?) && (not "#{kylin[:clusterName2]}" == "")
      if ! kylin[:clusterName2].eql?("default")
        clusterName2 = kylin[:clusterName2]
      end
    end

    containerName = "container#{kylin[:identifier]}"
    if (not (defined?(kylin[:containerName])).nil?) && (not "#{kylin[:containerName]}" == "")
      if ! kylin[:containerName].eql?("default")
        containerName = kylin[:containerName]
      end
    end

    metastoreName = "metastore#{kylin[:identifier]}"
    if (not (defined?(kylin[:metastoreName])).nil?) && (not "#{kylin[:metastoreName]}" == "")
      if ! kylin[:metastoreName].eql?("default")
        metastoreName = kylin[:metastoreName]
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

    template "#{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json" do
      source "sqlserver.parameters.json.erb"
      variables(
        :sqlvirtualMachinesname => sqlvirtualMachinesname,
        :sqldatabaseName => clusterName,
        :adminUsername => sshUserName,
        :adminPassword => sshPassword
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end

    template "#{basedir}azure/#{identifier}/separatedhdi.#{identifier}.json" do
      source "separatedhdi.json.erb"
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
    # Creating first cluster, hbase HDI node
    template "#{basedir}azure/#{identifier}/separatedhdi1.parameters.#{identifier}.json" do
      source "separatedhdi.parameters.json.erb"
      variables(
        :appType => kylin[:appType],
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => clusterType1,
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :location => kylin[:region],
        :metastoreName => metastoreName,
        :sshUserName => sshUserName,
        :sshPassword => sshPassword,
        :storageAccount1 => storageaccount1,
        :storageAccount2 => storageaccount2,
        :sqlvirtualMachinesname => sqlvirtualMachinesname,
        :vnetName => vnetName,
        :subnet1Name => subnet1Name,
        :databaseName => clusterName,
        :kaptoken => kaptoken,
        :kapagentid => kapagentid
      )
      mode 0644
      retries 3
      retry_delay 2
      owner "root"
      group "root"
      action :create
    end
    # Creating second cluster, hadoop HDI node
    template "#{basedir}azure/#{identifier}/separatedhdi2.parameters.#{identifier}.json" do
      source "separatedhdi.parameters.json.erb"
      variables(
        :appType => 'KAP',
        :clusterName  => clusterName2,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => clusterType2,
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :location => kylin[:region],
        :metastoreName => metastoreName,
        :sshUserName => sshUserName,
        :sshPassword => sshPassword,
        :storageAccount1 => storageaccount2,
        :storageAccount2 => storageaccount1,
        :sqlvirtualMachinesname => sqlvirtualMachinesname,
        :vnetName => vnetName,
        :subnet1Name => subnet1Name,
        :databaseName => clusterName,
        :kaptoken => kaptoken,
        :kapagentid => kapagentid
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
#output log if success
logprefix = get_log_prefix(identifier)
execute "scheme_allinone_log" do
  command "echo \"#{logprefix} scheme[#{scheme}]: basic files and directory create success\"  >> #{processlog}"
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
# Prepare credential directory
directory "#{basedir}azure/#{identifier}/azure" do
  owner username
  group username
  mode '0755'
  recursive true
  action :create
end

if (not (defined?(credentials[:username])).nil?) && (not "#{credentials[:username]}" == "")
  deploymentmode = "username"
  if (not (defined?(credentials[:env])).nil?) && (not "#{credentials[:env]}" == "")
    envstring = "--environment #{credentials[:env]}"
  else
    envstring = ""
  end

  #add process log here
  execute 'login' do
    command "azure login --username #{credentials[:username]} --password #{credentials[:password]} #{envstring} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end
  # login result log
  result_log(identifier, "use username and password to login azure", processlog, returnflagfile)


elsif (not (defined?(credentials[:token])).nil?) && (not "#{credentials[:token]}" == "")
  deploymentmode = "token"
  tokenjson1 = Chef::JSONCompat.to_json_pretty(credentials[:token][0].to_hash)
  tokenjson2 = Chef::JSONCompat.to_json_pretty(credentials[:token][1].to_hash)
  file "/root/.azure/tempTokens.json" do
    content tokenjson1 + ",\n" + tokenjson2
  end
  execute "modifyformat" do
    command "sed -i 's/^/  /g' /root/.azure/tempTokens.json;echo '[' > /root/.azure/accessTokens.json;cat /root/.azure/tempTokens.json >> /root/.azure/accessTokens.json;echo '' >> /root/.azure/accessTokens.json;echo \"\\\n\"']' >> /root/.azure/accessTokens.json;rm -f /root/.azure/tempTokens.json"
  end

  ruby_block "writeprofilefile" do
    block do
      require 'json'
      File.open("/root/.azure/azureProfile.json","w") do |f|
        f.puts(credentials[:profile].to_json)
      end
      #$stdout = File.open("#{basedir}azure/#{identifier}/azure/azureProfile.json", 'w')
      #pp credentials[:profile]
    end
  end
  execute "chaningpermission" do
    command "chmod 400 /root/.azure/azureProfile.json;chmod 400 /root/.azure/accessTokens.json"
  end

  result_pure_log(identifier, "use credential token login result:[success]", processlog)

end

# Setting basic config for azure
execute "writeconfigjson" do
  command "echo {\\\"mode\\\"\: \\\"arm\\\"} > /root/.azure/config.json"
end
# execute "writetelemetryjson" do
#   command "echo {\\\"telemetry\\\"\: \\\"false\\\"} > /root/.azure/telemetry.json"
# end


if (not (defined?(kylin)).nil?) && (not "#{kylin}" == "")
  # mapvolume = ""
  # if deploymentmode.eql?("token")
  #   mapvolume = "-v #{basedir}azure/#{identifier}/azure:$HOME/.azure"
  # end
  # execute 'config_arm_mode' do
  #   # command "docker run --name #{container_name} #{mapvolume} #{image_name} azure config mode arm || true"
  #   command "azure config mode arm || true"
  #   # notifies :run, 'execute[commit_docker]', :immediately
  #   #ignore_failure true
  # end

  # case when azureaction
  if azureaction.include?("create")
    result_pure_log(identifier, "azure resouces create begin ...", processlog)
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

    execute 'disabletelemetry' do
      command "azure telemetry --enable >> /root/.azure/azure.err && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(identifier, "azure enable telemetry", processlog, returnflagfile)

    if scheme.eql?("allinone")
      result_pure_log(identifier, "allinone deployment begin...", processlog)
      execute 'create_deployment' do
        command "azure group deployment create -g #{identifier} -n create_deployment -f #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json -e #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create by scheme allinon", processlog, returnflagfile)
    elsif scheme.eql?("allinonevnet")
      result_pure_log(identifier, "allinonevnet deployment begin...", processlog)
      execute 'create_vnet' do
        command "azure group deployment create -g #{identifier} -n create_vnet -f #{basedir}azure/#{identifier}/vnet.#{identifier}.json -e #{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        #notifies :run, 'execute[progress_vnetcompleted]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create vnet scheme allinonevnet", processlog, returnflagfile)
      execute 'create_storageaccount1' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount1 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create storageaccount1 with scheme allinonevnet", processlog, returnflagfile)
      execute 'create_sqlserver' do
        command "azure group deployment create -g #{identifier} -n create_sqlserver -f #{basedir}azure/#{identifier}/sqlserver.#{identifier}.json -e #{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json -vv >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create sqlserver with scheme allinonevnet", processlog, returnflagfile)
      execute 'create_hdi1' do
        command "azure group deployment create -g #{identifier} -n create_hdi1 -f #{basedir}azure/#{identifier}/singlehdi.#{identifier}.json -e #{basedir}azure/#{identifier}/singlehdi.parameters.#{identifier}.json -vv >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create hdi1 with scheme allinonevnet", processlog, returnflagfile)
      execute 'config_hdi1' do
        command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-hdi1-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP-install_v0.sh -t edgenode -p \"#{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{metastoreName} #{kylin[:appType]} #{clusterName} #{kaptoken} #{kapagentid}\" >> /root/.azure/azure.err && touch #{returnflagfile}"
        ignore_failure true
      end
      result_log(identifier, "azure group deployment config hdi1 with scheme allinonevnet", processlog, returnflagfile)

    elsif scheme.eql?("separated")
      result_pure_log(identifier, "separated deployment begin...", processlog)
      execute 'create_vnet' do
        command "azure group deployment create -g #{identifier} -n create_vnet -f #{basedir}azure/#{identifier}/vnet.#{identifier}.json -e #{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create vnet by sheme separated", processlog, returnflagfile)
      execute 'create_storageaccount1' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount1 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create storageaccount1 by sheme separated", processlog, returnflagfile)
      execute 'create_storageaccount2' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount2 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount2.#{identifier}.parameters.json >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create storageaccount2 by sheme separated", processlog, returnflagfile)
      execute 'create_sqlserver' do
        command "azure group deployment create -g #{identifier} -n create_sqlserver -f #{basedir}azure/#{identifier}/sqlserver.#{identifier}.json -e #{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json -vv >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create sqlserver by sheme separated", processlog, returnflagfile)
      execute 'create_hdi1' do
        command "azure group deployment create -g #{identifier} -n create_hdi1 -f #{basedir}azure/#{identifier}/separatedhdi.#{identifier}.json -e #{basedir}azure/#{identifier}/separatedhdi1.parameters.#{identifier}.json -vv >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure group deployment create hdi1 by sheme separated", processlog, returnflagfile)
      execute 'config_hdi1' do
        command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-hdi1-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_separateread_v0.sh -t edgenode >> /root/.azure/azure.err && touch #{returnflagfile}"
        ignore_failure true
      end
      result_log(identifier, "azure group deployment config hdi1 by sheme separated", processlog, returnflagfile)
      if ! azureaction.include?("read")
        result_pure_log(identifier, "azure cluster seperate read and write, hdi2 create begin ...", processlog)
        execute 'create_hdi2' do
          command "azure group deployment create -g #{identifier} -n create_hdi2 -f #{basedir}azure/#{identifier}/separatedhdi.#{identifier}.json -e #{basedir}azure/#{identifier}/separatedhdi2.parameters.#{identifier}.json -vv >> /root/.azure/azure.err && touch #{returnflagfile}"
          # notifies :run, 'execute[commit_docker]', :immediately
          ignore_failure true
        end
        result_log(identifier, "azure group deployment create hdi2 by sheme separated", processlog, returnflagfile)
        execute 'config_hdi2' do
          command "azure hdinsight script-action create #{clusterName2} -g #{identifier} -n KAP-hdi2-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_separateread_v0_writecluster.sh -t edgenode -p \"#{containerName} #{storageaccount1} #{accountregion}\" >> /root/.azure/azure.err && touch #{returnflagfile}"
          ignore_failure true
        end
        result_log(identifier, "azure group deployment config hdi2 by sheme separated", processlog, returnflagfile)
      end
    end
  elsif azureaction.eql?("removehdi")
    result_pure_log(identifier, "azure resouces removehdi begin ...", processlog)
    execute 'removehdi_resources_group' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-uninstall-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_uninstall_v0.sh -t edgenode -p #{kylin[:appType]} >> /root/.azure/azure.err && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(identifier, "azure hdinsight script-action create", processlog, returnflagfile)
    execute 'removehdi_hdinsight' do
      command "azure hdinsight cluster delete #{clusterName} -g #{identifier} >> /root/.azure/azure.err && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(identifier, "azure hdinsight hdinsight cluster delete", processlog, returnflagfile)
    if scheme.eql?("separated")
      result_pure_log(identifier, "hdinsight clushter is separated. begin remove hdinsight2...", processlog)
      execute 'removehdi_hdinsight2' do
        command "azure hdinsight cluster delete #{clusterName2} -g #{identifier} >> /root/.azure/azure.err && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(identifier, "azure hdinsight2 cluster delete", processlog, returnflagfile)
    end
  elsif azureaction.eql?("removeall")
    result_pure_log(identifier, "azure group removeall begin...", processlog)
    execute 'remove_resources_group' do
      command "azure group show #{identifier} > /root/.azure/check.txt || : ;NUM=`cat /root/.azure/check.txt| grep OK | wc -l|xargs`;if [ \"$NUM\" -ne \"0\" ];then azure group delete #{identifier} -q >> /root/.azure/azure.err;else echo \"Resource group #{identifier} not exists\">> /root/.azure/azure.err;fi"
      # notifies :run, 'execute[commit_docker]', :immediately
      #ignore_failure true
    end
  elsif azureaction.eql?("resize")
    execute 'resize_resources_group' do
      command "azure hdinsight cluster resize #{clusterName} -g #{identifier} #{kylin[:clusterWorkerNodeCount]} >> /root/.azure/azure.err && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(identifier, "azure hdinsight cluster resize", processlog, returnflagfile)
  elsif azureaction.eql?("upgrade")
    execute 'upgradekap' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-upgrade-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_upgrade_v0.sh -t edgenode -p \"#{kylin[:appType]} #{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{kylin[:metastoreName]}\" >> /root/.azure/azure.err"
      #ignore_failure true
    end
  end
end

=begin
execute 'progress_vnetcompleted' do
  command "echo \"Identifier: #{identifier}; Creation of Vnet succeed\" >> #{progresslog}"
  action :nothing
end
=end
