#
# Cookbook Name:: drupalsource
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "updatesource" do 
	#command 'echo `whoami` >> /home/ec2-user/who.txt'
	command 'git clone git@bitbucket.org:guojing/privaterepo.git /var/www/html/'
	not_if { ::File.exists?("/var/www/html/.git/config") }
	cwd '/home/ec2-user/'
end

template "/var/www/html/sites/default/settings.php" do
	source "settings.php.erb"
	mode 0640
	owner "ec2-user"
	group "ec2-user"
end
execute "restarthttpd" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end

