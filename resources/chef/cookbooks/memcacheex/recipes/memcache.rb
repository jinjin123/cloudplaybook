execute "prepareresource" do
	command "mkdir -p /home/ec2-user/tools;wget -O /home/ec2-user/tools/memcache.tar.gz http://pecl.php.net/get/memcache-2.2.7.tgz;tar zxf /home/ec2-user/tools/memcache.tar.gz -C /home/ec2-user/tools"
	cwd "/home/ec2-user"
	not_if { ::File.exists?("/etc/php.d/memcache.ini")}
	notifies :run, 'execute[installmemcache]', :immediately
end
execute "installmemcache" do 
	command "phpize ;./configure;make && make install"
	cwd "/home/ec2-user/tools/memcache-2.2.7"
	action :nothing
	notifies :run, 'execute[drushdlmemcache]', :immediately
end


execute "drushdlmemcache" do
	command 'drush dl memcache'
	not_if { ::File.exists?("#{node[:memcacheex][:appdir]}/sites/all/modules/contrib/memcache/memcache.module") }
	cwd "#{node[:memcacheex][:appdir]}"
	action :nothing
end

template "/etc/php.d/memcache.ini" do
        source "memcache.ini.erb"
        mode 0644
        owner "root"
        group "root"
end

template "#{node[:memcacheex][:appdir]}/sites/default/memcache.settings.php" do
	source "memcache.settings.php.erb"
	mode 0644
	owner "root"
	group "root"
end

ex_code= "if(file_exists('sites/default/memcache.settings.php')){include_once('sites/default/memcache.settings.php');}"
execute "update settings.php" do
        command "echo \"#{ex_code}\" >> #{node[:memcacheex][:appdir]}/sites/default/settings.php"
        not_if "cat #{node[:memcacheex][:appdir]}/sites/default/settings.php | grep 'memcache.settings.php' "
        cwd '/root'
end



execute "restarthttpd" do
	command "/etc/init.d/httpd restart"
	cwd '/root'
end



