#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#

basedir = node[:deploycode][:basedirectory]

node[:deploycode][:configuration][:drupal].each do |appname,spec|
  #create custom directories && set permission
  spec[:folders].each do | dir,permission |
    directory basedir + "#{appname}/#{dir}" do
      recursive true
      #Assume all root with docker
      owner 'root'
      group 'root'
      mode "0#{permission}"
      action :create
    end
  end

  #Create custom conf files from cookbook, override the one provided from git
  spec[:settings].each do | sourcefile,dest |

    if (not (defined?(spec[:variables][:dbname])).nil?) && (not "#{spec[:variables][:dbname]}" == "")
      dbname = spec[:variables][:dbname]
    else
      dbname = appname
    end

    #If not set variables, use default
    if (not (defined?(spec[:variables][:dbhost])).nil?) && (not "#{spec[:variables][:dbhost]}" == "")
      dbhost = spec[:variables][:dbhost]
      dbuser = spec[:variables][:dbuser]
      dbpass = spec[:variables][:dbpass]
    else
      dbhost = node[:deploycode][:default][:variables][:dbhost]
      dbuser = node[:deploycode][:default][:variables][:dbuser]
      dbpass = node[:deploycode][:default][:variables][:dbpass]
    end

    template "#{basedir}/#{appname}/#{dest}" do
      #Only support DBvariables for now; todo: support more kinds of variables
      variables(
        :host => dbhost,
        :username => dbuser,
        :password => dbpass,
        :dbname => dbname
      )
        #The filename already in template folder
        source sourcefile
        #Common config file setting
        mode "0644"
        retries 3
        retry_delay 10
        owner "root"
        group "root"
        action :create
        force_unlink true
        ignore_failure true
    end
  end

  docker_container "#{node[:projectname]}_#{appname}" do
    action :restart
    ignore_failure true
  end
end



#Assume no glusterfs for now
#
#node[:deploycode][:localfolder].each do |localfolder,gitinfo|
#  dir = basedir + localfolder
#  # Break if it is not Drupal
#  if gitinfo[:giturl].include?("drupal")
#  bash "mount_if_gluster" do
#    user "root"
#    cwd "/tmp"
#  code <<-EOH
#  if [ `cat /etc/fstab|grep glusterfs| wc -l` -gt 0 ]
#    then
#      mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
#        if [ -d "#{dir}/sites/default" ]; then
#           ln -s `cat /etc/fstab|grep glusterfs| awk '{print $2}'`/#{dir} #{dir}/sites/default/files
#          if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
#            then
#              chown nginx:nginx `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
#            else
#              chown apache:apache `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
#          fi
#        fi
#  else
#    if [ -d "#{dir}/sites/default" ]; then
#      mkdir #{dir}/sites/default/files
#      chmod 777 #{dir}/sites/default/files
#      if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
#        then
#          chown nginx:nginx #{dir}/sites/default/files
#      else
#        chown apache:apache #{dir}/sites/default/files
#      fi
#    fi
#  fi
#    EOH
#  end

#  docker_container "#{node[:projectname]}_" + localfolder do
#    action :restart
#    ignore_failure true
#  end
#  end
#end
