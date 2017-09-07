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
# yum_package 'docker'

# Moving bootproxy dirctory to one path upper than basedirectory

include_recipe 'yum'
basedir = node[:deploycode][:basedirectory]
projectname = node[:projectname]

docker_installation_script 'default' do
  retries 3
  ignore_failure true
  repo 'main'
  script_url 'https://get.daocloud.io/docker'
  action :create
end

ruby_block "check_docker" do
  block do
  #tricky way to load this Chef::Mixin::ShellOut utilities
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    command = 'command -v docker| wc -l'
    command_out = shell_out(command)
    node.set['docker_exists'] = command_out.stdout
  end
  action :create
end

# ruby_block 'install_docker_iffail' do
#   block do
#     if not node['docker_exists'].to_i > 0
#       resources(:yum_package => "docker").run_action(:install)
#     end
#   end
# end
#
# yum_package 'docker' do
#   action :nothing
# end
ruby_block 'install_docker_iffail' do
    block do
      if not node['docker_exists'].to_i > 0
        system("yum install -y docker")
      end
    end
  end

# Start cgconfig service to meet docker prerequisite
# (only run in amazon) as centos normally dont use systemvinit now
if node[:platform_family].eql?("rhel") and node[:platform].eql?("amazon")
  service "cgconfig" do
    action :start
  end
end

# Assign docker access right to user
user = node[:webserver][:code_owner]
if defined?(node[:deployuser])
    user = node[:deployuser]
end

#log 'message1' do
#  message "Log message:User = " + node[:webserver][:code_owner]
#  level :info
#end

#log 'message2' do
#  message "Log message:User = " + user
#  level :info
#end

execute 'change_usermod' do
  command "usermod -aG docker #{user}||true;usermod -aG dockerroot #{user}||true"
end

# Start Docker service
docker_service 'default' do
  host 'unix:///var/run/docker.sock'
  userland_proxy false
  ipv6 false
  action :start
end

if (not (defined?(node[:docker][:privaterepo])).nil?) && (not "#{node[:docker][:privaterepo]}" == "")
  docker_registry node[:docker][:privaterepo] do
    username node[:docker][:username]
    password node[:docker][:password]
    email 'support@bootdev.com'
  end
end

#todo make the array be unique elements
if (not (defined?(node[:deploycode][:runtime])).nil?) && (not "#{node[:deploycode][:runtime]}" == "")
  node[:deploycode][:runtime].each do |localfolder,docker|
    # Pull latest image
    docker_image docker[:image] do
      tag docker[:tag]
      action :pull
  #   notifies :redeploy, 'docker_container[webservice]'
    end
  end
end

