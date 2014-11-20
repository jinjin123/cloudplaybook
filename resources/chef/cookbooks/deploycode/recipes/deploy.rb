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
        if [[ #{node[:deploycode][:gitrepo]} == rollback* ]] ;
        then
                tag=`echo #{node[:deploycode][:gitrepo]} | cut -d':' -f 2`
                git fetch && git checkout $tag
                exit 0
        fi
        if [ $CHECK -gt 0 ];then
        git pull;
        git tag -a v_`date +"%Y%m%d%H%M%S"` -m 'Code Deploy'
        git push --tag
        else
        for x in `ls -a`
        do
                if [ $x != "." ] && [ $x != ".." ];
                then
                rm -rf $x
                fi
        done
        n=0;until [ $n -ge 5 ];do git clone --depth 1 #{node[:deploycode][:gitrepo]} #{node[:deploycode][:localsourcefolder]}; [ $? -eq 0 ] && break;n=$[$n+1];sleep 15;done;
        fi
        EOH
end

script "changeowner" do
        interpreter "bash"
        user "root"
        code <<-EOH
        export CHECK=`cat /etc/passwd | grep webapp | wc -l`
        if [ $CHECK -gt 0 ];then
        chown -R webapp:apache #{node[:deploycode][:localsourcefolder]};
        else 
        chown -R nginx:nginx #{node[:deploycode][:localsourcefolder]};
        fi
        service php-fpm restart|| true
        service nginx restart|| true
        EOH
end
