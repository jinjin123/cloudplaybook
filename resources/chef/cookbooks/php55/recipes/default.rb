#
# Cookbook Name:: php55
# Recipe:: default
#
# Copyright 2014, BootDev
#
# All rights reserved - Do Not Redistribute
#
#
#

pkgs = %w{
  php55 
  php55-mysql 
  php55-pdo
  php55-cli
  php55-devel 
  php55-gd 
  php55-mbstring 
  php55-xml
  php55-xmlrpc 
  php55-mysqlnd
  php-pecl-memcached
  php55-mcrypt
  php55-pear
  
}

pkgs.flatten.each do |pkg|

  r = package pkg do
    action( node['php55']['compiletime'] ? :nothing : :install )
  end
  r.run_action(:install) if node['php55']['compiletime']

end
