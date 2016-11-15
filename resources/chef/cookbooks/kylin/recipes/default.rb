#
# Cookbook Name:: kylin
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user 'hdfs' do
  comment 'Hadoop filesystem user'
  uid '501'
  gid 'root'
  home '/home/hdfs'
  shell '/bin/bash'
end

remote_file "#{Chef::Config[:file_cache_path]}/kylin.tar.gz" do
    source node[:kylin][:kylin_tarball]
    action :create
end

execute "installkylin" do
    cwd "#{Chef::Config[:file_cache_path]}"
    command "export DIRECTORY=`echo #{node[:kylin][:kylin_tarball]}|cut -f5 -d'/'| awk -F'-' '{print $3}'`;if [ ! -d '/usr/local/kylin' ]; then tar -xvf ./kylin.tar.gz;mv ./apache-kylin-$DIRECTORY-hbase1.x-bin /usr/local/kylin; fi"
#    user 'hdfs'
#    group 'root'
end

#env "KYLIN_HOME" do
#    value "/usr/local/kylin"
#end

template "/etc/bootstrap.sh" do
    source 'bootstrap.sh'
    owner 'root'
    group 'root'
    mode '0744'
end

execute "createkylincredential" do
    command 'sudo -u hdfs hadoop fs -mkdir /kylin;sudo -u hdfs hadoop fs -chown -R root:hadoop /kylin'
    user 'root'
    group 'root'
    ignore_failure true
end

execute "Startkylin" do
    command '/etc/bootstrap.sh'
end
