#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Setup config file
template node["memcached"]["conf"]["path"] do
  source "memcached.conf.erb"
  owner 'root'
  group 'root'
end

# Create /var/run/memcached
directory File.dirname(node["memcached"]["conf"]["pid_file"]) do
  action :create
  owner 'nobody'
  group 'nobody'
  mode 0777
end

# FIX to solve a problem on server reboot (while memcached is running)
file "/etc/tmpfiles.d/memcached.conf" do
  owner 'root'
  group 'root'
  content "# systemd tmpfile settings for memcached
# See tmpfiles.d(5) for details
d #{File.dirname(node["memcached"]["conf"]["pid_file"])} 0777 nobody nobody -
"
end

# Enable and start it
service 'memcached' do
  action [:enable, :restart]
end