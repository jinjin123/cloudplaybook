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

script "call_chefserver_updatevault" do
  interpreter "bash"
  user "root"
  code <<-EOH
  ssh -i /home/ec2-user/.pem/bootdev.pem
  EOH
end
