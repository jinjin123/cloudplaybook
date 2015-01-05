template "/root/.ssh/config" do
	source "config.erb"
	mode 0600
	owner "root"
	group "root"
        retries 3
        retry_delay 30
end

template "/root/.ssh/gitkey" do
	source "gitkey.erb"
	mode 0600
	owner "root"
	group "root"
        retries 3
        retry_delay 30
end

template "/root/.ssh/gitkey.pub" do
	source "gitkey.pub.erb"
	mode 0600
	owner "root"
	group "root"
        retries 3
        retry_delay 30
end


directory node[:deploycode][:localsourcefolder] do
        recursive true
        owner node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        mode '0755'
        action :create
end

#script "deploycode" do
#        interpreter "bash"
#        user "root"
#        environment ({'HOME' => '/root', 'USER' => 'root'})
#        code <<-EOH
#        retries 3
#        retry_delay 30
#        cd #{node[:deploycode][:localsourcefolder]}
#        CHECK=0 
#        if [ -d #{node[:deploycode][:localsourcefolder]}/.git ]; then
#            export CHECK=`cat #{node[:deploycode][:localsourcefolder]}/.git/config|grep #{node[:deploycode][:gitrepo]} | wc -l`
#        fi
#        if [[ #{node[:deploycode][:gitrepo]} == rollback* ]] ;
#        then
#                tag=`echo #{node[:deploycode][:gitrepo]} | cut -d':' -f 2`
#                git fetch && git checkout $tag
#                exit 0
#        fi
#        if [ $CHECK -gt 0 ];then
#        git pull > /var/log/git-pull.log;
#        git tag -a v_`date +"%Y%m%d%H%M%S"` -m 'Code Deploy'
#        git push --tag
#        else
#        for x in `ls -a`
#        do
#                if [ $x != "." ] && [ $x != ".." ];
#                then
#                rm -rf $x
#                fi
#        done
#        n=0;until [ $n -ge 5 ];do git clone --depth 1 #{node[:deploycode][:gitrepo]} #{node[:deploycode][:localsourcefolder]}> /var/log/git-clone.log; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;
#        fi
#        EOH
#end

execute "git_tag" do
        command 'git tag -a v_`date +"%Y%m%d%H%M%S"` -m "Code Deploy";git push --tag'
        cwd node[:deploycode][:localsourcefolder]
        user node[:deploycode][:code_owner]
        group node[:deploycode][:code_group]
        action :nothing
end

if ! Dir.exist? "#{node[:deploycode][:localsourcefolder]}/.git"
        include_recipe "deploycode::clone_repo"
else
        if File.readlines("#{node[:deploycode][:localsourcefolder]}/.git/config").grep("/#{node[:deploycode][:gitrepo]}/").size > 0
                git "pull_repo" do
                        user node[:deploycode][:code_owner]
                        group node[:deploycode][:code_group]
                        retries 3
                        retry_delay 30
                        repository node[:deploycode][:gitrepo]
                        reference "master"
                        action :sync
                        destination node[:deploycode][:localsourcefolder]
                        notifies :run, "execute[git_tag]", :delayed
                end        
        else 
                execute "clear_directory" do
                        command 'for x in `ls -a`;do if [ $x != "." ] && [ $x != ".." ];then rm -rf $x;fi; done'
                        cwd node[:deploycode][:localsourcefolder]
                        notifies :sync, "git[clone_repo]", :delayed
                end
        end
end

#script "changeowner" do
#        interpreter "bash"
#        user "root"
#        code <<-EOH
#        export CHECK=`cat /etc/passwd | grep webapp | wc -l`
#        if [ $CHECK -gt 0 ];then
#        chown -R webapp:apache #{node[:deploycode][:localsourcefolder]};
#        else 
#        chown -R nginx:nginx #{node[:deploycode][:localsourcefolder]};
#        service php-fpm restart|| true
#        service nginx restart|| true
#        fi
#        EOH
#end
