#
# Cookbook Name:: drupal_settings
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
require 'chef/data_bag'

if File.exist?("/etc/chef/run_update.sh")
  chef_gem "chef-vault"
  require "chef-vault"
  vault = ChefVault::Item.load("secrets", "secret_key")
 # vault['secret_key'] = vault['secret_key'].tr(" ", "\n")
  # To write changes to the file, use:
  out_file = File.open("/etc/chef/secret_key", "w")
  out_file.puts vault['secret_key']
end

if File.exist?("/etc/chef/secret_key")


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

if File.exist?(node['drupal_settings']['secretpath'])
drupal_secret = Chef::EncryptedDataBagItem.load_secret(node['drupal_settings']['secretpath'])
end

# Check if databag exists before applying templates
if Chef::DataBag.list.key?('drupal')

  template "/var/www/html/sites/default/basic.settings.php" do
    source "basic.settings.php"
    mode 0600
    retries 3
    retry_delay 30
    owner "nginx"
    group "nginx"
    action :create
    ignore_failure true
  end rescue NoMethodError

  begin
  # Check if DataBag item exist before applying templates
    Database_Setting = Chef::EncryptedDataBagItem.load("drupal", "Database", drupal_secret)
    template "/var/www/html/sites/default/settings.php" do
      source "settings.php"
      variables(
        :db_name => Database_Setting['db_name'], 
        :db_user => Database_Setting['db_user'],
        :db_passwd => Database_Setting['db_passwd'],
        :mysql_url => Database_Setting['mysql_url'],
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
  rescue Exception => e  
  end

  begin
    AWS_Setting = Chef::EncryptedDataBagItem.load("drupal", "AWS", drupal_secret)
    template "/var/www/html/sites/default/aws.settings.php" do
      source "aws.settings.php"
      variables(
        :aws_key => AWS_Setting['aws_key'], 
        :aws_secret => AWS_Setting['aws_secret'],
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
    rescue Exception => e  
  end
  
  begin
    Memcache_Setting = Chef::EncryptedDataBagItem.load("drupal", "Memcache", drupal_secret)
    template "/var/www/html/sites/default/memcache.settings.php" do
      source "memcache.settings.php"
      variables(
        :Memcache_server1 => Memcache_Setting['Memcache_server1'],
        :Memcache_port1 => Memcache_Setting['Memcache_port1'],
        :Memcache_server2 => Memcache_Setting['Memcache_server2'],
        :Memcache_port2 => Memcache_Setting['Memcache_port2']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
  rescue Exception => e  
  end

  begin    
    CDN_Setting = Chef::EncryptedDataBagItem.load("drupal", "CDN", drupal_secret)
    template "/var/www/html/sites/default/cdn.settings.php" do
      source "cdn.settings.php"
      variables(
        :LoadBalancerDNS => CDN_Setting['LoadBalancerDNS']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
  rescue Exception => e  
  end
  
  begin
    S3CDN_Setting = Chef::EncryptedDataBagItem.load("drupal", "S3CDN", drupal_secret)
    template "/var/www/html/sites/default/s3cdn.setttings.php" do
      source "s3cdn.setttings.php"
      variables(
        :S3CDN => S3CDN_Setting['S3CDN']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
  rescue Exception => e
  end

  # Calling three templates by one data_bag
  begin
    Host_n_storage_Setting = Chef::EncryptedDataBagItem.load("drupal", "Host_n_storage", drupal_secret)
    template "/var/www/html/sites/default/cookie.settings.php" do
      source "cookie.settings.php"
      variables(
        :LoadBalancerDNS => Host_n_storage_Setting['LoadBalancerDNS']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError

    template "/var/www/html/sites/default/s3.settings.php" do
      source "s3.settings.php"
      variables(
        :S3bucket => Host_n_storage_Setting['S3bucket']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
    
    template "/var/www/html/sites/default/xmlsitemap.settings.php " do
      source "xmlsitemap.settings.php"
      variables(
        :LoadBalancerDNS => Host_n_storage_Setting['LoadBalancerDNS'],
        :S3bucket => Host_n_storage_Setting['S3bucket']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner "nginx"
      group "nginx"
      action :create
      ignore_failure true
    end rescue NoMethodError
   rescue Exception => e    
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


end