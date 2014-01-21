#
# Cookbook Name:: drupalsource
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


=begin
execute "downloadsource" do 
	#command 'echo `whoami` >> /home/ec2-user/who.txt'
	command "git clone #{node[:drupalsource][:gitrepo]} #{node[:drupalsource][:appdir]}/"
	not_if { ::File.exists?("#{node[:drupalsource][:appdir]}/.git/config") }
	
end
=end

#create app user if not exist
execute "createappuser" do
	command "useradd -c 'app user' -s /bin/bash -m #{node[:drupalsource][:appuser]} -d /home/#{node[:drupalsource][:appuser]} -G apache"
	not_if "cat /etc/passwd | grep #{node[:drupalsource][:appuser]}"
end

execute "preparemountdir" do
	command "mkdir -p #{node[:drupalsource][:localsourcefolder]}"
end

execute "mountnfsfile" do
	command "mount -t nfs #{node[:drupalsource][:nfsserverip]}:#{node[:drupalsource][:nfssharefolder]} #{node[:drupalsource][:localsourcefolder]}"
	not_if "cat /proc/mounts | grep nfs"
end

execute "lntoapache" do
        command "rm -rf /var/www/html;ln -sf #{node[:drupalsource][:localsourcefolder]} /var/www/html"
end


#execute "changemod" do
#	command "chown -R #{node[:drupalsource][:appuser]}:apache #{node[:drupalsource][:appdir]}/*"
#end


=begin
execute "getsourcefroms3" do 
	command "s3fs -ouse_cache=/tmp -odefault_acl=public-read drupalsourcecode /mnt"	
	not_if "cat /proc/mounts|grep s3fs|awk '{print $2}' | grep mnt"
end

execute "createhardlink" do 
	command "ln -f /mnt/drupal /var/www/html"
end
=end


execute "makecustomdir " do
	command "mkdir -p contrib custom features;chmod 755 contrib custom features;chown -R webapp:apache contrib custom features" 
	cwd "#{node[:drupalsource][:appdir]}/sites/all/modules"
	not_if { ::File.exists?("#{node[:drupalsource][:appdir]}/sites/all/modules/contrib")}
end

execute "makefiledir" do
	command "mkdir -p files files/ctools files/ctools/css files/private files/private/awssns_keys;chmod 777 files;chmod 755 files/private;chown -R #{node[:drupalsource][:appuser]}:apache files "
	cwd "#{node[:drupalsource][:appdir]}/sites/default"
end

template "#{node[:drupalsource][:appdir]}/sites/default/files/.htaccess" do
	source "filesht.erb"
	owner "webapp"
	group "apache"
	mode "0444"
end
template "#{node[:drupalsource][:appdir]}/sites/default/files/private/.htaccess" do
	source "privateht.erb"
	owner "webapp"
	group "apache"
	mode "0444"
end




template "#{node[:drupalsource][:appdir]}/sites/default/settings.php" do
	source "settings.php.erb"
	mode 0644
	owner "#{node[:drupalsource][:appuser]}"
	group "apache"
end

template "#{node[:drupalsource][:appdir]}/sites/default/db.settings.php" do
	source "db.settings.php.erb"
	mode 0644
	owner "#{node[:drupalsource][:appuser]}"
	group "apache"
end

=begin
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
=end
template "/etc/httpd/conf/httpd.conf" do
	source "httpd.conf.erb"
	mode 0644
	owner "root"
	group "root"
end

execute "restarthttpd" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end

