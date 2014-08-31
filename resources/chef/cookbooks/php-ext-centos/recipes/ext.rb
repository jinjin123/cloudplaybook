execute "prepareformcrypt" do
        command "mkdir -p /root/.ssh"
end

remote_file "#{Chef::Config[:file_cache_path]}/externalsrc.rpm" do
    source "http://mirror.us.leaseweb.net/epel/6/x86_64/epel-release-6-8.noarch.rpm"
    action :create
end

if platform?("centos")
  rpm_package "externalsrc" do
    source "#{Chef::Config[:file_cache_path]}/externalsrc.rpm"
    action :install
  end
end

if platform?("amazon")
  rpm_package "externalsrc" do
    source "#{Chef::Config[:file_cache_path]}/externalsrc.rpm"
    action :upgrade
  end
end

pkgs = [ 'mysql', 'php-memcache', 'php-cli', 'php-gd', 'php-mbstring', 'php-mcrypt', 'php-pdo', 'php-xml', 'php-xmlrpc', 'php-mysql','php-pear','php-devel','zlib-devel','libevent','libevent-devel' ]
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "httpd" do
	action [:enable,:start]
end
