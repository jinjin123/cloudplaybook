template "/root/.ssh/config" do
	source "config.erb"
	mode 0600
	owner "root"
	group "root"
end

template "/root/.ssh/gitkey" do
	source "gitkey.erb"
	mode 0600
	owner "root"
	group "root"
end

template "/root/.ssh/gitkey.pub" do
	source "gitkey.pub.erb"
	mode 0600
	owner "root"
	group "root"
end


execute "preparesourcefolder" do
	command "mkdir -p #{node[:deploycode][:localsourcefolder]}"
end

execute "clonecode" do
	command "git clone  #{node[:deploycode][:giturl]} #{node[:deploycode][:localsourcefolder]}"
	not_if { ::File.directory?("#{node[:deploycode][:localsourcefolder]}/.git") }
end

execute "updatecode" do
	command "git pull"
	cwd "#{node[:deploycode][:localsourcefolder]}"
end
