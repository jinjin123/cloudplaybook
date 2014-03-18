#
# Cookbook Name:: basicservice
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "basicservice::rpc"
include_recipe "basicservice::glusterfs"

#create app user if not exist
=begin
execute "createappuser" do
        command "useradd -c 'app user' -s /bin/bash -m webapp -d /home/webapp -G apache"
        not_if "cat /etc/passwd | grep webapp"
end
=end
