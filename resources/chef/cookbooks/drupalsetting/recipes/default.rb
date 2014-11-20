#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
template "/var/www/html/sites/default/settings.php" do
        source "settings.php.erb"
        mode 0600
        owner "nginx"
        group "nginx"
        action :create_if_missing
end


