#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#

node[:deploycode][:localfolder].each do |localfolder,giturl|
  # Break if it is not Drupal
  break if !giturl.include?("drupal")
  dir = node[:deploycode][:basedirectory] + localfolder
  bash "mount_if_gluster" do
    user "root"
    cwd "/tmp"
  code <<-EOH
  if [ `cat /etc/fstab|grep glusterfs| wc -l` -gt 0 ]
    then
      mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
        if [ -d "#{dir}/sites/default" ]; then
          #ln -s `cat /etc/fstab|grep glusterfs| awk '{print $2}'`/#{dir} #{dir}/sites/default/files
          if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
            then
              chown nginx:nginx `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
            else
              chown apache:apache `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
          fi
        fi
  else
    if [ -d "#{dir}/sites/default" ]; then
      mkdir #{dir}/sites/default/files
      chmod 777 #{dir}/sites/default/files
      if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
        then
          chown nginx:nginx #{dir}/sites/default/files
      else
        chown apache:apache #{dir}/sites/default/files
      fi
    fi
  fi
    #temp fix before having glusterfs
    mkdir #{dir}/sites/default/files
    chmod 777 #{dir}/sites/default/files
    #Set file permission anyway, fix docker issue
    mkdir #{dir}/sites/default/private
    chmod 777 #{dir}/sites/default/private
    EOH
  end

  template "#{dir}/sites/default/settings.php" do
        source "#{localfolder}.settings.php"
        mode 0644
        retries 3
        retry_delay 30
        owner "root"
        group "root"
        action :create
        ignore_failure true
  end rescue NoMethodError

  docker_container 'sparkpadgp_' + localfolder do
    action :restart
  end
end
