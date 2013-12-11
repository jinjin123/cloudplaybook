#
# mongodb config settings
#
#

execute "installphpmongodbex" do
	command 'pecl install mongo'
	cwd '/home/ec2-user'
	not_if 'php -m | grep mongo'
end

template "/etc/php.d/mongo.ini" do
	source 'mongo.ini.erb'
	mode 0644
	owner "root"
	group "root"
end

execute "dldrupalmongdbmodule" do
	command 'drush dl mongodb'
	cwd '/var/www/html'
	not_if { ::File.exists?("#{node[:mongodbex][:appdir]}/sites/all/modules/contrib/mongodb/mongodb.module")}
end

template "/var/www/html/sites/default/mongdbex.settings.php" do
	source "mongodb.settings.php.erb"
	mode 0644
	owner "root"
	group "root"
end

#ex_code= "if(file_exists('sites/default/mongodb.settings.php')){include_once('sites/default/mongodb.settings.php');}"

#execute "updatesettings.php" do
#	command "echo \"#{ex_code}\" >> #{node[:mongodbex][:appdir]}/sites/default/settings.php"
#	not_if "cat #{node[:mongodbex][:appdir]}/sites/default/settings.php | grep 'mongodb.settings.php' "
#end


execute "restarthttpd" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end


