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
directory '/var/www/html' do
  owner 'ec2-user'
  group 'ec2-user'
  mode '0755'
  action :create
end

# Install Docker
docker_installation_script 'default' do
  repo 'main'
  script_url 'https://get.docker.com'
#  script_url 'https://my.computers.biz/dist/scripts/docker.sh'
  action :create
end

# Assign docker access right to ec2-user
execute 'change_usermod' do
  command 'usermod -aG docker ec2-user'
end

# Start cgconfig service to meet docker prerequisite
service "cgconfig" do
  action :start
end

## Start docker
#docker_service_manager 'default' do
#  action :start
#end

# Start Docker service
docker_service 'bootdev:2376' do
  host [ "tcp://#{node['ipaddress']}:2376", 'unix:///var/run/docker.sock' ]
  action [:create, :start]
end

#docker_registry 'daocloud.io' do
#  username 'bootdev'
#  password 'B00tDev!'
docker_registry 'docker-registry.bootdev.com:5000' do
  username 'keithyau'
  password 'thomas123'
  email 'chankongching@gmail.com'
end

# Pull latest image
#docker_image 'daocloud.io/bootdev/webservice' do
#docker_image 'daocloud.io/library/tomcat' do
docker_image 'docker-registry.bootdev.com:5000/tomcat' do
  tag '9'
  action :pull
#  notifies :redeploy, 'docker_container[webservice]'
end

#docker_image 'bootdev/webservice' do
#  tag 'latest'
#  action :pull
#  notifies :redeploy, 'docker_container[webservice]'
#end

## Run container
# First killing old one
#docker_container 'webservice' do
#  action :kill
#end

#docker_container 'webservice' do
#  repo 'daocloud.io/bootdev/webservice'
#  tag 'latest'
#  action :run
#  port '80:80'
#  binds [ '/var/www/html:/usr/local/nginx' ]
#end
