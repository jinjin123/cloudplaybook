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

docker_registry 'dockerpriv.kybot.io:5001' do
  username 'keithyau'
  password 'thomas123'
  email 'keithyau@sparkpad.com'
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

count = 81
node[:deploycode][:runtime].each do |localfolder,docker|
    #if tagged localdir, give the localfolder as mount poinT 
    if docker[:mountlocal].include?("localdir")
      #Override dir to custom url
      dir = node[:deploycode][:basedirectory] + localfolder
    else
      dir = "#{node[:deploycode][:basedirectory]}#{localfolder}/#{docker[:mountlocal]}"
    end
    #Override port if it is not shared port (mostly common port are 80 and 8080)
    if docker[:port].eql?("80")
      map_port = "90#{count}"
      count = count + 1
    elsif docker[:port].eql?("8080") 
      map_port = "90#{count}"
      count = count + 1
    else 
      map_port = docker[:port]
    end 
  #Directory for drupal folders
  directory dir do
    owner 'ec2-user'
    group 'ec2-user'
    mode '0755'
    recursive true
    action :create
  end
  #prepare docker
  #custom port number add here
  if docker[:image].include?("rmq") 
    docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      action :run
      port ['5671:5671','5672:5672','15672:15672','15674:15674','25672:25672']
      binds [ dir + ':/var/lib/rabbitmq' ]
    end
  else #app_mq #cdb #Drupal
    docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      kill_after 10
      action :run
      ignore_failure true
      port "#{map_port}:#{docker[:port]}"
      #binds [ dir + ':/var/www/html', '/data/' + localfolder:' + dir + '/sites/default/files' ]
      binds [ dir + ":#{docker[:mountdocker]}" ]
    end
  end
end
