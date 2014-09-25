#
# Cookbook Name:: nginx
# Recipe:: default
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
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

#Make sure port 80 is not in use
service "httpd" do
        action :stop 
end

include_recipe "nginx::#{node['nginx']['install_method']}"

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :start
end

execute "changeuserlogin" do
        command "usermod -s /bin/bash nginx"
end

execute "preparesourcefolder" do
        command "if [ -d '/opt/source/app' ];then mkdir -p /opt/source/app;fi"
end

execute "changeowner" do
        command "chown -R nginx:nginx /opt/source/app"
end

execute "lntoapache" do
        command "if [ -d '/var/www/html' ];then ln -sf /opt/source/app /var/www/html;fi"
end

