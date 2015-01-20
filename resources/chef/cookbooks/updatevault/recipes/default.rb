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

chef_gem "chef-vault"
require "chef-vault"

vault = ChefVault::Item.load("secrets", "secret_key")

file "/etc/chef/secret_key" do
  content vault['secret_key']
  owner "root"
  group "root"
  mode 00600
end

file_names = ['/etc/chef/secret_key']
file_names.each do |file_name|
  text = File.read(file_name)
  new_contents = text.gsub(/ /, "\n")
  # To write changes to the file, use:
  File.open(file_name, "w") {|file| file.puts new_contents }
end