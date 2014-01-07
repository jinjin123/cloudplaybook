pkgs = [ 'php', 'php-cli', 'php-fpm', 'php-gd', 'php-mbstring', 'php-mcrypt', 'php-pdo', 'php-xml', 'php-xmlrpc', 'php-mysql','php-pear','php-devel','zlib-devel','libevent','libevent-devel' ]
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

template "/root/.ssh/config" do
	source "config.erb"
	mode 0600
	owner "root"
	group "root"
end
template "/root/.ssh/bitbucket" do
	source "bitbucket.erb"
	mode 0600
	owner "root"
	group "root"
end
template "/root/.ssh/bitbucket.pub" do
	source "bitbucket.pub.erb"
	mode 0600
	owner "root"
	group "root"
end
template "/root/.ssh/known_hosts" do
	source "known_hosts.erb"
	mode 0600
	owner "root"
	group "root"
end
service "httpd" do
	action [:enable,:start]
end
