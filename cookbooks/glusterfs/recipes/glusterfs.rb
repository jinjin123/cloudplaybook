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

ruby_block "check_gluster" do
  block do
  #tricky way to load this Chef::Mixin::ShellOut utilities
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    command = 'yum list installed | grep gluster| wc -l'
    command_out = shell_out(command)
    node.set['gluster'] = command_out.stdout
  end
  action :create
end

ruby_block 'checked_gluster_notexists' do
  block do
    if node['gluster'].to_i == 0
      system("rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-libs-3.11.3-1.el6.x86_64.rpm")
      system("rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-3.11.3-1.el6.x86_64.rpm")
      system("rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-client-xlators-3.11.3-1.el6.x86_64.rpm")
      system("rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-fuse-3.11.3-1.el6.x86_64.rpm")
    end
  end
end

# execute "installglusterlibs" do
#   command "rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-libs-3.11.3-1.el6.x86_64.rpm"
# end
#
# execute "installgluster" do
#   command "rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-3.11.3-1.el6.x86_64.rpm"
# end
#
# execute 'installglusterfs-client-xlators' do
#   command 'rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-client-xlators-3.11.3-1.el6.x86_64.rpm'
# end
#
# execute "installglusterfuse" do
#   command "rpm -ivh https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.11/glusterfs-fuse-3.11.3-1.el6.x86_64.rpm"
# end