etchosts = []
if (not (defined?(node[:deploycode][:runtime])).nil?) && (not "#{node[:deploycode][:runtime]}" == "")
  node[:deploycode][:runtime].each do |localfolder,docker|
    #if tagged localdir, give the localfolder as mount point

    if (not (defined?(docker[:mountlocal])).nil?) && (not "#{docker[:mountlocal]}" == "")
      # Preparing directory
      if localfolder.eql?("bootproxy")
        if docker[:mountlocal].eql?("multipledir")
          node.default["bindvolume"] = docker[:mountdocker]
        else
          dir_name = "#{node[:deploycode][:basedirectory]}../bootproxy"
          node.default["bindvolume"] = [ "#{node[:deploycode][:basedirectory]}../bootproxy:#{docker[:mountdocker]}" ]
        end
      elsif docker[:mountlocal].eql?("localdir")
        #Override dir to custom url
        dir_name = "#{node[:deploycode][:basedirectory]}#{localfolder}"
        node.default["bindvolume"] = [ "#{node[:deploycode][:basedirectory]}#{localfolder}:#{docker[:mountdocker]}" ]
      else
        if docker[:mountlocal].eql?("multipledir")
          node.default["bindvolume"] = docker[:mountdocker]
        else
          dir_name = docker[:mountlocal]
          node.default["bindvolume"] = [ "#{docker[:mountlocal]}:#{docker[:mountdocker]}" ]
        end
      end

      if not docker[:mountlocal].eql?("multipledir") && (not (defined?(dir_name)).nil?)
        if localfolder.eql?("mysql")
          dir_permission = '0777'
        else
          dir_permission = '0755'
        end
        #Prepare directories
        directory "#{dir_name}" do
          owner user
          group user
          mode "#{dir_permission}"
          recursive true
          ignore_failure true
          action :create
        end
      end
    else
      node.default["bindvolume"] = nil
    end

    if (not (defined?(node[:deploycode][:configuration][:general][localfolder])).nil?) && (not "#{node[:deploycode][:configuration][:general]}" == "")
      spec = node[:deploycode][:configuration][:general][localfolder]
      if !spec
        spec = []
      end
      if not node.default["bindvolume"].nil?
        if localfolder.eql?("bootproxy")
          FULLPATH="#{basedir}../#{localfolder}_configuration"
        else
          FULLPATH="#{basedir}#{localfolder}_configuration"
        end
        spec.each do |file,path|
          node.default["bindvolume"].push("#{FULLPATH}/#{file}:#{path}")
        end
      end
    end

    # Begin running containers
    container_name = "#{node[:projectname]}_" + localfolder
    if container_name.eql?("#{node[:projectname]}_mysql")
      #Add the first docker
      docker_container container_name do
        repo docker[:image]
        tag docker[:tag]
        kill_after 3
        env docker[:env]
        command '--sql-mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"'
        action :run
        #ignore_failure true
        port docker[:ports]
        volumes node.default["bindvolume"]
      end
      etchosts.push("#{container_name}:#{container_name}")
      #Break and dont create mysql proxy.conf
      next
    else
      node.run_state[:linking] = []
      #Special handling if bootproxy,  get all local running docker id and name and link into bootproxy
      if localfolder.eql?("bootproxy")
        container_name = localfolder
        node.set[:dockerinfo] = []
        results = "/tmp/dockerinfo.txt"
        file results do
          action :delete
        end

        cmd = "docker ps|grep -v CONTAINER|grep -v monitor|grep -v ' rancher/'| awk \'{print $1, $NF}\'"
        bash cmd do
          code <<-EOH
          #{cmd} > #{results}
          EOH
        end

        ruby_block "removehostmode" do
          only_if { "cat #{results}| wc -l;while [ $? -ne 0 ]; do cat #{results}| wc -l;done" }
          # only_if { ::File.exists?(results) }
          block do
            f = File.open(results)
            dockerinfo = Hash.new
            f.each do |line|
              dockerinfo[line.chomp.split(' ')[0]] = line.chomp.split(' ')[1]
            end
            f.close
            dockerinfo.each do |hash, dockername|
              # node.run_state[:linking].push("#{dockername}:#{dockername}")
              %x[export CHECKNETWORKMODE=`docker inspect #{hash}| grep NetworkMode| grep host| wc -l`;if [ \"$CHECKNETWORKMODE\" -ne \"0\" ]; then sed -i '/#{hash}/d' #{results};fi]
            end
          end
        end

        ruby_block "result" do
          only_if { "cat #{results}| wc -l;while [ $? -ne 0 ]; do cat #{results}| wc -l;done" }
          # only_if { ::File.exists?(results) }
          block do
            f = File.open(results)
            dockerinfo = Hash.new
            f.each do |line|
              dockerinfo[line.chomp.split(' ')[0]] = line.chomp.split(' ')[1]
            end
            f.close
            dockerinfo.each do |hash, dockername|
              node.run_state[:linking].push("#{dockername}:#{dockername}")
            end
            # Removing bootproxy entry
            node.run_state[:linking] = node.run_state[:linking] - ["bootproxy:bootproxy"]
          end
        end
      else
        node.run_state[:linking] = etchosts
      end

      if node.default["bindvolume"].eql?([":"])
        node.default["bindvolume"] = nil
      end
#      if (not (defined?(docker[:memory_limit])).nil?) && (not "#{docker[:memory_limit]}" == "")
#        memory_limit = docker[:memory_limit]
#      else
#        memory_limit = -1
#      end
      if (not (defined?(docker[:network_mode])).nil?) && (not "#{docker[:network_mode]}" == "")
        if docker[:network_mode].eql?("host")
          node.run_state[:linking] = ""
        end
      end

      # Checking restart behavior of docker
      if (not (defined?(docker[:restart])).nil?) && (not "#{docker[:restart]}" == "")
        restartbehavior = kylin[:restart]
      else
        restartbehavior = "true"
      end

      if restartbehavior.eql?("true")
        if localfolder.eql?("bootproxy")
          # Using lazy evaluation if bootproxy
          docker_container container_name do
            repo docker[:image]
            tag docker[:tag]
            #Add all docker link
            # links node.set[:linking]
            links lazy{node.run_state[:linking]}
            env docker[:env]
            command docker[:command]
            kill_after 30
      #      autoremove true
            action :run
            port docker[:ports]
            volumes node.default["bindvolume"]
            cap_add 'SYS_ADMIN'
            devices []
            privileged true
            timeout 30
            memory docker[:memory_limit]
            network_mode docker[:network_mode]
      #      {["/dev/fuse"]}
          end
        else
          docker_container container_name do
            repo docker[:image]
            tag docker[:tag]
            #Add all docker link
            links node.run_state[:linking]
            env docker[:env]
            command docker[:command]
            kill_after 30
      #      autoremove true
            action :run
            port docker[:ports]
            volumes node.default["bindvolume"]
            cap_add 'SYS_ADMIN'
            devices []
            privileged true
            timeout 30
            memory docker[:memory_limit]
            network_mode docker[:network_mode]
      #      {["/dev/fuse"]}
          end
        end
      end

      if (not (defined?(docker[:exec])).nil?) && (not "#{docker[:exec]}" == "")
        execute 'execute command inside docker' do
        command "docker exec -i #{container_name} /bin/bash -c \'#{docker[:exec]}\';docker restart #{container_name}"
        end
      end
      if (not (defined?(docker[:network_mode])).nil?) && (not "#{docker[:network_mode]}" == "")
        if docker[:network_mode].eql?("host")
          node.run_state[:linking] = ""
        else
          etchosts.push("#{container_name}:#{container_name}")
        end
      else
        etchosts.push("#{container_name}:#{container_name}")
      end
    end

    #Add proxy.conf to folder if bootproxy defined
    if defined?(node[:externalmode]) && node[:externalmode].eql?("bootproxy")
      #Prepare bootproxy directories
      directory "#{node[:deploycode][:basedirectory]}../bootproxy" do
        owner user
        group user
        mode '0755'
        recursive true
        action :create
      end

      # if docker[:proxyport].eql?("80")
      #   portstring = ""
      # else
      #   portstring = ":#{docker[:proxyport]}"
      # end

      #Skip template create for bootdev proxy
      next if localfolder.eql?("bootproxy")

      # Setting Domain name for application
      domainstring = "#{localfolder}.#{node[:domainname]}"
      if (not (defined?(docker[:customdomainstring])).nil?) && (not "#{docker[:customdomainstring]}" == "")
        domainstring = docker[:customdomainstring]
      else
        domainprefixset = node[:domainprefix]
        if (not (defined?(docker[:customdomainprefix])).nil?) && (not "#{docker[:customdomainprefix]}" == "")
          domainprefixset = docker[:customdomainprefix]
        end

        domainsuffixset = node[:domainsuffix]
        if (not (defined?(docker[:customdomainsuffix])).nil?) && (not "#{docker[:customdomainsuffix]}" == "")
          domainsuffixset = docker[:customdomainsuffix]
        end

        if (not (defined?(docker[:overridesubdomain])).nil?) && (not "#{docker[:overridesubdomain]}" == "")
          if docker[:overridesubdomain].eql?("www")
            domainstring = "#{docker[:overridesubdomain]}.#{node[:domainname]} #{node[:domainname]}"
          else
            domainstring = "#{docker[:overridesubdomain]}.#{node[:domainname]}"
          end
        else
          if (not (defined?(domainprefixset)).nil?) && (not "#{domainprefixset}" == "")
            domainstring = "#{domainprefixset}#{localfolder}.#{node[:domainname]}"
          elsif (not (defined?(domainsuffixset)).nil?) && (not "#{domainsuffixset}" == "")
            domainstring = "#{localfolder}#{domainsuffixset}.#{node[:domainname]}"
          end
        end
      end

      # Preparing variables for https
      https = false
      if (not (defined?(docker[:https])).nil?)
        https = docker[:https]
      end

      # # Adding domain parameter
      # domain = true
      # if (not (defined?(docker[:domain])).nil?)
      #   domain = docker[:domain]
      # end


      # Configuration of network mode of docker

      if (not (defined?(docker[:network_mode])).nil?) && (not "#{docker[:network_mode]}" == "")
        next if docker[:network_mode].eql?("host")
      end

      # if (domain == true)
        if (not (defined?(docker[:ports]).nil?)) && (not "#{docker[:ports]}" == "")
          if ! docker[:ports].kind_of?(Array)
            portnumber = docker[:ports].chomp.split(':')[1]
            template "#{node[:deploycode][:basedirectory]}../bootproxy/#{node[:projectname]}.#{localfolder}.proxy.conf" do
              variables(
                :host => container_name,
                :domain  => domainstring,
                :proxyport => portnumber,
                :https => https
              )
              source "proxy.conf"
              mode 0644
              retries 3
              retry_delay 2
              ignore_failure
              owner "root"
              group "root"
              action :create
          #    ignore_failure true
            end
          end
        end
      # end
    end
  end
end
