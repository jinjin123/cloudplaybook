#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
mysql_database node['mysql']['database'] do
    connection  ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
    action :create
end

mysql_database_user node['mysql']['db_username'] do
    connection  ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
    password node['mysql']['db_password']
    database_name node['mysql']['database']
    privileges [:select, :update, :insert, :create, :delete]
    action :create
end
