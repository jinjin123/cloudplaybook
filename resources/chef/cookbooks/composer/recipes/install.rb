script "install" do
        interpreter "bash"
        user "root"
        code <<-EOH
        cd /root
        curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
        ln -s /usr/local/bin/composer /usr/bin/composer
        mkdir -p /usr/local/src/drush
        git clone --depth 1 https://github.com/drush-ops/drush.git /usr/local/src/drush
        cd /usr/local/src/drush
        git checkout 7.0.0-alpha5  #or whatever version you want.
        ln -s /usr/local/src/drush/drush /usr/bin/drush
        composer install
#        /usr/local/bin/composer global require drush/drush::dev-master
#        sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
#        source $HOME/.bashrc
        EOH
end

script "ch_config" do
        interpreter "bash"
        user "root"
        code <<-EOH
        echo "cgi.fix_pathinfo=0" >> /etc/php.ini
        EOH
end
