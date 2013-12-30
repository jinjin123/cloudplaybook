#
# Cookbook Name:: drupalsource
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "downloadsource" do 
	#command 'echo `whoami` >> /home/ec2-user/who.txt'
	command "git clone #{node[:drupalsource][:gitrepo]} #{node[:drupalsource][:appdir]}/"
	not_if { ::File.exists?("#{node[:drupalsource][:appdir]}/.git/config") }
	cwd '/home/ec2-user/'
end
execute "makecustomdir " do
	command "mkdir -p contrib custom features;chmod 777 contrib custom features" 
	cwd "#{node[:drupalsource][:appdir]}/sites/all/modules"
	not_if { ::File.exists?("#{node[:drupalsource][:appdir]}/sites/all/modules/contrib")}
end

execute "makefiledir" do
	command "mkdir -p files files/ctools files/ctools/ files/ctools/css files/private files/private/awssns_keys;chmod 777 files;chmod 755 files/private;"
	cwd "#{node[:drupalsource][:appdir]}/sites/default"
	not_if { ::File.exists?("#{node[:drupalsource][:appdir]}/sites/default/files")}
end

template "#{node[:drupalsource][:appdir]}/sites/default/files/.htaccess" do
	source "filesht.erb"
	owner "apache"
	group "apache"
	mode "0444"
end
template "#{node[:drupalsource][:appdir]}/sites/default/files/private/.htaccess" do
	source "privateht.erb"
	owner "apache"
	group "apache"
	mode "0444"
end

=begin
directory "#{node[:drupalsource][:appdir]}/sites/default/drupal.d" do
	owner "root"
	group "root"
	mode 00766
	action :create
end
=end


template "/var/www/html/sites/default/settings.php" do
	source "settings.php.erb"
	mode 0644
	owner "apache"
	group "apache"
end
template "/etc/httpd/modifyHttpConfig" do
	source "modifyHttpConfig.erb"
	mode 0644
	owner "root"
	group "root"
end
execute "update http config" do
	command 'cat modifyHttpConfig >> /etc/httpd/conf/httpd.conf'
	not_if "cat /etc/httpd/conf/httpd.conf | grep 'End of AWS Settings'"
	cwd '/etc/httpd'
end

execute "change source owner" do
	command "chown -R apache:apache #{node[:drupalsource][:appdir]};chown -R apache:apache #{node[:drupalsource][:appdir]}/*;chown -R apache:apache #{node[:drupalsource][:appdir]}/.[a-zA-Z]*;"
	cwd "/root"
end

execute "restarthttpd" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end

