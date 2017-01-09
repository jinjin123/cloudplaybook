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

#code_owner_home=`cat /etc/passwd| grep #{node[:deploycode][:code_owner]}| cut -d: -f6| tr -d '\040\011\012\015'`
#if code_owner_home.to_s.strip.length == 0
  code_owner_home="/home/ec2-user"
#end

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

basedir = node[:deploycode][:basedirectory]

node[:deploycode][:localfolder].each do |localfolder,giturl|
  directory basedir + localfolder do
    recursive true
    owner node[:deploycode][:code_owner]
    group node[:deploycode][:code_group]
    mode '0755'
    action :create
  end
end

#include_recipe 'deploycode::clone_repo'

node[:deploycode][:localfolder].each do |localfolder,giturl|
  dir = basedir + localfolder
    #Dont git pull if it is not a git project
    break if giturl.include?("nodownload")
  if ! Dir.exist? dir + "/.git"
    execute "clear_directory" do
      command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
      cwd dir
      #notifies :sync, "git[clone_repo_local]", :immediately
    end
    git "clone_repo_local" do
      user node[:deploycode][:code_owner]
      group node[:deploycode][:code_group]
      repository giturl
      depth 10
      retries 1
      retry_delay 30
      action :sync
      destination dir
      checkout_branch 'master'
      enable_checkout false
    end
  else
    contents = File.read( dir + "/.git/config")
    if contents.include?(giturl)
      git "pull_repo" do
        user node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        retries 3
        retry_delay 30
        repository giturl
        revision 'master'
        action :sync
        destination dir
#       enable_checkout false
#        notifies :run, "execute[git_tag]", :immediately
      end        
    else 
      execute "clear_directory" do
        command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
        cwd dir
        #notifies :sync, "git[clone_repo_local]", :immediately
      end
      git "clone_repo_local" do
        user node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        repository giturl
        depth 10
        retries 1
        retry_delay 30
        action :sync
        destination dir
        checkout_branch 'master'
        enable_checkout false
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
  docker_container 'sparkpadgp_' + localfolder do
    action :restart
    ignore_failure true
  end
end
