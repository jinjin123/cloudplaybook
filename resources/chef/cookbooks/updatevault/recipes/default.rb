#
# Cookbook Name:: updatevault
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
#
directory "/home/ec2-user/.pem" do
  owner 'root'
  group 'root'
  mode '0744'
  action :create
  ignore_failure true
end

template "/home/ec2-user/.pem/bootdev.pem" do
  source "bootdev.pem"
  mode 0400
  retries 3
  retry_delay 30
  owner "root"
  group "root"
  action :create
  ignore_failure true
end rescue NoMethodError

Role = File.read("/etc/chef/role.txt").tr("\n","")
ChefServerIP = `cat /etc/chef/client.rb|grep chef_server_url|cut -d/ -f3|cut -d. -f1`
ChefServerIP = ChefServerIP.tr("\n","")

template "/etc/chef/run_update.sh" do
  source "run_update.sh"
    variables(
      :ChefServerIP => "#{ChefServerIP}",
      :RoleName => "#{Role}",
    )
      mode 0700
      retries 3
      retry_delay 30
      owner "root"
      group "root"
      action :create
      ignore_failure true
    end rescue NoMethodError

execute 'call_chefserver' do
  command "/etc/chef/run_update.sh"
end

chef_gem "chef-vault"
require "chef-vault"

vault = ChefVault::Item.load("secrets", "secret_key")
vault['secret_key'] = vault['secret_key'].tr(" ", "\n")

file "/etc/chef/secret_key" do
  content vault['secret_key']
  owner "root"
  group "root"
  mode 00600
end