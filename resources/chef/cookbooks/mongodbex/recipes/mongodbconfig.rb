#
# mongodb config settings
#
#

execute "installphpmongodbex" do
	command 'pecl install mongo'
	cwd '/home/ec2-user'
	not_if 'php -m | grep mongo'
end

execute "dldrupalmongdbmodule" do
	command 'drush dl mongodb'
	cwd '/var/www/html'
	not_if { ::File.exists?("#{node[:mongodbex][:appdir]}/sites/all/modules/contrib/mongodb/mongodb.module")}
end

template "/var/www/html/sites/default/drupal.d/05mongdbex.settings.php" do
	source "05mongodb.settings.php.erb"
	mode 0644
	owner "root"
	group "root"
end
execute "restarthttpd" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end


