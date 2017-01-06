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
  #Directory for drupal folders
  dir = node[:deploycode][:basedirectory] + localfolder 
  directory dir do
    owner 'ec2-user'
    group 'ec2-user'
    mode '0755'
    recursive true
    action :create
  end
  #prepare docker
  if docker[:image].include?("drupal")  
    docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      action :run
      port "80#{count}:80"
      #Map /data/sitename to sitefolder/sites/default/files
      #binds [ dir + ':/var/www/html', '/data/' + localfolder:' + dir + '/sites/default/files' ]
      binds [ dir + ':/var/www/html' ]
    end
    count = count + 1
  #prepare docker
  elsif docker[:image].include?("rmq")
    docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      action :run
      port ['5671:5671','5672:5672','15672:15672','15674:15674','25672:25672']
      binds [ dir + ':/var/lib/rabbitmq' ]
    end
  elsif docker[:image].include?("cdb")
    docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      action :run
      port "#{docker[:port]}:#{docker[:port]}"
      binds [ dir + ':/usr/local/var/lib/couchdb' ]
    end
  elsif docker[:image].include?("oc")
     docker_container 'sparkpadgp_' + localfolder do
      repo docker[:image]
      tag docker[:tag]
      action :run
      port "80#{count}:80"
      binds [ dir + ':/usr/local/tomcat/webapps' ]
    end
    count = count + 1
  #prepare docker
  end
end
