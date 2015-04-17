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
    ignore_failure true
  end
end

pkgs = [ 'mysql', 'php-pecl-memcache', 'php-cli', 'php-gd', 'php-mbstring', 'php-mcrypt', 'php-pdo', 'php-xml', 'php-xmlrpc', 'php-mysql','php-pear','php-devel','zlib-devel','libevent','libevent-devel' ]
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

#bash "install_mongo" do
#  user "root"
#  cwd "/root"
#  code <<-EOH
#  mkdir /root/mongo-php-driver
#  git clone https://github.com/mongodb/mongo-php-driver.git /root/mongo-php-driver
#  cd /root/mongo-php-driver
#  phpize
#  ./configure
#  make
#  make install
#  EOH
#end

#service "httpd" do
#	action [:enable,:start]
#end
