package "nfs-utils" do
	action :install
end

template "/etc/exports" do
	source "exports.erb"
	mode 0644
	owner "root"
	group "root"
end

execute "preparesharefolder" do
	command "mkdir -p #{node[:nfsserver][:sharepath]}"
end

execute "startnfsserver" do
	command "/etc/init.d/rpcbind start;chkconfig rpcbind on;/etc/init.d/rpcidmapd start; chkconfig rpcidmapd on;/etc/init.d/nfs start;chkconfig nfs on"
end

