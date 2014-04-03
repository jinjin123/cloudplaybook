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

script "deploycode" do
	interpreter "bash"
	user "root"
	cwd "#{node[:deploycode][:localsourcefolder]}"
	code <<-EOH
	export CHECK=`cat #{node[:deploycode][:localsourcefolder]}/.git/config|grep #{node[:deploycode][:gitrepo]} | wc -l`
	if [ $CHECK -gt 0 ];then
	git pull;
	else
	rm -rf #{node[:deploycode][:localsourcefolder]}/*
	git clone --depth 1 #{node[:deploycode][:gitrepo]} #{node[:deploycode][:localsourcefolder]}
	fi
	EOH
end

execute "lntoapache" do
	command "rm -rf /var/www/html;ln -sf #{node[:deploycode][:localsourcefolder]} /var/www/html"
end

execute "enablesite" do
	command "a2ensite default"
end
execute "restarthttp" do
	command "service httpd restart"
end

