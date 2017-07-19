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

  identifier = kylin[:identifier]
  keypair = kylin[:keypair]
  keypairprivatekey = kylin[:keypairprivatekey]

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

  instancetype = "m4.xlarge"
  if (not (defined?(kylin[:instancetype])).nil?) && (not "#{kylin[:instancetype]}" == "")
    instancetype = kylin[:instancetype]
  end

  clusterLoginUserName = 'kylin'
  if (not (defined?(kylin[:clusterLoginUserName])).nil?) && (not "#{kylin[:clusterLoginUserName]}" == "")
    clusterLoginUserName = kylin[:clusterLoginUserName]
  end
  if (not (defined?(kylin[:clusterLoginUserName])).nil?) && (not "#{kylin[:clusterLoginUserName]}" == "")
    clusterLoginUserName = kylin[:clusterLoginUserName]
  end
  clusterLoginPassword = 'Kyligence2016'
  if (not (defined?(kylin[:clusterLoginPassword])).nil?) && (not "#{kylin[:clusterLoginPassword]}" == "")
    clusterLoginPassword = kylin[:clusterLoginPassword]
  end
  appType = "KAP+KyAnalyzer+Zeppelin"
  if (not (defined?(kylin[:appType])).nil?) && (not "#{kylin[:appType]}" == "")
    appType = kylin[:appType]
  end
  kaptoken = "dda18812-e57b-47f1-8aae-38adebecde8a"
  if (not (defined?(kylin[:kaptoken])).nil?) && (not "#{kylin[:kaptoken]}" == "")
    kaptoken = kylin[:kaptoken]
  end
  instancecount = "2"
  if (not (defined?(kylin[:clusterWorkerNodeCount])).nil?) && (not "#{kylin[:clusterWorkerNodeCount]}" == "")
    instancecount = kylin[:clusterWorkerNodeCount]
  end


  file "#{basedir}aws/#{identifier}/credentials/kylin.pem" do
    content keypairprivatekey
    owner 'root'
    group 'root'
    mode '0400'
    action :create
  end
  ## Configuring default variable Finished

  # Fixing kylin.pem format
  execute "fixingpem" do
    command "sed -i \"s/-----BEGIN RSA PRIVATE KEY----- //\" #{basedir}aws/#{identifier}/credentials/kylin.pem;sed -i \"s/ -----END RSA PRIVATE KEY-----//\" #{basedir}aws/#{identifier}/credentials/kylin.pem;cat #{basedir}aws/#{identifier}/credentials/kylin.pem | tr \" \" \"\n\" > #{basedir}aws/#{identifier}/credentials/kylin.pem.tmp;mv #{basedir}aws/#{identifier}/credentials/kylin.pem.tmp #{basedir}aws/#{identifier}/credentials/kylin.pem;sed -i '1i -----BEGIN RSA PRIVATE KEY-----' #{basedir}aws/#{identifier}/credentials/kylin.pem;echo >>#{basedir}aws/#{identifier}/credentials/kylin.pem;echo '-----END RSA PRIVATE KEY-----' >> #{basedir}aws/#{identifier}/credentials/kylin.pem;chmod 400 #{basedir}aws/#{identifier}/credentials/kylin.pem"
  end

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
          command = "cd #{basedir}aws/#{identifier};#{basedir}aws/#{identifier}/scripts/04_deploy_chef.sh `cat #{basedir}aws/#{identifier}/ZONE.txt`,#{identifier},#{keypair},#{clusterLoginUserName},#{clusterLoginPassword},#{appType},#{kaptoken},#{instancecount} >>  #{basedir}aws/#{identifier}/deploy.log"
          command_out = shell_out(command, :timeout => 3600)
      end
      action :create
    end
    execute "run_install" do
      command "ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo /root/create_client.sh #{identifier} #{instancetype}\""
    end
    execute "create_sample_cube" do
      command "ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo (cd /home/ec2-user/chef11/chef-repo;knife ssh 'name:*'' '/usr/local/kap/bin/sample.sh')\""
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
      command "export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF)}');while [ \"#{kylin[:clusterWorkerNodeCount]}\" -ne \"$NEWCOUNT\" ];do sleep 5;echo \"Resize in progress\";export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF)}');echo \"Current Node count = \"$NEWCOUNT >>  #{basedir}aws/#{identifier}/deploy.log;done"
    end
  elsif awsaction.eql?("removeall")
    execute "remove_cloudformation" do
      command "for x in -chefserver -kylinserver;do aws cloudformation delete-stack --stack-name #{identifier}$x;done"
    end
    execute "remove_s3" do
      command "for x in `aws s3 ls| awk {'print $3'}| grep #{identifier}-chefserver-privatekeybucket-`;do aws s3 rb s3://$x --force;done"
    end
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[?Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt"
      ignore_failure true
    end
    execute "remove_emr" do
      command "aws emr terminate-clusters --cluster-ids `cat #{basedir}aws/#{identifier}/clusterID.txt` || true"
      ignore_failure true
    end
    execute "runningwaitloop_forServers" do
      command "STATUS='00';while [ \"$STATUS\" != '11' ]; do echo 'ChefServer status' >>  #{basedir}aws/#{identifier}/deploy.log; aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].StackStatus' --output text >>  #{basedir}aws/#{identifier}/deploy.log; if [ $? -eq 0 ]; then STATUSchefserver='0'; else  STATUSchefserver='1'; fi; echo 'KylinServer status'>>  #{basedir}aws/#{identifier}/deploy.log; aws cloudformation describe-stacks --stack-name #{identifier}-kylinserver --query 'Stacks[*].StackStatus' --output text >>  #{basedir}aws/#{identifier}/deploy.log; if [ $? -eq 0 ]; then STATUSkylinserver='0'; else  STATUSkylinserver='1'; fi; STATUS=$STATUSchefserver$STATUSkylinserver;echo 'Status = '$STATUS >>  #{basedir}aws/#{identifier}/deploy.log; sleep 10; done"
    end
    template "#{basedir}aws/#{identifier}/clearvpc.sh" do
      source 'clearvpc.sh'
      owner 'root'
      group 'root'
      mode '0755'
    end
    execute "clearvpc" do
      command "#{basedir}aws/#{identifier}/clearvpc.sh #{identifier}-vpc >>  #{basedir}aws/#{identifier}/deploy.log || true"
      ignore_failure true
    end
    execute "removingVPC" do
      command "aws cloudformation delete-stack --stack-name #{identifier}-vpc >>  #{basedir}aws/#{identifier}/deploy.log"
    end
    execute "runningwaitloop_forVPC" do
      command "CURRENSTATUS=\"\";STATUS='0';while [ \"$STATUS\" != '1' ] && [ \"$CURRENSTATUS\" != \"DELETE_FAILED\" ]; do echo 'VPC status' >> #{basedir}aws/#{identifier}/deploy.log;CURRENSTATUS=$(aws cloudformation describe-stacks --stack-name #{identifier}-vpc --query 'Stacks[*].StackStatus' --output text);if [ $? -eq 0 ]; then STATUS='0'; else  STATUS='1'; fi;echo 'Status = '$STATUS >>  #{basedir}aws/#{identifier}/deploy.log;done"
    end
    execute "removingVPCagain" do
      command "aws cloudformation delete-stack --stack-name #{identifier}-vpc >>  #{basedir}aws/#{identifier}/deploy.log"
    end
  end

end
