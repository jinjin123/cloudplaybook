pkgs = [ 'php54', 'php54-cli', 'php54-fpm', 'php54-gd', 'php54-mbstring', 'php54-mcrypt', 'php54-pdo', 'php54-xml', 'php54-xmlrpc', 'php54-mysql','php-pear','php54-devel','zlib-devel','libevent','libevent-devel' ]
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
