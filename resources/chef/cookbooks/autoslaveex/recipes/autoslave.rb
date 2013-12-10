
execute "drushdlautoslave" do
	command 'drush dl autoslave'
	not_if { ::File.exists?("#{node[:autoslaveex][:appdir]}/sites/all/module/contrib/autoslave/autoslave.module") }
	cwd "#{node[:autoslaveex][:appdir]}"
end

template "#{node[:autoslaveex][:appdir]}/sites/default/drupal.d/04autoslave.settings.php" do
	source "04autoslave.settings.php.erb"
	mode 0644
	owner "root"
	group "root"
end
=begin
ex_code= "if(file_exists('sites/default/autoslave.settings.php')){include_once('sites/default/autoslave.settings.php');}"
execute "update settings.php" do
	command "echo \"#{ex_code}\" >> #{node[:autoslaveex][:appdir]}/sites/default/settings.php"
	not_if "cat #{node[:autoslaveex][:appdir]}/sites/default/settings.php | grep 'autoslave.settings.php' "
	cwd '/root'
end
=end

execute "restarthttp" do
	command '/etc/init.d/httpd restart'
	cwd '/root'
end

