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
#execute "preparemountdir" do
#       command "mkdir -p #{node[:diskmount][:localsourcefolder]}"
#end

execute "wait_until_drupal" do
        command "n=0;until [ $n -ge 5 ];do ls -lrt #{node[:diskmount][:localsourcefolder]}; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;"
end

execute "mountvolume" do
	command "echo '#{node[:diskmount][:glusterserverip]}:/#{node[:diskmount][:glustervolume]} #{node[:diskmount][:localsourcefolder]} glusterfs defaults 0 0' >>/etc/fstab;"
	not_if "cat /proc/mounts | grep glusterfs"
end


