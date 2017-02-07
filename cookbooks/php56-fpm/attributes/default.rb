# chef cookbook attributes
default['php56-fpm']['compiletime'] = false

if node.platform_family == "rhel"
  user = "ec2-user"
  group = "ec2-user"
  conf_dir = "/etc/php.d"
  pool_conf_dir = "/etc/php-fpm.d"
  conf_file = "/etc/php-fpm.conf"
  error_log = "/var/log/php-fpm/error.log"
  pid = "/var/run/php-fpm/php-fpm.pid"
else
  user = "www-data"
  group = "www-data"
  conf_dir = "/etc/php5/fpm/conf.d"
  pool_conf_dir = "/etc/php5/fpm/pool.d"
  if node.platform == "ubuntu" and node.platform_version.to_f <= 10.04
    conf_file = "/etc/php5/fpm/php5-fpm.conf"
  else
    conf_file = "/etc/php5/fpm/php-fpm.conf"
  end
  error_log = "/var/log/php5-fpm.log"
  pid ="/var/run/php5-fpm.pid"
end

default['php56-fpm']['user'] = user
default['php56-fpm']['group'] = group
default['php56-fpm']['conf_dir'] = conf_dir
default['php56-fpm']['pool_conf_dir'] = pool_conf_dir
default['php56-fpm']['conf_file'] = conf_file
default['php56-fpm']['pid'] = pid
default['php56-fpm']['error_log'] =  error_log
default['php56-fpm']['log_level'] = "notice"
default['php56-fpm']['emergency_restart_threshold'] = 0
default['php56-fpm']['emergency_restart_interval'] = 0
default['php56-fpm']['process_control_timeout'] = 0
default['php56-fpm']['pools'] = [
  {
    :name => "www"
  }
]
