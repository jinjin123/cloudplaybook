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
execute "preparemountdir" do
       command "mkdir -p #{node[:diskmount][:localsourcefolder]}"
end

#execute "create_mount_pt" do
#	command "echo '#{node[:diskmount][:glusterserverip]}:/#{node[:diskmount][:glustervolume]} #{node[:diskmount][:localsourcefolder]} glusterfs defaults 0 0' >>/etc/fstab;"
#	not_if "cat /proc/mounts | grep glusterfs"
#end

if ! node[:diskmount][:glusterserverip].empty?
  mount node[:diskmount][:localsourcefolder] do
    device "#{node[:diskmount][:glusterserverip]}:/#{node[:diskmount][:glustervolume]}"
    dump 0
    pass 0
    fstype "glusterfs"
    options "defaults"
    action [:mount, :enable]
  end
end
