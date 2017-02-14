#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#

basedir = node[:deploycode][:basedirectory]
  # Customization for MQ Cnf
  # Create cfg directory inside mq localfolder
  #Todo in sitesinfo.json, make a configuration specification
  directory basedir + 'mq/zkfmq/src/' do
    recursive true
    owner 'ec2-user'
    group 'ec2-user'
    mode '0755'
    action :create
  end

  #recursive true is not working
  directory basedir + 'reportingsys/storage' do
    recursive true
    owner 'ec2-user'
    group 'ec2-user'
    mode '0777'
    action :create
  end

  execute "change permissionsi of laravel" do
    command "chmod -R 777 #{basedir}/reportingsys/storage/"
    user "root"
    action :run
  end

  execute "change localtime" do
    command "ln -sf /usr/share/zoneinfo/Hongkong /etc/localtime"
    user "root"
    action :run
  end

  directory basedir + 'reportingsys/bootstrap/cache' do
    recursive true
    owner 'ec2-user'
    group 'ec2-user'
    mode '0777'
    action :create
  end

  template "#{basedir}/mq/zkfmq/src/zkf.cfg" do
        source "mq.zkf.cfg"
        mode 0644
        retries 3
        retry_delay 30
        owner "ec2-user"
        group "ec2-user"
        action :create
        ignore_failure true
  end

  template "#{basedir}/reportingsys/.env" do
        source "reportingsys.env"
        mode 0755
        retries 3
        retry_delay 30
        owner "ec2-user"
        group "ec2-user"
        action :create
        ignore_failure true
  end

  template "#{basedir}/reportingsys/config/externa_connection_db.php" do
        source "reportingsys.externa_connection_db.php"
        mode 0755
        retries 3
        retry_delay 30
        owner "ec2-user"
        group "ec2-user"
        action :create
        ignore_failure true
  end

node[:deploycode][:localfolder].each do |localfolder,giturl|
  dir = basedir + localfolder
  # Break if it is not Drupal
  if giturl.include?("drupal")
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
    ignore_failure true
  end
  end
end
