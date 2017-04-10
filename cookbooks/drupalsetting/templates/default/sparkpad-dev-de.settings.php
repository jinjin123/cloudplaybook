<?php
// Database connection to sharing hosts
$databases = array (
  'default' => array (
    'default' => array (
      'database' => "<%= @dbname %>",
      'username' => "<%= @username %>",
      'password' => "<%= @password %>",
      'host' => "<%= @host %>",
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  )
);

$update_free_access = FALSE;
$drupal_hash_salt = '';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
ini_set('max_execution_time', 120);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)|(?:system\/files)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
$conf['restws_basic_auth_user_regex'] = '/.*/';
$conf['user_failed_login_ip_limit'] = 1000;

/**
 * Redis Configuration.
 */
 // Redis settings
 $conf['redis_client_interface'] = 'PhpRedis';
 $conf['redis_client_host'] = 'sparkpadgp_redis';
 $conf['lock_inc'] = 'sites/all/modules/contrib/redis/redis.lock.inc';
 $conf['path_inc'] = 'sites/all/modules/contrib/redis/redis.path.inc';
 $conf['cache_backends'][] = 'sites/all/modules/contrib/redis/redis.autoload.inc';
 $conf['cache_default_class'] = 'Redis_Cache';
 // For multisite, you must use a unique prefix for each site
 $conf['cache_prefix'] = 'sparkpadgp_de';
