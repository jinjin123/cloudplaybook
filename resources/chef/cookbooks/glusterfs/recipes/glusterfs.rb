#install gluseterfs client

execute "addglusterrepo" do
        command "wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/glusterfs-epel.repo"
        not_if { ::File.exists?("/etc/yum.repos.d/glusterfs-epel.repo") }
        notifies :run , 'execute[fixrepo]', :immediately
        notifies :run , 'execute[installglusterfsclient]', :immediately

end

execute "fixrepo" do
        command "sed -i 's/$releasever/6/g' /etc/yum.repos.d/glusterfs-epel.repo"
        action :nothing
end

execute "installglusterfsclient" do
        command "yum install -y glusterfs-fuse"
        action :nothing
end
