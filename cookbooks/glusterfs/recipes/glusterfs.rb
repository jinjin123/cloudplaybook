#install gluseterfs client

# execute "addglusterrepo" do
#         command "wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/glusterfs-epel.repo"
#         not_if { ::File.exists?("/etc/yum.repos.d/glusterfs-epel.repo") }
#         notifies :run , 'execute[fixrepo]', :immediately
#         notifies :run , 'execute[installglusterfsclient]', :immediately
#
# end
#
# execute "fixrepo" do
#         command "sed -i 's/$releasever/6/g' /etc/yum.repos.d/glusterfs-epel.repo"
#         action :nothing
# end
#
# execute "installglusterfsclient" do
#         command "yum install -y glusterfs-fuse"
#         action :nothing
# end

execute "installglusterfuse" do
  command "rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-fuse-3.11.3-1.el6.x86_64.rpm"
end
