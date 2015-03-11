#
# Cookbook Name:: drucloud_config
# Recipe:: default
#
# Copyright 2015, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
module_list = [ 'apachesolr', 'advagg_css_cdn', 'advagg_js_cdn', 'memcache', 'cdn', 'apachesolr_search' ]

unless node['drucloud_config']['drucloud_package'] =~ /recommend/
  module_list.each do |modules|
    execute "disable_modules_#{modules}" do
      command "source #{node['drucloud_config']['drupal_user_home']}/.bashrc;#{node['drucloud_config']['drush_path']}/drush dis #{modules} -y"
      cwd "#{node['drucloud_config']['drupal_root']}/sites/default"
      user node['drucloud_config']['drupal_user']
      group node['drucloud_config']['drupal_group']
      environment ({'HOME' => node['drucloud_config']['drupal_user_home']})
      ignore_failure true
    end
  end
  
  execute "drush_clear_cache" do
    cwd "source #{node['drucloud_config']['drupal_user_home']}/.bashrc;#{node['drucloud_config']['drupal_root']}/sites/default"
    user node['drucloud_config']['drupal_user']
    group node['drucloud_config']['drupal_group']
    environment ({'HOME' => node['drucloud_config']['drupal_user_home']})
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
