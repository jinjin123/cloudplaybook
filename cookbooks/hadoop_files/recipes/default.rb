#
# Cookbook Name:: hadoop_files
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template "/etc/yum.repos.d/HDP.repo" do
  source 'HDP.repo'
  owner 'root'
  group 'root'
  mode '0755'
end

template "/etc/yum.repos.d/HDP-UTILS.repo" do
  source 'HDP-UTILS.repo'
  owner 'root'
  group 'root'
  mode '0755'
end

directory "/root/keys" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template "/root/keys/kylin.pem" do
  source 'kylin.pem'
  owner 'root'
  group 'root'
  mode '0400'
end

template "/etc/init.d/kylin" do
  source 'kylin.service'
  owner 'root'
  group 'root'
  mode  '0744'
end

#AWS ONLY
template "/usr/local/kap/kap-2.3.7-GA-hbase1.x/conf/kylin_job_conf.xml" do
  #variables lazy { {metahostname: shell_out!('curl http://169.254.169.254/latest/meta-data/hostname').stdout} }
  variables lazy { {metahostname: node[:deploykylin][:runtime][:bootkylin][:emr_master_ip] } }
  source "kylin_job_conf.xml.erb"
  mode 0644
  owner "hadoop"
  group "hadoop"
  retries 3
  retry_delay 30
end

execute "yum_update" do
    command 'yum update -y'
    ignore_failure true
end

#remote_file "#{Chef::Config[:file_cache_path]}/jdk-7u71-linux-x64.rpm" do
#    source "https://s3.cn-north-1.amazonaws.com.cn/bootdevcn/jdk-7u71-linux-x64.rpm"
#    action :create
#    ignore_failure true
#end

#rpm_package "jdk-7u71" do
#    source "#{Chef::Config[:file_cache_path]}/jdk-7u71-linux-x64.rpm"
#    action :install
#end

pkgs_lib = %w{
    usr/lib/jvm
    usr/lib/phoenix
    usr/lib/hadoop 
    usr/lib/hadoop-hdfs
    usr/lib/hadoop-httpfs
    usr/lib/hadoop-kms
    usr/lib/hadoop-lzo
    usr/lib/hadoop-mapreduce
    usr/lib/hadoop-yarn
    usr/lib/bigtop-groovy
    usr/lib/bigtop-tomcat
    usr/lib/bigtop-utils
    usr/lib/hive
    usr/lib/hive-hcatalog
    usr/lib/hbase
    usr/lib/tez    
}

pkgs_lib.flatten.each do |pkg|
    execute "copy_#{pkg}" do
        command "scp -r -i #{node[:deploykylin][:runtime][:bootkylin][:emr_master_pem]} -o StrictHostKeyChecking=no #{node[:deploykylin][:runtime][:bootkylin][:emr_master_user]}@#{node[:deploykylin][:runtime][:bootkylin][:emr_master_ip]}:/#{pkg} /usr/lib/"
        user 'root'
        group 'root'
        ignore_failure true
    end 
end

pkgs_etc = %w{
    etc/hadoop
    etc/hadoop-httpfs
    etc/hadoop-kms
    etc/hbase
    etc/hive
    etc/hive-hcatalog
    etc/hive-webhcat
    etc/phoenix
    etc/tez
}

pkgs_etc.flatten.each do |pkg|
    execute "copy_#{pkg}" do
        command "scp -r -i #{node[:deploykylin][:runtime][:bootkylin][:emr_master_pem]} -o StrictHostKeyChecking=no #{node[:deploykylin][:runtime][:bootkylin][:emr_master_user]}@#{node[:deploykylin][:runtime][:bootkylin][:emr_master_ip]}:/#{pkg} /etc/"
        user 'root'
        group 'root'
        ignore_failure true
    end
end

pkgs_bin = %w{
    usr/bin/hadoop
    usr/bin/hbase
    usr/bin/hive
    usr/bin/yarn
    usr/bin/emrfs
}

pkgs_bin.flatten.each do |pkg|
    execute "copy_#{pkg}" do
        command "scp -r -i #{node[:deploykylin][:runtime][:bootkylin][:emr_master_pem]} -o StrictHostKeyChecking=no #{node[:deploykylin][:runtime][:bootkylin][:emr_master_user]}@#{node[:deploykylin][:runtime][:bootkylin][:emr_master_ip]}:/#{pkg} /usr/bin/"
        user 'root'
        group 'root'
        ignore_failure true
    end
end

pkgs_single = %w{
    usr/share/aws 
}

pkgs_single.flatten.each do |pkg|
    execute "copy_#{pkg}" do
        command "scp -r -i #{node[:deploykylin][:runtime][:bootkylin][:emr_master_pem]} -o StrictHostKeyChecking=no #{node[:deploykylin][:runtime][:bootkylin][:emr_master_user]}@#{node[:deploykylin][:runtime][:bootkylin][:emr_master_ip]}:/#{pkg} /#{pkg}"
        user 'root'
        group 'root'
        ignore_failure true
    end
end

