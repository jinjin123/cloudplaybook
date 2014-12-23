#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
template "/var/www/html/sites/default/settings.php" do
        source "settings.php"
        mode 0600
        owner "nginx"
        group "nginx"
        action :create_if_missing
end

directory "/var/www/html/sites/default/files" do
        owner 'nginx'
        group 'nginx'
        mode '0777'
        action :create
end

bash "mount_if_gluster" do
  user "root"
  cwd "/tmp"
  code <<-EOH
if [ `cat /etc/fstab|grep glusterfs| wc -l` -eq 1 ]
then
mkdir -p `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    if [ `cat /etc/passwd|grep nginx| wc -l` -nq 0 ]
    then
    chown nginx:nginx `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    else
    chown apache:apache `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    fi
fi
EOH
end

if node['drupalsetting']['solr_url'] != "variable"
   execute "put_solr_setting" do
        user node['drupalsetting']['system_user']
        group node['drupalsetting']['system_user']
        environment ({'HOME' => "/home/ec2-user", 'USER' => "ec2-user"})
        command <<-EOH
        source /home/ec2-user/.bashrc
        cd /var/www/html/sites/default
        drush solr-set-env-url #{node['drupalsetting']['solr_url']}
        EOH
   end    
end
