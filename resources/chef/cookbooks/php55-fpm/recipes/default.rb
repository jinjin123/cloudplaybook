#
# Cookbook Name:: php55-fpm
# Recipe:: default
#
# Copyright 2014, BootDev
#
# All rights reserved - Do Not Redistribute
#
#
#

pkgs = %w{
  php55-fpm 
}

pkgs.flatten.each do |pkg|

  r = package pkg do
    action( node['php55-fpm']['compiletime'] ? :nothing : :install )
  end
  r.run_action(:install) if node['php55-fpm']['compiletime']

end

template "/etc/php-fpm.d/www.conf" do
  source "www.conf"
  mode "0644"
  owner 'root'
  group 'root'
end

service "php-fpm" do
  action :start
end
