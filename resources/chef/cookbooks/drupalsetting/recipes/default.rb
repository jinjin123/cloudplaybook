#
# Cookbook Name:: drupalsetting
# Recipe:: default
#
# Copyright 2014, BootDev
# www.BootDev.com
# All rights reserved - Do Not Redistribute
#
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

template "/home/ec2-user/tools/drupal_dir/de/sites/default/settings.php" do
        source "settings.php"
        mode 0644
        retries 3
        retry_delay 30
        owner "root"
        group "root"
        action :create
        ignore_failure true
end rescue NoMethodError

docker_container 'sparkpadgp_de' do
  action :restart
end

