#
# Cookbook Name:: drupal_settings
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
require 'chef/data_bag'

bash "mount_if_gluster" do
  user "root"
  cwd "/tmp"
  code <<-EOH
if [ `cat /etc/fstab|grep glusterfs| wc -l` -gt 0 ]
then
  mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
  if [ -d "/var/www/html/sites/default" ]; then
    ln -s `cat /etc/fstab|grep glusterfs| awk '{print $2}'` /var/www/html/sites/default/files
    if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
    then
      chown nginx:nginx `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    else
      chown apache:apache `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
    fi
  fi
else
  if [ -d "/var/www/html/sites/default" ]; then
  mkdir /var/www/html/sites/default/files
  chmod 777 /var/www/html/sites/default/files
    if [ `cat /etc/passwd|grep nginx| wc -l` -eq 1 ]
    then
    chown nginx:nginx /var/www/html/sites/default/files
    else
    chown apache:apache /var/www/html/sites/default/files
    fi
  fi
fi
EOH
end

#template "/var/www/html/sites/default/settings.php" do
#        source "settings.php"
#        mode 0600
#        retries 3
#        retry_delay 30
#        owner "nginx"
#        group "nginx"
#        action :create
#        ignore_failure true
#end rescue NoMethodError

drupal_secret = Chef::EncryptedDataBagItem.load_secret("#{node['drupal_settings']['secretpath']}")

if Chef::DataBag.list.key?('drupal')
  if Chef::DataBagItem.validate_id!('Memcache')
    Memcache_Setting = Chef::EncryptedDataBagItem.load("Memcache", "drupal", drupal_secret)
    template "/var/www/html/sites/default/memcache.settings.php" do
      source "memcache.settings.php"
      variables(
        :Memcache_server1 => Memcache_Setting['Memcache_server1'] 
        :Memcache_port1 => Memcache_Setting['Memcache_port1']
        :Memcache_server2 => Memcache_Setting['Memcache_server2']
        :Memcache_port2 => Memcache_Setting['Memcache_port2']
      )
    end 
  end
end

service "nginx" do
  action :restart
  ignore_failure true
end

service "php-fpm" do
  action :restart
  ignore_failure true
end
