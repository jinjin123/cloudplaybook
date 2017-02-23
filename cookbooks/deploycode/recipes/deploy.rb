directory "/root/.ssh" do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

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

if node[:deployuser] && not((node[:deployuser]).empty?)
  user = node[:deployuser]
  node.default[:deploycode][:code_owner] = node[:deployuser]
  node.default[:deploycode][:code_group] = node[:deployuser]
else
  user = node[:deploycode][:code_owner]
end

#code_owner_home=`cat /etc/passwd| grep #{node[:deploycode][:code_owner]}| cut -d: -f6| tr -d '\040\011\012\015'`
#if code_owner_home.to_s.strip.length == 0
# By piping Json input into this cookbook
#if not (defined?(node[:deployuser])).nil? && node[:deployuser] != "root"
#if user != "root"
#  code_owner_home="/home/#{node[:deployuser]}"

if defined?(node[:deployuser]) 
  user = node[:deployuser]

if user.include?("root")
  code_owner_home="/root"
else
  code_owner_home="/home/#{user}"
end

  file "#{code_owner_home}/.ssh/authorized_keys" do
   backup 5
   mode 0600
   owner user
   group user
   action :touch
  end

  directory "#{code_owner_home}/.ssh" do
    owner user
    group user
    mode '0700'
    recursive true
    action :create
  end

  template "#{code_owner_home}/.ssh/config" do
    source "config.erb"
    mode 0600
    owner user
    group user
    retries 3
    retry_delay 30
  end

  template "#{code_owner_home}/.ssh/gitkey" do
    source "gitkey.erb"
    mode 0600
    owner user
    group user
    retries 3
    retry_delay 30
  end

  template "#{code_owner_home}/.ssh/gitkey.pub" do
    source "gitkey.pub.erb"
    mode 0600
    owner user
    group user
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
end

basedir = node[:deploycode][:basedirectory]

#Create directory
node[:deploycode][:localfolder].each do |localfolder,giturl|
  next if localfolder.include?("nocreatefolder")
  directory basedir + localfolder do
    recursive true
    owner node[:deploycode][:code_owner]
    group node[:deploycode][:code_group]
    mode '0755'
    action :create
  end
end

#include_recipe 'deploycode::clone_repo'

node[:deploycode][:localfolder].each do |localfolder,gitinfo|
  dir = basedir + localfolder
    #Dont git pull if it is not a git project
    next if gitinfo.include?("nodownload")
  if ! Dir.exist? dir + "/.git"
    execute "clear_directory" do
      command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
      cwd dir
      #notifies :sync, "git[clone_repo_local]", :immediately
    end
    git "clone_repo_new" do
      user node[:deploycode][:code_owner]
      group node[:deploycode][:code_group]
      repository gitinfo[:giturl]
      depth 10
      retries 1
      retry_delay 10
      action :sync
      destination dir
      revision gitinfo[:branch]
      checkout_branch gitinfo[:branch] #The name of the checkouted branch
      enable_checkout true
    end
  else
    #contents = File.read( dir + "/.git/config")
    if File.readlines(dir + "/.git/config").grep(/#{gitinfo[:giturl]}/).any?
      git "pull_repo" do
        user node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        retries 3
        retry_delay 10
        repository gitinfo[:giturl]
        revision gitinfo[:branch]
        checkout_branch gitinfo[:branch] #The name of the checkouted branch
        enable_checkout true
        action :sync
        destination dir
      end        
    else 
      execute "clear_directory" do
        command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
        cwd dir
        #notifies :sync, "git[clone_repo_local]", :immediately
      end
      git "clone_repo_remove_existing" do
        user node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        repository gitinfo[:giturl]
        depth 10
        retries 1
        retry_delay 10
        action :sync
        destination dir
        revision gitinfo[:branch]
        checkout_branch gitinfo[:branch] #The name of the checkouted branch
        enable_checkout true
      end
    end
  end

  file dir + "/ping.html" do
    content '<html></html>'
    mode 0600
    owner node[:deploycode][:code_owner]
    group node[:deploycode][:code_group]
    action :create
  end

  #update changes to docker
  docker_container "#{node[:projectname]}_" + localfolder do
    action :restart
    kill_after 5
    ignore_failure true
  end
end
