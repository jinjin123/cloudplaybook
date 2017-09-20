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


#runtime = node[:deploycode][:runtime][:azure]

# storing kylin variables to be called
if (not (defined?(azure[:kylin])).nil?) && (not "#{azure[:kylin]}" == "")
  kylin = azure[:kylin]
end
identifier = kylin[:identifier]

# fetch app info
if (not (defined?(kylin[:app])).nil?)
  appinfo = kylin[:app]
end

# add default value to appinfo
appType = "KAP+KyAnalyzer+Zeppelin"
if (not (defined?(appinfo[:appType])).nil?) && (not "#{appinfo[:appType]}" == "")
  appType = appinfo[:appType]
end

kapUrl = "https://kyhub.blob.core.chinacloudapi.cn/packages/kap/kap-2.4.4-GA-hbase1.x.tar.gz"
if (not (defined?(appinfo[:kapUrl])).nil?) && (not "#{appinfo[:kapUrl]}" == "")
  kapUrl = appinfo[:kapUrl]
end

kyanalyzerUrl = "https://kyhub.blob.core.chinacloudapi.cn/packages/kyanalyzer/KyAnalyzer-2.4.0.tar.gz"
if (not (defined?(appinfo[:KyAnalyzerUrl])).nil?) && (not "#{appinfo[:KyAnalyzerUrl]}" == "")
  kyanalyzerUrl＝appinfo = appinfo[:KyAnalyzerUrl]
end

zeppelinUrl = "https://kyhub.blob.core.chinacloudapi.cn/packages/zeppelin/zeppelin-0.8.0-kylin.tar.gz"
if (not (defined?(appinfo[:ZeppelinUrl])).nil?) && (not "#{appinfo[:ZeppelinUrl]}" == "")
  zeppelinUrl = appinfo[:ZeppelinUrl]
end



# Adding custom log
progresslog = "#{basedir}azure/#{identifier}/progress.log"
returnflagfile = "/tmp/kap_process_success"

azureerror = "/root/.azure/azure.err"
title0       = "### STEP 00: "
title1       = "### STEP 01: "
title2       = "### STEP 02: "
title3       = "### STEP 03: "
title4       = "### STEP 04: "
title5       = "### STEP 05: "
title6       = "### STEP 06: "
title7       = "### STEP 07: "
title8       = "### STEP 08: "
title9       = "### STEP 09: "
title10      = "### STEP 10: "
title11      = "### STEP 11: "
title12      = "### STEP 12: "
sampletitle  = "### STEP 00: "
emptytitle   = "             "
titleend     = "### FINISHED "
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
result_pure_log(title0, "begin deployment with clusterid : [#{identifier}]", progresslog)
result_pure_log(title1, "Prepare and validate deployment", progresslog)
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
        :appType => appType,
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => kylin[:clusterType],
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :workerNodeSize => kylin[:workerNodeSize],
        :location => kylin[:region],
        :metastoreName => metastoreName,
        :sshUserName => sshUserName,
        :sshPassword => sshPassword,
        :storageAccount => storageAccount,
        :kaptoken => kaptoken,
        :kapagentid => kapagentid,
        :kapurl => kapUrl,
        :kyanalyzerurl => kyanalyzerUrl,
        :zeppelinurl => zeppelinUrl
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
        :appType => appType,
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => clusterType1,
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :workerNodeSize => kylin[:workerNodeSize],
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
        :kapagentid => kapagentid,
        :kapurl => kapUrl,
        :kyanalyzerurl => kyanalyzerUrl,
        :zeppelinurl => zeppelinUrl
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
        :appType => appType,
        :clusterName  => clusterName,
        :clusterLoginUserName => kylin[:clusterLoginUserName],
        :clusterLoginPassword => kylin[:clusterLoginPassword],
        :clusterType => clusterType1,
        :clusterVersion => kylin[:clusterVersion],
        :clusterWorkerNodeCount => kylin[:clusterWorkerNodeCount],
        :containerName => containerName,
        :edgeNodeSize => kylin[:edgeNodeSize],
        :workerNodeSize => kylin[:workerNodeSize],
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
        :kapagentid => kapagentid,
        :kapurl => kapUrl,
        :kyanalyzerurl => kyanalyzerUrl,
        :zeppelinurl => zeppelinUrl
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
        :workerNodeSize => kylin[:workerNodeSize],
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
        :kapagentid => kapagentid,
        :kapurl => kapUrl,
        :kyanalyzerurl => kyanalyzerUrl,
        :zeppelinurl => zeppelinUrl
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
result_pure_log(emptytitle, "basic files and directory created success", progresslog)
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
result_pure_log(title2, "Login Azure", progresslog)
if (not (defined?(credentials[:username])).nil?) && (not "#{credentials[:username]}" == "")
  deploymentmode = "username"
  if (not (defined?(credentials[:env])).nil?) && (not "#{credentials[:env]}" == "")
    envstring = "--environment #{credentials[:env]}"
  else
    envstring = ""
  end
  execute 'login' do
    command "azure login --username #{credentials[:username]} --password #{credentials[:password]} #{envstring} >> #{azureerror} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
    ignore_failure true
  end
  result_log(identifier, "use username and password to login azure", progresslog, returnflagfile)
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
  result_pure_log(identifier, "use credential token login, prepare profile success.", progresslog)
