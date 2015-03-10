#
# Cookbook Name:: drucloud_config
# Recipe:: default
#
# Copyright 2015, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
module_list = [ 'apachesolr', 'advagg_css_cdn', 'advagg_js_cdn', 'memcache' ]

unless node['drucloud_config']['drucloud_package'] =~ /recommend/
  module_list.each do |modules|
    bash "disable_modules" do
      cwd "#{node['drucloud_config']['drupal_root']}/sites/default"
      user node['drucloud_config']['drupal_user']
      group node['drucloud_config']['drupal_group']
      environment ({'HOME' => '/var/lib/nginx'})
      command "#{node['drucloud_config']['drush_path']}/drush dis #{modules} -y"
    end
  end
  
  bash "drush_clear_cache" do
    cwd "#{node['drucloud_config']['drupal_root']}/sites/default"
    user node['drucloud_config']['drupal_user']
    group node['drucloud_config']['drupal_group']
    environment ({'HOME' => '/var/lib/nginx'})
    command "#{node['drucloud_config']['drush_path']}/drush cc all"
  end
  

# Disable APC when package
  if node['drucloud_config']['drucloud_package'] =~ /free/
    
    if(File.file?('/etc/php.d/apc.ini'))
      exec("/bin/sed -i 's/apc.enabled.*/apc.enabled = 0/' /etc/php.d/apc.ini")
    end

    service "php-fpm" do
      action :restart
      ignore_failure true
    end
  end
end