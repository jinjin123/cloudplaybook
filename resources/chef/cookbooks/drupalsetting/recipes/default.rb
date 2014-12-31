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
        action :create
        ignore_failure true
end rescue NoMethodError

#directory "/var/www/html/sites/default/files" do
#        owner 'nginx'
#        group 'nginx'
#        mode '0777'
#        action :create
#        ignore_failure true
#end

# Directory syntax of chef does not take ignore_failure
bash "create_files_directory" do
  user "nginx"
  cwd "/tmp"
  code <<-EOH
  if [ -d "/var/www/html/sites/default" ]; then
  mkdir /var/www/html/sites/default/files
  chmod 777 /var/www/html/sites/default/files
  fi
EOH
end

bash "mount_if_gluster" do
  user "root"
  cwd "/tmp"
  code <<-EOH
if [ `cat /etc/fstab|grep glusterfs| wc -l` -eq 1 ]
then
mkdir -p `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
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
        ignore_failure true
        command <<-EOH
        source /home/ec2-user/.bashrc
        if [ -d "/var/www/html/sites/default" ]; then
            cd /var/www/html/sites/default
            drush en apachesolr apachesolr_search -y
            drush solr-set-env-url #{node['drupalsetting']['solr_url']}
        fi
        EOH
   end    
end