end
result_pure_log(emptytitle, "Login Azure success", progresslog)
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
    # Create resources group
    result_pure_log(title3, "Create resource group ", progresslog)
    execute 'create_resources_group' do
      # command "docker run --name #{container_name} #{mapvolume} #{image_name} azure group create -n #{identifier} -l #{kylin[:region]} || true"
      command "azure group create -n #{identifier} -l #{kylin[:region]}"
      # notifies :run, 'execute[commit_docker]', :immediately
      #ignore_failure true
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
      command "azure telemetry --enable >> #{azureerror} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(emptytitle, "azure enable telemetry", progresslog, returnflagfile)
    if scheme.eql?("allinone")
      result_pure_log(title4, "Deploy all resource within one template", progresslog)
      execute 'create_deployment' do
        command "azure group deployment create -g #{identifier} -n create_deployment -f #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.json -e #{basedir}azure/#{identifier}/deploymentTemplate.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create by scheme allinon", progresslog, returnflagfile)
    elsif scheme.eql?("allinonevnet")
      result_pure_log(title4, "Create Vnet", progresslog)
      execute 'create_vnet' do
        command "azure group deployment create -g #{identifier} -n create_vnet -f #{basedir}azure/#{identifier}/vnet.#{identifier}.json -e #{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        notifies :run, 'execute[progress_vnetcompleted]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create vnet scheme allinonevnet", progresslog, returnflagfile)
      result_pure_log(title5, "Create Storage Account", progresslog)
      execute 'create_storageaccount1' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount1 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create storageaccount1 with scheme allinonevnet", progresslog, returnflagfile)
      result_pure_log(title6, "Create SQL Server for Hive", progresslog)
      execute 'create_sqlserver' do
        command "azure group deployment create -g #{identifier} -n create_sqlserver -f #{basedir}azure/#{identifier}/sqlserver.#{identifier}.json -e #{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json -vv >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create sqlserver with scheme allinonevnet", progresslog, returnflagfile)
      result_pure_log(title7, "Create HDInsight", progresslog)
      execute 'create_hdi1' do
        command "azure group deployment create -g #{identifier} -n create_hdi1 -f #{basedir}azure/#{identifier}/singlehdi.#{identifier}.json -e #{basedir}azure/#{identifier}/singlehdi.parameters.#{identifier}.json -vv >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create hdi1 with scheme allinonevnet", progresslog, returnflagfile)
      result_pure_log(title8, "Config HDInsight and Install KAP", progresslog)
      execute 'config_hdi1' do
        command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-hdi1-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP-install_v0.sh -t edgenode -p \"#{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{metastoreName} #{appType} #{clusterName} #{kaptoken} #{kapagentid} #{kapUrl} #{kyanalyzerUrl} #{zeppelinUrl}\" >> #{azureerror} && touch #{returnflagfile}"
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment config hdi1 with scheme allinonevnet", progresslog, returnflagfile)
    elsif scheme.eql?("separated")
      result_pure_log(title4, "Create Vnet", progresslog)
      execute 'create_vnet' do
        command "azure group deployment create -g #{identifier} -n create_vnet -f #{basedir}azure/#{identifier}/vnet.#{identifier}.json -e #{basedir}azure/#{identifier}/vnet.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create vnet by sheme separated", progresslog, returnflagfile)
      result_pure_log(title5, "Create Storage Account", progresslog)
      execute 'create_storageaccount1' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount1 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount1.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create normal storageaccount by sheme separated", progresslog, returnflagfile)
      execute 'create_storageaccount2' do
        command "azure group deployment create -g #{identifier} -n create_storageaccount2 -f #{basedir}azure/#{identifier}/storageaccount.#{identifier}.json -e #{basedir}azure/#{identifier}/storageaccount2.#{identifier}.parameters.json >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create write storage account by sheme separated", progresslog, returnflagfile)
      result_pure_log(title6, "Create SQL Server", progresslog)
      execute 'create_sqlserver' do
        command "azure group deployment create -g #{identifier} -n create_sqlserver -f #{basedir}azure/#{identifier}/sqlserver.#{identifier}.json -e #{basedir}azure/#{identifier}/sqlserver.parameters.#{identifier}.json -vv >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create sqlserver by sheme separated", progresslog, returnflagfile)
      result_pure_log(title7, "Create HDinsight", progresslog)
      execute 'create_hdi1' do
        command "azure group deployment create -g #{identifier} -n create_hdi1 -f #{basedir}azure/#{identifier}/separatedhdi.#{identifier}.json -e #{basedir}azure/#{identifier}/separatedhdi1.parameters.#{identifier}.json -vv >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment create hdi1 by sheme separated", progresslog, returnflagfile)
      result_pure_log(title8, "Config HDinsight", progresslog)
      execute 'config_hdi1' do
        command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-hdi1-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_separateread_v0.sh -t edgenode -p \"#{containerName} #{storageaccount1} #{storageaccount2} #{accountregion}\" >> #{azureerror} && touch #{returnflagfile}"
        ignore_failure true
      end
      result_log(emptytitle, "azure group deployment config hdi1 by sheme separated", progresslog, returnflagfile)
      if ! azureaction.include?("read")
        result_pure_log(title9, "Create HDinsight WriteCluster", progresslog)
        execute 'create_hdi2' do
          command "azure group deployment create -g #{identifier} -n create_hdi2 -f #{basedir}azure/#{identifier}/separatedhdi.#{identifier}.json -e #{basedir}azure/#{identifier}/separatedhdi2.parameters.#{identifier}.json -vv >> #{azureerror} && touch #{returnflagfile}"
          # notifies :run, 'execute[commit_docker]', :immediately
          ignore_failure true
        end
        result_log(emptytitle, "azure group deployment create hdi2 by sheme separated", progresslog, returnflagfile)
        result_pure_log(title10, "Config HDinsight WriteCluster", progresslog)
        execute 'config_hdi2' do
          command "azure hdinsight script-action create #{clusterName2} -g #{identifier} -n KAP-hdi2-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_separateread_v0_writecluster.sh -t edgenode -p \"#{containerName} #{storageaccount1} #{accountregion} #{storageaccount2}\" >> #{azureerror} && touch #{returnflagfile}"
          ignore_failure true
        end
        result_log(emptytitle, "azure group deployment config hdi2 by sheme separated", progresslog, returnflagfile)
      end
    end
  elsif azureaction.eql?("removehdi")
    result_pure_log(title3, "Remove KAP", progresslog)
    execute 'removehdi_resources_group' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-uninstall-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_uninstall_v0.sh -t edgenode -p #{appType} >> #{azureerror} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(emptytitle, "remove kap and backup it", progresslog, returnflagfile)
    result_pure_log(title4, "Remove HDinsight Cluster", progresslog)
    execute 'removehdi_hdinsight' do
      command "azure hdinsight cluster delete #{clusterName} -g #{identifier} >> #{azureerror} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(emptytitle, "azure hdinsight hdinsight cluster delete", progresslog, returnflagfile)
    if scheme.eql?("separated")
      result_pure_log(title5, "Remove HDinsight write cluster", progresslog)
      execute 'removehdi_hdinsight2' do
        command "azure hdinsight cluster delete #{clusterName2} -g #{identifier} >> #{azureerror} && touch #{returnflagfile}"
        # notifies :run, 'execute[commit_docker]', :immediately
        ignore_failure true
      end
      result_log(emptytitle, "azure hdinsight2 cluster delete", progresslog, returnflagfile)
    end
  elsif azureaction.eql?("removeall")
    result_pure_log(title3, "Remove Whole Resource Group", progresslog)
    execute 'remove_resources_group' do
      command "azure group show #{identifier} > /root/.azure/check.txt || : ;NUM=`cat /root/.azure/check.txt| grep OK | wc -l|xargs`;if [ \"$NUM\" -ne \"0\" ];then azure group delete #{identifier} -q >> #{azureerror};else echo \"Resource group #{identifier} not exists\">> #{azureerror};fi"
      # notifies :run, 'execute[commit_docker]', :immediately
      #ignore_failure true
    end
  elsif azureaction.eql?("resize")
    result_pure_log(title3, "Resize HDinsight cluster", progresslog)
    execute 'resize_resources_group' do
      command "azure hdinsight cluster resize #{clusterName} -g #{identifier} #{kylin[:clusterWorkerNodeCount]} >> #{azureerror} && touch #{returnflagfile}"
      # notifies :run, 'execute[commit_docker]', :immediately
      ignore_failure true
    end
    result_log(emptytitle, "azure hdinsight cluster resize", progresslog, returnflagfile)
  elsif azureaction.eql?("upgrade")
    result_pure_log(title3, "Upgrade HDinsight cluster", progresslog)
    execute 'upgradekap' do
      command "azure hdinsight script-action create #{clusterName} -g #{identifier} -n KAP-upgrade-v0-onca4kdxp6vhw -u https://raw.githubusercontent.com/Kyligence/Iaas-Applications/master/KAP/scripts/KAP_upgrade_v0.sh -t edgenode -p \"#{appType} #{kylin[:clusterLoginUserName]} #{kylin[:clusterLoginPassword]} #{kylin[:metastoreName]}\" >> #{azureerror}"
      #ignore_failure true
    end
  end
end

result_pure_log(titleend, "Upgrade HDinsight cluster", progresslog)
