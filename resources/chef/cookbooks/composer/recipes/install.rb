script "install" do
        interpreter "bash"
        user "root"
        code <<-EOH
        cd /root
        curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
        /usr/local/bin/composer global require drush/drush:6.*
        sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
        source $HOME/.bashrc
        EOH
end

script "ch_config" do
        interpreter "bash"
        user "root"
        code <<-EOH
        echo "cgi.fix_pathinfo=0" >> /etc/php.ini
        EOH
end
