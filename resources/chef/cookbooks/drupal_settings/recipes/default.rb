#
# Cookbook Name:: drupal_settings
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
#execute 'call_chefserver' do
#  command "bash /etc/chef/run_update.sh"
#  retries 3
#  retry_delay 30
#  action :run
#end

#include_recipe 'drupal_settings::write_secret'

require 'chef/data_bag'

if File.exist?(node['drupal_settings']['secretpath'])
  bash "mount_if_gluster" do
    user "root"
    cwd "/tmp"
    code <<-EOH
      if [ `cat /etc/fstab|grep glusterfs| wc -l` -gt 0 ]; then
        if [ -d "#{node['drupal_settings']['web_root']}/sites/default/files" ];then
          rm -rf #{node['drupal_settings']['web_root']}/sites/default/files
        fi
      fi
      if [ ! -d "#{node['drupal_settings']['web_root']}/sites/default/files" ] && [ ! -h "#{node['drupal_settings']['web_root']}/sites/default/files" ]; then
        if [ `cat /etc/fstab|grep glusterfs| wc -l` -gt 0 ]; then
          mount `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
          if [ -d "#{node['drupal_settings']['web_root']}/sites/default" ]; then
            ln -s `cat /etc/fstab|grep glusterfs| awk '{print $2}'` #{node['drupal_settings']['web_root']}/sites/default/files
            chmod -R 777 `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
            chown -R #{node['drupal_settings']['web_user']}:#{node['drupal_settings']['web_group']} `cat /etc/fstab|grep glusterfs| awk '{print $2}'`
          fi
        else
          mkdir -p #{node['drupal_settings']['web_root']}/sites/default/files
          chmod -R 777 #{node['drupal_settings']['web_root']}/sites/default/files
          chown -R #{node['drupal_settings']['web_user']}:#{node['drupal_settings']['web_group']} #{node['drupal_settings']['web_root']}/sites/default/files
        fi
      fi
    EOH
    ignore_failure true
  end


  drupal_secret = IO.read(node['drupal_settings']['secretpath']).strip
  #Chef::EncryptedDataBagItem.load_secret(node['drupal_settings']['secretpath'])

  # Check if databag exists before applying templates
  if Chef::DataBag.list.key?('drupal')

    template "#{node['drupal_settings']['web_root']}/sites/default/basic.settings.php" do
      source "basic.settings.php"
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user'] 
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError
    
    template "#{node['drupal_settings']['web_root']}/sites/default/advagg.settings.php" do
      source "advagg.settings.php"
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError
    
    template "#{node['drupal_settings']['web_root']}/sites/default/search.settings.php" do
      source "search.settings.php"
      variables(
        :search_default_module => node['drupal_settings']['search_default_module'],
        :search_node => node['drupal_settings']['search_node']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
     end rescue NoMethodError


    # Check if DataBag item exist before applying templates
    Database_Setting = Chef::EncryptedDataBagItem.load("drupal", "Database", drupal_secret)
    template "#{node['drupal_settings']['web_root']}/sites/default/settings.php" do
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
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end

    AWS_Setting = Chef::EncryptedDataBagItem.load("drupal", "AWS", drupal_secret)
    template "#{node['drupal_settings']['web_root']}/sites/default/aws.settings.php" do
      source "aws.settings.php"
      variables(
        :aws_key => AWS_Setting['aws_key'], 
        :aws_secret => AWS_Setting['aws_secret'],
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end
  
    begin
      Memcache_Setting = Chef::EncryptedDataBagItem.load("drupal", "Memcache", drupal_secret)
    rescue Exception => e  
    end
    template "#{node['drupal_settings']['web_root']}/sites/default/memcache.settings.php" do
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
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError


    begin
      CDN_Setting = Chef::EncryptedDataBagItem.load("drupal", "CDN", drupal_secret)
    rescue Exception => e  
    end
    template "#{node['drupal_settings']['web_root']}/sites/default/cdn.settings.php" do
      source "cdn.settings.php"
      variables(
        :CDN => CDN_Setting['CDN'],
        :LoadBalancerDNS => CDN_Setting['LoadBalancerDNS']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError

  
    begin
      S3CDN_Setting = Chef::EncryptedDataBagItem.load("drupal", "S3CDN", drupal_secret)
    rescue Exception => e
    end
    template "#{node['drupal_settings']['web_root']}/sites/default/s3cdn.settings.php" do
      source "s3cdn.settings.php"
      variables(
        :S3CDN => S3CDN_Setting['S3CDN']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError


    # Calling three templates by one data_bag
    begin
      Host_n_storage_Setting = Chef::EncryptedDataBagItem.load("drupal", "Host_n_storage", drupal_secret)
    rescue Exception => e    
    end
    template "#{node['drupal_settings']['web_root']}/sites/default/cookie.settings.php" do
      source "cookie.settings.php"
      variables(
        :LoadBalancerDNS => Host_n_storage_Setting['LoadBalancerDNS']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError

    template "#{node['drupal_settings']['web_root']}/sites/default/s3.settings.php" do
      source "s3.settings.php"
      variables(
        :S3bucket => Host_n_storage_Setting['S3bucket']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError
    
    template "#{node['drupal_settings']['web_root']}/sites/default/xmlsitemap.settings.php" do
      source "xmlsitemap.settings.php"
      variables(
        :LoadBalancerDNS => Host_n_storage_Setting['LoadBalancerDNS'],
        :S3bucket => Host_n_storage_Setting['S3bucket']
      )
      mode 0600
      retries 3
      retry_delay 30
      owner node['drupal_settings']['web_user']
      group node['drupal_settings']['web_group']
      action :create
      ignore_failure true
    end rescue NoMethodError
  end
end

# if git repository is drupal, then run drupal_settings
ruby_block "CheckDrupal" do
  block do
    Existance = 0
    if File.file?("#{node['drupal_settings']['web_root']}/.git/config")
      CheckDrucloud = `cat #{node['drupal_settings']['web_root']}/.git/config|grep drucloud|wc -l`
      Existance = CheckDrucloud.to_i
    end
    if Existance > 0
      if File.file?('/usr/bin/chef-server-ctl')
        if !File.file?("#{node['drupal_settings']['web_root']}/ping.html")
          command = ""
          command = command + "if [ -f /etc/chef/validation.pem ] && [ -f /usr/bin/chef-server-ctl ];then chef-server-ctl stop;fi;"
          command = command + "su -c \"source #{node['drupal_settings']['web_user_home']}/.bashrc;"
          command = command + "cd #{node['drupal_settings']['web_root']}/sites/default;"
          command = command + "n=0;until [ \${n} -ge 3 ];do #{node['drupal_settings']['web_user_home']}/.composer/vendor/bin/drush site-install drucloud --account-name=admin --account-pass=admin --site-name=drucloudaws --yes;[ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;"
          command = command + "#{node['drupal_settings']['web_user_home']}/.composer/vendor/bin/drush php-eval 'node_access_rebuild();'\" -m \"#{node['drupal_settings']['web_user']}\";"
          command = command + "if [ -f /var/swap.1 ];then swapoff /var/swap.1;rm -f /var/swap.1;fi;"
          command = command + "echo \"<html></html>\" > #{node['drupal_settings']['web_root']}/ping.html;/bin/chown #{node['drupal_settings']['web_user']}:#{node['drupal_settings']['web_group']} #{node['drupal_settings']['web_root']}/ping.html;"
#          command = command + "if [ -f /etc/chef/validation.pem ] && [ -f /usr/bin/chef-server-ctl ];then chef-server-ctl stop;fi" 
          print command
          exec(command)
        end
      end
    end
  end
end


file "#{node['drupal_settings']['web_root']}/ping.html" do
  content '<html></html>'
  mode 0600
  owner node['drupal_settings']['web_user']
  group node['drupal_settings']['web_group']
  action :create
end

service "nginx" do
  action :restart
  ignore_failure true
end

service "php-fpm" do
  action :restart
  ignore_failure true
end