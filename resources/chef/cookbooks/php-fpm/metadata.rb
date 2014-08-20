name "php-fpm"
maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Installs/Configures php-fpm"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.6.9"

depends "apt"
depends "yum"
recipe            "php-fpm::module_mysql", "Install the php5-mysql package"
recipe            "php-fpm::module_gd", "Install the php5-gd package"
recipe            "php-fpm::module_pdo", "Install the php5-pdo package"
recipe            "php-fpm::module_mbstring", "Install the php5-mbstring package"


%w{ debian ubuntu centos redhat fedora amazon }.each do |os|
  supports os
end
