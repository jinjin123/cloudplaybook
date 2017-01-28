#
# Cookbook Name:: webserver
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# BootDev defined docker default script

# Check if target web directory is exist, create it if not
# Assign docker access right to user
#yum_package 'docker'

docker_installation_script 'default' do
  repo 'main'
  script_url 'https://get.daocloud.io/docker'
  action :create
end

# Start cgconfig service to meet docker prerequisite 
# (only run in amazon) as centos normally dont use systemvinit now
if node[:platform_family].eql?("rhel") and node[:platform].eql?("amazon")
  service "cgconfig" do
    action :start
  end
end

# Assign docker access right to user
user = node[:deployuser]
execute 'change_usermod' do
  command "usermod -aG docker #{user}"
end

# Start Docker service
docker_service 'default' do
  host 'unix:///var/run/docker.sock'
  action :start
end

docker_registry node[:docker][:privaterepo] do
  username node[:docker][:username]
  password node[:docker][:password]
  email 'support@bootdev.com'
end

#todo make the array be unique elements
node[:deploycode][:runtime].each do |localfolder,docker|
  # Pull latest image
  docker_image docker[:image] do
    tag docker[:tag]
    action :pull
#   notifies :redeploy, 'docker_container[webservice]'
  end
end

etchosts = []
node[:deploycode][:runtime].each do |localfolder,docker|
    #if tagged localdir, give the localfolder as mount poinT 
    if docker[:mountlocal].include?("localdir")
      #Override dir to custom url
      dir = node[:deploycode][:basedirectory] + localfolder
    else
      dir = docker[:mountlocal]
    end

  #Prepare directories
  directory dir do
    owner user
    group user
    mode '0755'
    recursive true
    action :create
  end

  container_name = "#{node[:projectname]}_" + localfolder
  if container_name.eql?("#{node[:projectname]}_mysql") 
    #Add the first docker
    docker_container container_name do
      repo docker[:image]
      tag docker[:tag]
      kill_after 3
      env docker[:env]
      action :run
      #ignore_failure true
      port docker[:ports]
      binds [ dir + ":#{docker[:mountdocker]}" ]
    end
    etchosts.push("#{container_name}:#{container_name}")
    #Break and dont create mysql proxy.conf
    next
  else 
    #prepare dockers
    docker_container container_name do
      repo docker[:image]
      tag docker[:tag]
      #Add all docker link
      links etchosts
      env docker[:env]
      command docker[:command]
      kill_after 5
#      autoremove true
      action :run
      port docker[:ports]
      binds [ dir + ":#{docker[:mountdocker]}" ]
    end
    etchosts.push("#{container_name}:#{container_name}")
  end
 
  #Add proxy.conf to folder if bootproxy defined
  if node[:externalmode].eql?("bootproxy")
    #Prepare bootproxy directories
    directory "#{node[:deploycode][:basedirectory]}bootproxy" do
      owner user
      group user
      mode '0755'
      recursive true
      action :create
    end
   
    if docker[:proxyport].eql?("80")
      portstring = ""
    else
      portstring = ":#{docker[:proxyport]}"
    end

    #Skip template create for bootdev proxy
    next if localfolder.eql?("bootproxy")

    domainprefixset = node[:domainprefix]
    if defined?(docker[:customdomainprefix])
      domainprefixset = docker[:customdomainprefix]
    end
    #Add same amount of proxy templates to Nginx folder
    template "#{node[:deploycode][:basedirectory]}bootproxy/#{localfolder}.proxy.conf" do
      variables(
        :host => container_name,
        :portstring => portstring,
        :prefix => "#{domainprefixset}#{localfolder}",
        :domain => node[:domainname],
      )
        source "proxy.conf"
        mode 0644
        retries 3
        retry_delay 2
        owner "root"
        group "root"
        action :create
#        ignore_failure true
    end
  end

end
