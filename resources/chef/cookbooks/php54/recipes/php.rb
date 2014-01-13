execute "prepareformcrypt" do
        command "mkdir -p /root/.ssh"
end

remote_file "#{Chef::Config[:file_cache_path]}/externalsrc.rpm" do
    source "http://mirror.us.leaseweb.net/epel/6/x86_64/epel-release-6-8.noarch.rpm"
    action :create
end

rpm_package "externalsrc" do
    source "#{Chef::Config[:file_cache_path]}/externalsrc.rpm"
    action :install
end

pkgs = [ 'php', 'git', 'php-cli', 'php-fpm', 'php-gd', 'php-mbstring', 'php-mcrypt', 'php-pdo', 'php-xml', 'php-xmlrpc', 'php-mysql','php-pear','php-devel','zlib-devel','libevent','libevent-devel' ]
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


execute "installDrushIfNotExistInDevVM" do
        command "wget --quiet -O - http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz | tar -zxf - -C /usr/local/share; ln -s /usr/local/share/drush/drush /usr/local/bin/drush; drush"
        not_if { ::File.exists?("/usr/local/bin/drush") }
end
