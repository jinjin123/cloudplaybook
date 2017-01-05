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
yum_package 'docker' do
end

# Assign docker access right to ec2-user
execute 'change_usermod' do
  command 'usermod -aG docker ec2-user'
end

# Start cgconfig service to meet docker prerequisite
service "cgconfig" do
  action :start
end

# Start Docker service
docker_service 'sparkpadgp:2376' do
  host [ "tcp://#{node['ipaddress']}:2376", 'unix:///var/run/docker.sock' ]
  action [:create, :start]
end

# Pull latest image
docker_image 'daocloud.io/drupal' do
  tag '7'
  action :pull
#  notifies :redeploy, 'docker_container[webservice]'
end

count = 0
node[:deploycode][:localfolder].each do |localfolder,giturl|
  #Directory for drupal folders
  dir = node[:deploycode][:basedirectory] + localfolder 
  directory dir do
    owner 'ec2-user'
    group 'ec2-user'
    mode '0755'
    recursive true
    action :create
  end
  count = count + 1
  #prepare docker
  docker_container 'sparkpadgp_' + localfolder do
    repo 'daocloud.io/drupal'
    tag '7'
    action :run
    port "808#{count}:80"
    #Map /data/sitename to sitefolder/sites/default/files
    #binds [ dir + ':/var/www/html', '/data/' + localfolder:' + dir + '/sites/default/files' ]
    binds [ dir + ':/var/www/html' ]
  end
end
