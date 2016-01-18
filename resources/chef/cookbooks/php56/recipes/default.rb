#
# Cookbook Name:: php56
# Recipe:: default
#
# Copyright 2014, BootDev
#
# All rights reserved - Do Not Redistribute
#
#
#
#  php56
#  php56-pdo
#  php56-cli
#  php56-devel
#  php56-gd
#  php56-mbstring
#  php56-xml
#  php56-xmlrpc
#  php56-mysqlnd
#  php56-mcrypt
#  libmemcached
#  libmemcached-devel
#  cyrus-sasl-devel
#  php56-fpm

pkgs = %w{
  php56 
  php56-cli 
  php56-common 
  php56-devel 
  php56-gd 
  php56-mbstring 
  php56-mysqlnd 
  php56-opcache 
  php56-pdo 
  php56-process 
  php56-pecl-memcached 
  php56-xml 
  php56-xmlrpc
}

pkgs.flatten.each do |pkg|

  r = package pkg do
    action( node['php56']['compiletime'] ? :nothing : :install )
  end
  r.run_action(:install) if node['php56']['compiletime']

end

#remote_file "/home/ec2-user/tools/memcached-#{node['php56']['memcached-version']}.tgz" do
#  source "http://pecl.php.net/get/memcached-#{node['php56']['memcached-version']}.tgz"
#end

#execute 'Install_php_memcache' do
#  command "tar -zxvf memcached-#{node['php56']['memcached-version']}.tgz;cd memcached-#{node['php56']['memcached-version']};phpize;./configure;make;make install;"
#  environment ({'LC_ALL' => 'en_US.UTF-8', 'LANG' => 'en_US.UTF-8'})
#  cwd '/home/ec2-user/tools/'
#end

#execute 'enable_memcached' do
#  command "sed -i 's/^;\(.*\)extension=msql.so/ extension=memcached.so/' /etc/php.ini"
#end

execute 'change_limit' do
  command "sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini;sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php.ini"
end

template 'opcache.ini' do
  source 'opcache.ini'
  path "/etc/php.d/10-opcache.ini"
  owner 'root'
  group 'root'
  mode '0644'
end
