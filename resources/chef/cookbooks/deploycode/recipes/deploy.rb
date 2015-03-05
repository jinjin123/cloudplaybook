template "/root/.ssh/config" do
  source "config.erb"
  mode 0600
  owner "root"
  group "root"
  retries 3
  retry_delay 30
end

template "/root/.ssh/gitkey" do
  source "gitkey.erb"
  mode 0600
  owner "root"
  group "root"
  retries 3
  retry_delay 30
end

template "/root/.ssh/gitkey.pub" do
  source "gitkey.pub.erb"
  mode 0600
  owner "root"
  group "root"
  retries 3
  retry_delay 30
end

code_owner_home=`cat /etc/passwd| grep #{node[:deploycode][:code_owner]}| cut -d: -f6| tr -d '\040\011\012\015'`
if code_owner_home.to_s.strip.length == 0
  code_owner_home="/var/lib/nginx"
end

directory "#{code_owner_home}/.ssh" do
  owner node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  mode '0700'
  action :create
end

template "#{code_owner_home}/.ssh/config" do
  source "config.erb"
  mode 0600
  owner node[:deploycode][:code_owner] 
  group node[:deploycode][:code_group]
  retries 3
  retry_delay 30
end

template "#{code_owner_home}/.ssh/gitkey" do
  source "gitkey.erb"
  mode 0600
  owner node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  retries 3
  retry_delay 30
end

template "#{code_owner_home}/.ssh/gitkey.pub" do
  source "gitkey.pub.erb"
  mode 0600
  owner node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  retries 3
  retry_delay 30
end

ruby_block "Change key config file" do
  block do
    fe = Chef::Util::FileEdit.new("#{code_owner_home}/.ssh/config")
    fe.search_file_replace("/root/","#{code_owner_home}/")
    fe.write_file
  end
end

directory node[:deploycode][:localsourcefolder] do
  recursive true
  owner node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  mode '0755'
  action :create
end

include_recipe 'deploycode::clone_repo'

execute "git_tag" do
  command 'git tag -a v_`date +"%Y%m%d%H%M%S"` -m "Code Deploy";git push --tags'
  cwd node[:deploycode][:localsourcefolder]
  user node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  action :nothing
end

if ! Dir.exist? "#{node[:deploycode][:localsourcefolder]}/.git"
  execute "clear_directory" do
  command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
  cwd node[:deploycode][:localsourcefolder]
  notifies :sync, "git[clone_repo]", :immediately
  end
else
  contents = File.read("#{node[:deploycode][:localsourcefolder]}/.git/config")
  if contents.include?(node[:deploycode][:gitrepo])
    git "pull_repo" do
      user node[:deploycode][:code_owner]
      group node[:deploycode][:code_group]
      retries 3
      retry_delay 30
      repository node[:deploycode][:gitrepo]
#      reference "master"
      action :sync
      destination node[:deploycode][:localsourcefolder]
      notifies :run, "execute[git_tag]", :immediately
    end        
  else 
    execute "clear_directory" do
      command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
      cwd node[:deploycode][:localsourcefolder]
      notifies :sync, "git[clone_repo]", :immediately
    end
  end
end

# if git repository is drupal, then run drupal_settings
ruby_block "CheckDrupal" do
  block do
    Existance = 0
    CheckDrucloud = `cat /var/www/html/.git/config|grep drucloud|wc -l`
    Existance = CheckDrucloud.to_i
    run = ""
# if /etc/chef/validation.pem, it is a typical chef-client, otherwise, it is a chef-solo
    if Existance > 0
      if !File.file?('/etc/chef/validation.pem')
         exec("chef-solo -o 'recipe[drupal_settings]';su -c \"source /var/lib/nginx/.bashrc;cd #{node[:deploycode][:localsourcefolder]}/sites/default;drush site-install drucloud --account-name=admin --account-pass=admin --site-name=drucloudaws --yes\" -m \"#{node[:deploycode][:code_owner]}\" ")
      else
         exec("chef-client -o 'recipe[drupal_settings]'")
      end
    end
    print run
  end
end

file "#{node[:deploycode][:localsourcefolder]}/ping.html" do
  content '<html></html>'
  mode 0600
  owner node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  action :create
end

service "nginx" do
  action :restart
  ignore_failure true
end

service "php-fpm" do
  action :restart
  ignore_failure true
end
