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
  php55-pdo
  php55-cli
  php55-devel 
  php55-gd 
  php55-mbstring 
  php55-xml
  php55-xmlrpc 
  php55-mysqlnd
  php55-mcrypt
  libmemcached
  libmemcached-devel
  cyrus-sasl-devel
}

pkgs.flatten.each do |pkg|

  r = package pkg do
    action( node['php55']['compiletime'] ? :nothing : :install )
  end
  r.run_action(:install) if node['php55']['compiletime']

end

remote_file "/home/ec2-user/tools/memcached-#{node['php55']['memcached-version']}.tgz" do
  source "http://pecl.php.net/get/memcached-#{node['php55']['memcached-version']}.tgz"
end

execute 'Install_php_memcache' do
  command "tar -zxvf memcached-#{node['php55']['memcached-version']}.tgz;cd memcached-#{node['php55']['memcached-version']};phpize;./configure;make;make install;"
  environment ({'LC_ALL' => 'en_US.UTF-8', 'LANG' => 'en_US.UTF-8'})
  cwd '/home/ec2-user/tools/'
end

execute 'enable_memcached' do
  command "sed -i 's/^;\(.*\)extension=msql.so/ extension=memcached.so/' /etc/php.ini"
end

execute 'change_limit' do
  command "sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini"
end
