#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
template "/var/www/html/sites/default/settings.php" do
        source "settings.php"
        mode 0600
        owner "nginx"
        group "nginx"
        action :create_if_missing
end

directory "/var/www/html/sites/default/files" do
        owner 'nginx'
        group 'nginx'
        mode '0777'
        action :create
end