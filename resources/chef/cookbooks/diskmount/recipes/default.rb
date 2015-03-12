#
# Cookbook Name:: diskmount
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
#
#execute "wait_until_drupal" do
#        command "n=0;until [ $n -ge 5 ];do ls -lrt /var/www/html/sites/default; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;"
#end

execute "preparemountdir" do
       command "mkdir -p #{node[:diskmount][:localsourcefolder]}"
end

#execute "create_mount_pt" do
#	command "echo '#{node[:diskmount][:glusterserverip]}:/#{node[:diskmount][:glustervolume]} #{node[:diskmount][:localsourcefolder]} glusterfs defaults 0 0' >>/etc/fstab;"
#	not_if "cat /proc/mounts | grep glusterfs"
#end
if node[:diskmount][:glusterserverip].to_s.present?
  mount node[:diskmount][:localsourcefolder] do
    device "#{node[:diskmount][:glusterserverip]}:/#{node[:diskmount][:glustervolume]}"
    dump 0
    pass 0
    fstype "glusterfs"
    options "defaults"
    action :enable
  end
end
