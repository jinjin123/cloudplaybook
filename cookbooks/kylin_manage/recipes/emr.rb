#
# Cookbook Name:: kylin_manage
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/root/create_emr.sh" do
    source 'create_emr.sh'
    owner 'root'
    group 'root'
    mode '0744'
end
