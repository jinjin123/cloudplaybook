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
	code <<-EOH
	cd #{node[:deploycode][:localsourcefolder]}
	export CHECK=`cat #{node[:deploycode][:localsourcefolder]}/.git/config|grep #{node[:deploycode][:gitrepo]} | wc -l`
	if [ $CHECK -gt 0 ];then
	git pull;
	else
	for x in `ls -a`
	do
		if [ $x != "." ] && [ $x != ".." ];
		then
		rm -rf $x
		fi
	done
	git clone --depth 1 #{node[:deploycode][:gitrepo]} . 
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

