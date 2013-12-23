template "#{node[:awsex][:appdir]}/sites/default/aws.settings.php" do
	source "aws.settings.php.erb"
	mode 0644
	owner "apache"
	group "apache"
end

execute "installcomposerex" do
	command "curl -sS https://getcomposer.org/installer | php;mv composer.phar /usr/bin/composer"
	cwd "#{node[:awsex][:appdir]}/sites/all/libraries/awssdk"
	not_if { ::File.exists?("/usr/bin/composer") }
	notifies :run , 'execute[installdrushcomposer]', :immediately
end

execute "installdrushcomposer" do 
	command "composer install;drush dl composer-8.x-1.x-dev;drush composer install;drush cc all"
	cwd "#{node[:awsex][:appdir]}/sites/all/libraries/awssdk"
	action :nothing
end

execute "cleandrush" do
	command "drush cc all"
	cwd "#{node[:awsex][:appdir]}/sites"
end





