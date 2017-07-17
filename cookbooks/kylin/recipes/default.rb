#
# Cookbook Name:: kylin
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# remote_file "#{Chef::Config[:file_cache_path]}/kylin.tar.gz" do
#     # source node[:kylin][:kylin_tarball]
#     source "#{node[:kylin][:KAP_DOWNLOAD_URI]}#{node[:kylin][:KAP_TARFILE]}
#     action :create
# end
#
# execute "installkylin" do
#     cwd "#{Chef::Config[:file_cache_path]}"
#     command "export DIRECTORY=`echo #{node[:kylin][:kylin_tarball]}|cut -f5 -d'/'| awk -F'-' '{print $3}'`;if [ ! -d '/usr/local/kylin' ]; then tar -xvf ./kylin.tar.gz;mv ./apache-kylin-$DIRECTORY-hbase1.x-bin /usr/local/kylin; fi"
# #    user 'hdfs'
# #    group 'root'
# end

#env "KYLIN_HOME" do
#    value "/usr/local/kylin"
#end

template "/etc/bootstrap.sh" do
    source 'bootstrap.sh'
    owner 'root'
    group 'root'
    mode '0744'
end

user 'hdfs' do
  comment 'Hadoop filesystem user'
  uid '501'
  gid 'root'
  home '/home/hdfs'
  shell '/bin/bash'
  ignore_failure true
end

user 'hadoop' do
  comment 'Hadoop user'
  uid '502'
  gid 'root'
  home '/home/hadoop'
  shell '/bin/bash'
  ignore_failure true
end

# Download and execute installation script
remote_file "#{Chef::Config[:file_cache_path]}/install.sh" do
    # source node[:kylin][:kylin_tarball]
    source node[:kylin][:installscript]
    action :create
end

execute "installkylin" do
    cwd "#{Chef::Config[:file_cache_path]}"
    command "chmod 744 ./install.sh;./install.sh #{node[:kylin][:var_adminuser]} #{node[:kylin][:var_adminpassword]} #{node[:kylin][:var_apptype]} #{node[:kylin][:var_kyaccountToken]};"
#    user 'hdfs'
#    group 'root'
end

#AWS ONLY
template "/usr/local/kap/conf/kylin_job_conf.xml" do
  #variables lazy { {metahostname: shell_out!('curl http://169.254.169.254/latest/meta-data/hostname').stdout} }
  variables lazy { {metahostname: node[:kylin][:emrserver] } }
  source "kylin_job_conf.xml.erb"
  mode 0644
  owner "ec2-user"
  group "ec2-user"
  retries 3
  retry_delay 30
end

execute "createkylincredential" do
    command 'sudo -u hdfs hadoop fs -mkdir /kylin;sudo -u hdfs hadoop fs -chown -R root:hadoop /kylin'
    user 'root'
    group 'root'
    ignore_failure true
end

template "/etc/init.d/kap" do
  source 'kap.service'
  owner 'root'
  group 'root'
  mode  '0755'
end

execute "Startkylin" do
    command 'chkconfig --level 345 kap;service kap start'
end

if kylin[:appType].downcase.include?("kyanalyzer")
  template "/etc/init.d/kyanalyzer" do
    source 'kyanalyzer.service'
    owner 'root'
    group 'root'
    mode  '0755'
  end
  execute "Startkyanalyzer" do
      command 'chkconfig --level 345 kyanalyzer;service kyanalyzer start'
  end
end

if kylin[:appType].downcase.include?("zeppelin")
  template "/etc/init.d/zeppelin" do
    source 'zeppelin.service'
    owner 'root'
    group 'root'
    mode  '0755'
  end
  execute "Startzeppelin" do
      command 'chkconfig --level 345 zeppelin;service zeppelin start'
  end
end
