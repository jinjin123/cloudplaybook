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

aws = node[:deploycode][:configuration][:aws]

awsaction = aws[:action]
# storing kylin variables to be called
if not ((not (defined?(awsaction)).nil?) && (not "#{awsaction}" == ""))
  awsaction = "create"
end

credentials = aws[:credentials]

# Setting basedir to store template files
basedir = node[:deploycode][:basedirectory]
username = node[:deployuser]
#runtime = node[:deploycode][:runtime][:azure]

# storing kylin variables to be called
if (not (defined?(aws[:kylin])).nil?) && (not "#{aws[:kylin]}" == "")
  kylin = aws[:kylin]
end
identifier = kylin[:identifier]

# Check what scheme, "allinone" or "separated" to be deployed
if (not (defined?(aws[:scheme])).nil?) && (not "#{aws[:scheme]}" == "")
  scheme = aws[:scheme]
else
  scheme = "allinone"
end

# Name of docker container is not imaport, just make one
container_name = "#{node[:projectname]}_aws_#{identifier}"
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
  directory "#{basedir}aws/#{identifier}" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end
  directory "#{basedir}aws/#{identifier}/scripts" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end
  directory "#{basedir}aws/#{identifier}/templates" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end
  directory "#{basedir}aws/#{identifier}/credentials" do
    owner username
    group username
    mode '0755'
    recursive true
    action :create
  end

  if kylin[:region].downcase.include?("cn")
    accountregion = "china"
  else
    accountregion = "global"
  end

  ## Setting of variables
  kaptoken = ''
  if (not (defined?(kylin[:kaptoken])).nil?) && (not "#{kylin[:kaptoken]}" == "")
    kaptoken = kylin[:kaptoken]
  end

  ## Configuring default variable
  region = "cn-north-1"
  if (not (defined?(credentials[:region])).nil?) && (not "#{credentials[:region]}" == "")
    if ! credentials[:region].eql?("default")
      region = credentials[:region]
    end
  end

  identifier = kylin[:identifier]
  keypair = kylin[:keypair]
  keypairprivatekey = kylin[:keypairprivatekey]

  file "#{basedir}aws/#{identifier}/credentials/kylin.pem" do
    content keypairprivatekey
    owner 'root'
    group 'root'
    mode '0400'
    action :create
  end
  ## Configuring default variable Finished

  # Configuring AWS credentials
  directory '/root/.aws' do
    owner 'root'
    group 'root'
    mode 00755
    recursive true
    action :create
  end

  template "/root/.aws/config" do
    source "aws.config.erb"
    variables(
      :region => region
    )
    mode 0400
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end
  template "/root/.aws/credentials" do
    source "aws.credentials.erb"
    variables(
      :awskey => credentials[:awskey],
      :awssecret => credentials[:awssecret]
    )
    mode 0400
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  # execute 'listS3' do
  #   command 'aws s3 ls'
  #   action :run
  # end

  # Run checking for key pair
  execute "checkifkeypairexist" do
    command "aws ec2 describe-key-pairs --key-name #{keypair}"
  end

  template "#{basedir}aws/#{identifier}/scripts/01_awscheck_zone.sh" do
    source "aws_01_awscheck_zone.sh"
    mode 0744
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  template "#{basedir}aws/#{identifier}/scripts/03_deploy_vpc.sh" do
    source "aws_03_deploy_vpc.sh"
    mode 0744
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  template "#{basedir}aws/#{identifier}/scripts/04_deploy_chef.sh" do
    source "aws_04_deploy_chef.sh"
    mode 0744
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  template "#{basedir}aws/#{identifier}/templates/vpc.template" do
    source "aws_vpc.template"
    mode 0744
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  template "#{basedir}aws/#{identifier}/templates/chefServer.template" do
    source "aws_chefServer.template"
    mode 0744
    retries 3
    retry_delay 2
    owner "root"
    group "root"
    action :create
  end

  file "/root/identifier.txt" do
    content identifier
  end

  if awsaction.include?("create")
    # Running 01_awscheck_zone
    ruby_block "checkzone" do
      block do
          #tricky way to load this Chef::Mixin::ShellOut utilities
          Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
          command = "#{basedir}aws/#{identifier}/scripts/01_awscheck_zone.sh #{region} > #{basedir}aws/#{identifier}/ZONE.txt"
          command_out = shell_out(command)
      end
      action :create
    end

    # Running 03_deploy_vpc
    ruby_block "createvpc" do
      block do
          #tricky way to load this Chef::Mixin::ShellOut utilities
          Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
          command = "cd #{basedir}aws/#{identifier};#{basedir}aws/#{identifier}/scripts/03_deploy_vpc.sh `cat #{basedir}aws/#{identifier}/ZONE.txt`,#{identifier} >>  #{basedir}aws/#{identifier}/deploy.log"
          command_out = shell_out(command)
      end
      action :create
    end

    # Running 04_deploy_chef
    ruby_block "createchefserver" do
      block do
          #tricky way to load this Chef::Mixin::ShellOut utilities
          Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
          command = "cd #{basedir}aws/#{identifier};#{basedir}aws/#{identifier}/scripts/04_deploy_chef.sh `cat #{basedir}aws/#{identifier}/ZONE.txt`,#{identifier},#{keypair} >>  #{basedir}aws/#{identifier}/deploy.log"
          command_out = shell_out(command, :timeout => 3600)
      end
      action :create
    end
  elsif awsaction.eql?("resize")
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[?Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt"
    end
    execute "checkcurrentnodecount" do
      command "aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $3,$(NF-1)}' > #{basedir}aws/#{identifier}/nodecount.txt"
    end
    execute "runresize" do
      command "export COUNT=`cat #{basedir}aws/#{identifier}/nodecount.txt|awk {'print $2'}`;export INSTANCEGROUPS=`cat #{basedir}aws/#{identifier}/nodecount.txt|awk {'print $1'}`;aws emr modify-instance-groups --instance-groups InstanceGroupId=$INSTANCEGROUPS,InstanceCount=#{kylin[:clusterWorkerNodeCount]}"
    end
    execute "checkrunsize" do
      command "export COUNT=`cat #{basedir}aws/#{identifier}/nodecount.txt|awk {'print $2'}`;export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF-1)}');while [ \"$COUNT\" -ne \"$NEWCOUNT\" ];do sleep 5;echo \"Resize in progress\";export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt| awk {'print $1'}` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF-1)}');echo \"Current Node count = \"$NEWCOUNT >>  #{basedir}aws/#{identifier}/deploy.log;done"
    end
  end

end
