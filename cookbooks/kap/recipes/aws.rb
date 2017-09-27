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
require File.expand_path('../comm.rb', __FILE__)

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



#clear old stuff if exists
execute "removeawsstuff" do
  command "rm -rf /root/.aws/*"
  ignore_failure true
end

# storing kylin variables to be called
if (not (defined?(aws[:kylin])).nil?) && (not "#{aws[:kylin]}" == "")
  kylin = aws[:kylin]
end
identifier = kylin[:identifier]

# Adding custom log
progresslog = "#{basedir}aws/#{identifier}/progress.log"
returnflagfile = "/tmp/kap_process_success"
awserror = "/root/.aws/aws.err"

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

# fetch app info
if (not (defined?(kylin[:app])).nil?)
  appinfo = kylin[:app]
end

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

# Check what scheme, "allinone" or "separated" to be deployed
if (not (defined?(aws[:scheme])).nil?) && (not "#{aws[:scheme]}" == "")
  scheme = aws[:scheme]
else
  scheme = "allinone"
end

# Check emr version if set
if (not (defined?(kylin[:emrversion])).nil?) && (not "#{kylin[:emrversion]}" == "")
  emrversion = kylin[:emrversion]
else
  emrversion = "emr-5.5.0"
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

  kapagentid = ""
  if (not (defined?(kylin[:kapagentid])).nil?) && (not "#{kylin[:kapagentid]}" == "")
    kapagentid = kylin[:kapagentid]
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

  workerNodeInstanceType = "m4.xlarge"
  if (not (defined?(kylin[:workerNodeSize])).nil?) && (not "#{kylin[:workerNodeSize]}" == "")
    workerNodeInstanceType = kylin[:workerNodeSize]
  end

  edgeNodeInstanceType = ""
  if (not (defined?(kylin[:edgeNodeSize])).nil?) && (not "#{kylin[:edgeNodeSize]}" == "")
    edgeNodeInstanceType = kylin[:edgeNodeSize]
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
  kaptoken = "dda18812-e57b-47f1-8aae-38adebecde8a"
  if (not (defined?(kylin[:kaptoken])).nil?) && (not "#{kylin[:kaptoken]}" == "")
    kaptoken = kylin[:kaptoken]
  end
  instancecount = "2"
  if (not (defined?(kylin[:clusterWorkerNodeCount])).nil?) && (not "#{kylin[:clusterWorkerNodeCount]}" == "")
    instancecount = kylin[:clusterWorkerNodeCount]
  end
  emrid = ""
  if (not (defined?(kylin[:emrid])).nil?) && (not "#{kylin[:emrid]}" == "")
    emrid = kylin[:emrid]
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
  # empty progresslog
  execute "truncateprogresslog" do
    command "echo \"\" > #{progresslog}"
    ignore_failure true
  end
  result_pure_log(title0, "Check keypair", progresslog)
  # Run checking for key pair
  execute "checkifkeypairexist" do
    command "aws ec2 describe-key-pairs --key-name #{keypair} > #{awserror} && touch #{returnflagfile}"
    ignore_failure true
  end
  result_log(emptytitle, "check keypair existence", progresslog, returnflagfile)

  result_pure_log(title1, "Prepare and validate deployment", progresslog)
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
    source "aws_chefServer.template.erb"
    variables(
      :accountregion => accountregion
    )
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
    result_pure_log(title2, "CheckZone", progresslog)
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
    result_pure_log(emptytitle, "aws deployment checkzone bash finish", progresslog)
    # execute "checkzone" do
    #   command = "#{basedir}aws/#{identifier}/scripts/01_awscheck_zone.sh #{region} > #{basedir}aws/#{identifier}/ZONE.txt"
    # end

    result_pure_log(title3, "Create VPC", progresslog)
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
    result_pure_log(emptytitle, "aws deployment create vpc finish", progresslog)

    # Running 04_deploy_chef
    result_pure_log(title4, "Create ChefServer", progresslog)
    ruby_block "createchefserver" do
      block do
          #tricky way to load this Chef::Mixin::ShellOut utilities
          Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
          command = "cd #{basedir}aws/#{identifier};#{basedir}aws/#{identifier}/scripts/04_deploy_chef.sh `cat #{basedir}aws/#{identifier}/ZONE.txt`,#{identifier},#{keypair},#{clusterLoginUserName},#{clusterLoginPassword},#{appType},#{kaptoken},#{kapagentid},#{instancecount},#{kapUrl},#{kyanalyzerUrl},#{zeppelinUrl},#{workerNodeInstanceType} >  #{awserror}"
          command_out = shell_out(command, :timeout => 3600)
      end
      action :create
    end
    result_pure_log(emptytitle, "aws deployment create vpc and chefserver finish", progresslog)

    result_pure_log(title5, "Create EMR", progresslog)
    execute "create_emr" do
      command "ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo /root/create_emr.sh #{identifier} #{emrversion}\" > #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment create emr", progresslog, returnflagfile)
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[? Status.State==`WAITING` && Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt  && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment check EMR ID", progresslog, returnflagfile)
    result_pure_log(title6, "Create KAP", progresslog)
    execute "run_install" do
      command "ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo /root/create_client.sh #{identifier} #{instancetype} #{accountregion}\" > #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment run_install for chefclient", progresslog, returnflagfile)
    execute "runningwaitloop_forchefclient" do
      command "CURRENSTATUS=\"\";while [ \"$CURRENSTATUS\" != \"CREATE_COMPLETE\" ]; do CURRENSTATUS=$(aws cloudformation describe-stacks --stack-name #{identifier}-kylinserver --query 'Stacks[*].StackStatus' --output text);sleep 5;done"
      ignore_failure true
    end
    result_pure_log(title7, "Create Sample Cube", progresslog)
    execute "create_sample_cube" do
      command "echo \"Start creating sample cube\" >> #{basedir}aws/#{identifier}/deploy.log;n=0;until [ $n -ge 5 ];do ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo /usr/local/kap/bin/sample.sh'\)\"  >> #{basedir}aws/#{identifier}/deploy.log && break;n=$[$n+1];sleep 15;done"
      ignore_failure true
    end
    result_pure_log(emptytitle, "aws deployment chefclient prepare and create sample finish", progresslog)
  elsif awsaction.eql?("resize")
    result_pure_log(title2, "Check EMR ID", progresslog)
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[? Status.State==`WAITING` && Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment check EMR ID", progresslog, returnflagfile)
    execute "checkcurrentnodecount" do
      command "aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $3,$(NF-1)}' > #{basedir}aws/#{identifier}/nodecount.txt && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment check current node count", progresslog, returnflagfile)
    result_pure_log(title3, "Resizing", progresslog)
    execute "runresize" do
      command "export COUNT=`cat #{basedir}aws/#{identifier}/nodecount.txt|awk {'print $2'}`;export INSTANCEGROUPS=`cat #{basedir}aws/#{identifier}/nodecount.txt|awk {'print $1'}`;aws emr modify-instance-groups --instance-groups InstanceGroupId=$INSTANCEGROUPS,InstanceCount=#{kylin[:clusterWorkerNodeCount]} > #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment run resize", progresslog, returnflagfile)
    execute "checkrunsize" do
      command "export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF)}');while [ \"#{kylin[:clusterWorkerNodeCount]}\" -ne \"$NEWCOUNT\" ];do sleep 5;echo \"Resize in progress\";export NEWCOUNT=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep INSTANCEGROUPS| grep CORE | awk '{print $(NF)}');echo \"Current Node count = \"$NEWCOUNT >>  #{basedir}aws/#{identifier}/deploy.log ;done"
    end
    result_pure_log(emptytitle, "aws deployment action[resize] finish", progresslog)
  elsif awsaction.eql?("removeemr")
    result_pure_log(title2, "Remove KylinServer", progresslog)
    execute "remove_cloudformation" do
      command "for x in -kylinserver;do aws cloudformation delete-stack --stack-name #{identifier}$x > #{awserror};done && touch #{returnflagfile}"
    end
    result_log(emptytitle, "in action[removeemr] remove cloudformation", progresslog, returnflagfile)
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[? Status.State==`WAITING` && Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt"
      ignore_failure true
    end
    result_pure_log(title3, "Remove EMR", progresslog)
    execute "remove_emr" do
      command "aws emr terminate-clusters --cluster-ids `cat #{basedir}aws/#{identifier}/clusterID.txt` || :"
      ignore_failure true
    end
    execute "runningwaitloop_foremr" do
      command "CURRENSTATUS=\"\";STATUS='0';while [ \"$STATUS\" != '1' ] && [ \"$CURRENSTATUS\" != \"TERMINATED\" ]; do CURRENSTATUS=$(aws emr describe-cluster --cluster-id `cat #{basedir}aws/#{identifier}/clusterID.txt` --output text | grep STATUS | head -1| awk {'print $2'});if [ $? -eq 0 ]; then STATUS='0'; else  STATUS='1'; fi;sleep 5;done"
      ignore_failure true
    end
    result_pure_log(emptytitle, "aws deployment action:[removeemr] finish", progresslog)
  elsif awsaction.eql?("removeall")
    result_pure_log(title2, "Remove ChefServer", progresslog)
    execute "remove_chefservercloudformation" do
      command "aws cloudformation describe-stacks --stack-name #{identifier}-chefserver > #{basedir}aws/#{identifier}/checkchefserver.txt || :;NUM=`cat #{basedir}aws/#{identifier}/checkchefserver.txt| wc -l|xargs`;if [ \"$NUM\" -ne \"0\" ];then for x in -chefserver;do echo \"Removing $x\" >> #{basedir}aws/#{identifier}/deploy.log;aws cloudformation delete-stack --stack-name #{identifier}$x > #{awserror};done;else echo \"Stack #{identifier}-chefserver does not exists\">> #{basedir}aws/#{identifier}/deploy.log;fi && touch #{returnflagfile}"
    end
    result_log(emptytitle, "in action[removeall] remove chefserver cloudformation", progresslog, returnflagfile)
    result_pure_log(title3, "Remove KAP", progresslog)
    execute "remove_kylinservercloudformation" do
      command "aws cloudformation describe-stacks --stack-name #{identifier}-kylinserver > #{basedir}aws/#{identifier}/checkkylinserver.txt || :;NUM=`cat #{basedir}aws/#{identifier}/checkkylinserver.txt| wc -l|xargs`;if [ \"$NUM\" -ne \"0\" ];then for x in -kylinserver;do echo \"Removing $x\" >> #{basedir}aws/#{identifier}/deploy.log;aws cloudformation delete-stack --stack-name #{identifier}$x > #{awserror};done;else echo \"Stack #{identifier}-kylinserver does not exists\">> #{basedir}aws/#{identifier}/deploy.log;fi && touch #{returnflagfile}"
    end
    result_log(emptytitle, "in action[removeall] remove kylinserver cloudformation", progresslog, returnflagfile)
    result_pure_log(title4, "Remove S3 Bucket", progresslog)
    execute "remove_s3" do
      command "for x in `aws s3 ls| awk {'print $3'}| grep #{identifier}-chefserver-privatekeybucket- || : `;do echo \"Removing S3 bucket name as $x\" >> #{basedir}aws/#{identifier}/deploy.log;aws s3 rb s3://$x --force  > #{awserror};done && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "in action[removeall] remove s3", progresslog, returnflagfile)
    execute "checkEMRid" do
      command "aws emr list-clusters --query 'Clusters[? Status.State==`WAITING` && Name==`#{identifier}`]'| grep Id| cut -d':' -f2|cut -d'\"' -f2 > #{basedir}aws/#{identifier}/clusterID.txt"
      ignore_failure true
    end
    result_pure_log(title5, "Remove EMR", progresslog)
    execute "remove_emr" do
      command "NUM=`cat #{basedir}aws/#{identifier}/clusterID.txt| wc -l`;if [ \"$NUM\" -ne \"0\" ];then aws emr terminate-clusters --cluster-ids `cat #{basedir}aws/#{identifier}/clusterID.txt` >> #{basedir}aws/#{identifier}/deploy.log || :;fi"
      ignore_failure true
    end
    execute "runningwaitloop_forServers" do
      command "NUM1=`cat #{basedir}aws/#{identifier}/checkchefserver.txt| wc -l|xargs`;if [ \"$NUM1\" -ne \"0\" ];then NUM2=`cat #{basedir}aws/#{identifier}/checkkylinserver.txt| wc -l|xargs`;if [ \"$NUM2\" -ne \"0\" ];then STATUS='00';while [ \"$STATUS\" != '11' ]; do echo 'ChefServer status' >>  #{basedir}aws/#{identifier}/deploy.log; aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].StackStatus' --output text >>  #{basedir}aws/#{identifier}/deploy.log; if [ $? -eq 0 ]; then STATUSchefserver='0'; else  STATUSchefserver='1'; fi; echo 'KylinServer status'>>  #{basedir}aws/#{identifier}/deploy.log; aws cloudformation describe-stacks --stack-name #{identifier}-kylinserver --query 'Stacks[*].StackStatus' --output text >>  #{basedir}aws/#{identifier}/deploy.log; if [ $? -eq 0 ]; then STATUSkylinserver='0'; else  STATUSkylinserver='1'; fi; STATUS=$STATUSchefserver$STATUSkylinserver;echo 'Status = '$STATUS >>  #{basedir}aws/#{identifier}/deploy.log; sleep 10; done;fi;fi"
    end
    template "#{basedir}aws/#{identifier}/clearvpc.sh" do
      source 'clearvpc.sh'
      owner 'root'
      group 'root'
      mode '0755'
    end
    result_pure_log(title6, "Remove VPC", progresslog)
    execute "clearvpc" do
      command "#{basedir}aws/#{identifier}/clearvpc.sh #{identifier}-vpc >>  #{basedir}aws/#{identifier}/deploy.log || :"
      ignore_failure true
    end
    # execute "removingVPC" do
    #   command "aws cloudformation delete-stack --stack-name #{identifier}-vpc >> #{basedir}aws/#{identifier}/deploy.log"
    # end
    execute "runningwaitloop_forVPC" do
      command "CURRENSTATUS=\"\";STATUS='0';while [ \"$STATUS\" != '1' ] && [ \"$CURRENSTATUS\" != \"DELETE_FAILED\" ]; do echo 'VPC status' >> #{basedir}aws/#{identifier}/deploy.log;CURRENSTATUS=$(aws cloudformation describe-stacks --stack-name #{identifier}-vpc --query 'Stacks[*].StackStatus' --output text);if [ $? -eq 0 ]; then STATUS='0'; else  STATUS='1'; fi;echo 'Status = '$STATUS >>  #{basedir}aws/#{identifier}/deploy.log;sleep 5;done"
    end
    result_pure_log(emptytitle, "aws deployment action:[removeall] finish", progresslog)
  elsif awsaction.eql?("existing")
    result_pure_log(title2, "Check EMR and applications etc", progresslog)
    execute "checkemrversion" do
      command "VERSION=$(aws emr describe-cluster --cluster-id #{emrid} --query 'Cluster.ReleaseLabel'  --output text);echo \"VERSION = \"$VERSION >> #{basedir}aws/#{identifier}/deploy.log;MAINVERSION=$(echo $VERSION|cut -d'-' -f2| cut -d'.' -f1);MINORVERSION=$(echo $VERSION|cut -d'-' -f2| cut -d'.' -f2);echo \"MAINVERSION = \"$MAINVERSION >> #{basedir}aws/#{identifier}/deploy.log;echo \"MINORVERSION = \"$MINORVERSION >> #{basedir}aws/#{identifier}/deploy.log;if [ \"$MAINVERSION\" -lt '5' ];then echo 'Main version not match prerequisite' > #{awserror};exit 1;fi;if [ \"$MINORVERSION\" -lt '5' ];then echo 'Version not match prerequisite, minimum EMR 5.5.0' > #{awserror};exit 1;fi && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment check emrversion", progresslog, returnflagfile)
    execute "checkemrapplication" do
      command "APPLICATIONS=$(aws emr describe-cluster --cluster-id #{emrid} --query 'Cluster.Applications' --output text);echo \"Application lists = \"$APPLICATIONS >> #{basedir}aws/#{identifier}/deploy.log;for x in Hive HBase;do if [[ $APPLICATIONS != *\"$x\"* ]];then echo \"Application $x did not found\" > #{awserror};exit 1;fi; done && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "in action[existing] check emr application", progresslog, returnflagfile)
    execute "checkvpcforgateway" do
      command "
        subnetid=$(aws emr describe-cluster --cluster-id #{emrid} --query 'Cluster.Ec2InstanceAttributes.Ec2SubnetId'| cut -d '\"' -f2);
        echo $subnetid > #{basedir}aws/#{identifier}/subnetid.txt;
        echo \"Subnetid = \"$subnetid >> #{basedir}aws/#{identifier}/deploy.log;
        VPCCOMMAND=\"aws ec2 describe-subnets --query 'Subnets[? SubnetId==\\\`SUBNETID\\\` ].VpcId' --output text\";
        echo \"VPCCOMMAND = \"$VPCCOMMAND >> #{basedir}aws/#{identifier}/deploy.log;
        NEWSTRING=$subnetid;
        RESULTCOMMAND=\"${VPCCOMMAND/SUBNETID/$NEWSTRING}\";
        echo \"This is the command to be ran: \"$RESULTCOMMAND >> #{basedir}aws/#{identifier}/deploy.log;
        vpcid=`eval $RESULTCOMMAND`;
        echo \"Vpcid = \"$vpcid >> #{basedir}aws/#{identifier}/deploy.log;
        echo $vpcid > #{basedir}aws/#{identifier}/vpcid.txt;
        checkgatewayattachcommand=\"aws ec2 describe-internet-gateways --query 'InternetGateways[*].Attachments[? VpcId == \\\`VPCID\\\`].VpcId' --output text\";
        NEWSTRING=$vpcid;
        RESULTCOMMAND=\"${checkgatewayattachcommand/VPCID/$NEWSTRING}\";
        echo \"This is the command to be ran: \"$RESULTCOMMAND >> #{basedir}aws/#{identifier}/deploy.log;
        gatewayresult=`eval $RESULTCOMMAND`;
        echo \"gatewayresult = \"$gatewayresult >> #{basedir}aws/#{identifier}/deploy.log;
        echo \"Running of checking of security group id\";
        COMMAND=\"aws ec2 describe-security-groups --query 'SecurityGroups[? GroupName == \\\`SECURITYGROUPNAME\\\` ].GroupId' --output text\";
        RESULTCOMMAND=\"${COMMAND/SECURITYGROUPNAME/#{identifier}-VpcSecurityGroup}\";
        echo \"SecurityGroups checking command = \"$RESULTCOMMAND;
        securitygroupid=`eval $RESULTCOMMAND` || :;
        echo \"Checked security group id = \"$securitygroupid;
        echo $securitygroupid > #{basedir}aws/#{identifier}/securitygroupid.txt;
      "
    end
    execute "checkzone" do
      command "#{basedir}aws/#{identifier}/scripts/01_awscheck_zone.sh #{region} > #{basedir}aws/#{identifier}/ZONE.txt"
    end
    execute "showzonefile" do
      command "cat #{basedir}aws/#{identifier}/ZONE.txt >> #{basedir}aws/#{identifier}/deploy.log"
    end
    result_pure_log(title3, "Create Chef Server", progresslog)
    execute "rundeploychef" do
      command "cd #{basedir}aws/#{identifier};#{basedir}aws/#{identifier}/scripts/04_deploy_chef.sh `cat #{basedir}aws/#{identifier}/ZONE.txt`,#{identifier},#{keypair},#{clusterLoginUserName},#{clusterLoginPassword},#{appType},#{kaptoken},#{kapagentid},#{instancecount},#{kapUrl},#{kyanalyzerUrl},#{zeppelinUrl},#{workerNodeInstanceType},`cat #{basedir}aws/#{identifier}/vpcid.txt`,`cat #{basedir}aws/#{identifier}/subnetid.txt`,`cat #{basedir}aws/#{identifier}/securitygroupid.txt` >  #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment deploy chef", progresslog, returnflagfile)
    execute "checkcurrentemrnamebyidandrunintoemrcreate" do
      command "CLUSTERNAME=$(aws emr list-clusters --query 'Clusters[? Status.State==`WAITING` && Id==`#{emrid}`].Name' --output text);echo #{emrid} > #{basedir}aws/#{identifier}/clusterID.txt;ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo /root/create_emr.sh $CLUSTERNAME\" > #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment create emr", progresslog, returnflagfile)
    result_pure_log(title4, "Create KAP", progresslog)
    execute "run_install" do
      command "ssh -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"sudo /root/create_client.sh #{identifier} #{instancetype} #{accountregion}\"  > #{awserror} && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment chefclient kylin", progresslog, returnflagfile)
    execute "runningwaitloop_forchefclient" do
      command "CURRENSTATUS=\"\";while [ \"$CURRENSTATUS\" != \"CREATE_COMPLETE\" ]; do CURRENSTATUS=$(aws cloudformation describe-stacks --stack-name #{identifier}-kylinserver --query 'Stacks[*].StackStatus' --output text);sleep 5;done"
      ignore_failure true
    end
    result_pure_log(title5, "Create SampleCube", progresslog)
    execute "create_sample_cube" do
      command "echo \"Start creating sample cube\" >> #{basedir}aws/#{identifier}/deploy.log;n=0;until [ $n -ge 5 ];do ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo /usr/local/kap/bin/sample.sh'\)\"  >> #{basedir}aws/#{identifier}/deploy.log && break;n=$[$n+1];sleep 15;done"
      ignore_failure true
    end
    result_pure_log(emptytitle, "aws deployment action[existing] finish", progresslog)
  elsif awsaction.eql?("removekap")
    result_pure_log(title2, "Backup KAP data", progresslog)
    #  backup kap whole folder to s3 first
    execute "backup_kapfolder" do
      command "ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo /etc/chef/backupkap.sh'\)\""
      #ignore_failure true
    end
    result_pure_log(title3, "Remove KAP", progresslog)
    execute "remove_cloudformation" do
      command "for x in -chefserver -kylinserver;do echo \"Removing $x\" >> #{basedir}aws/#{identifier}/deploy.log;aws cloudformation delete-stack --stack-name #{identifier}$x > #{awserror};done && touch #{returnflagfile}"
      ignore_failure true
    end
    result_log(emptytitle, "aws deployment remove kap", progresslog, returnflagfile)
    result_pure_log(emptytitle, "aws deployment remove kap finish", progresslog)
  elsif awsaction.eql?("testing")
    execute "startkap" do
      command "echo \"Starting KAP\" >> #{basedir}aws/#{identifier}/deploy.log;n=0;until [ $n -ge 5 ];do ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo service kap restart'\)\"  >> #{basedir}aws/#{identifier}/deploy.log && break;n=$[$n+1];sleep 15;done"
    end
    execute "startkyanalyzer" do
      command "echo \"Starting KAP\" >> #{basedir}aws/#{identifier}/deploy.log;n=0;until [ $n -ge 5 ];do ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo service kyanalyzer restart'\)\"  >> #{basedir}aws/#{identifier}/deploy.log && break;n=$[$n+1];sleep 15;done"
    end
    execute "startzeppelin" do
      command "echo \"Starting KAP\" >> #{basedir}aws/#{identifier}/deploy.log;n=0;until [ $n -ge 5 ];do ssh -t -t -i #{basedir}aws/#{identifier}/credentials/kylin.pem -o StrictHostKeyChecking=no ec2-user@`aws cloudformation describe-stacks --stack-name #{identifier}-chefserver --query 'Stacks[*].Outputs[*]' --output text | grep ServerPublicIp| awk {'print $NF'}` \"\(cd /home/ec2-user/chef11/chef-repo;sudo knife ssh -i /root/.ssh/kylin.pem 'role:chefclient-kylin' 'sudo service zeppelin restart'\)\"  >> #{basedir}aws/#{identifier}/deploy.log && break;n=$[$n+1];sleep 15;done"
    end
  end
end
