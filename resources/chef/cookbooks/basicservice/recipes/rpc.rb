#install rpc service ,mainly for rpcbind
package "nfs-utils" do
	action :install
end

execute "startrpcbind" do
	command "/etc/initd./rpcbind start;chkconfig rpcbind on"
end




