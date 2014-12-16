script "download_composer" do
        interpreter "bash"
        user "root"
        code <<-EOH
        cd /root
        curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
        ln -s /usr/local/bin/composer /usr/bin/composer
        cp /home/ec2-user/.b* /var/lib/nginx
        chown nginx:nginx /var/lib/nginx/.b*
        EOH
end

script "install_drush_nginx" do
        interpreter "bash"
        user "nginx"
        code <<-EOH
        cd
        /usr/local/bin/composer global require drush/drush::dev-master
        sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
        source $HOME/.bashrc
        EOH
end

script "install_drush_ec2user" do
        interpreter "bash"
        user "ec2-user"
        code <<-EOH
        cd
        /usr/local/bin/composer global require drush/drush::dev-master
        sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
        source $HOME/.bashrc
        EOH
end

script "install_drush_root" do
        interpreter "bash"
        user "root"
        code <<-EOH
        cd
        /usr/local/bin/composer global require drush/drush::dev-master
        sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
        source $HOME/.bashrc
        EOH
end
