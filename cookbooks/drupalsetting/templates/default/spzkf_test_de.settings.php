<?php

$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'de',
      'username' => 'de',
      'password' => 'de',
      'host' => '172.16.104.122',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
  'erp' => array (
    'default' => array (
      'database' => 'erp',
      'username' => 'erp',
      'password' => 'erp',
      'host' => '172.16.104.122',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
$update_free_access = FALSE;
$drupal_hash_salt = '';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)|(?:system\/files)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';

if (extension_loaded('memcachedx')) {
  $conf['cache_backends'][] = 'sites/all/modules/contrib/memcache_storage/memcache_storage.inc';
  $conf['cache_default_class'] = 'MemcacheStorage';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  $conf['memcache_storage_key_prefix'] = 'de';
  $conf['memcache_storage_debug'] = FALSE;
  $conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
  #$conf['memcache_servers'] = array('127.0.0.1:11211' => 'default');
  $conf['memcache_servers'] = array(
    'memcached:11211' => 'default',
    '127.0.0.1:11211' => 'default',
  );
  $conf['memcache_extension'] = 'Memcached';
  $conf['memcache_options'] = array(
    Memcached::OPT_TCP_NODELAY => TRUE,
    Memcached::OPT_NO_BLOCK => TRUE,
    Memcached::OPT_BINARY_PROTOCOL => TRUE,
  );
  $conf['lock_inc'] = 'sites/all/modules/contrib/memcache_storage/includes/lock.inc';
#$conf['session_inc'] = 'sites/all/modules/memcache_storage/includes/session.inc';
}
if (extension_loaded('redis')) {
  $conf['redis_client_interface'] = 'Predis'; // Can be "Predis".
  $conf['redis_client_host']      = 'redis';  // Your Redis instance hostname.
  $conf['lock_inc']               = 'sites/all/modules/contrib/redis/redis.lock.inc';
  #$conf['path_inc']               = 'sites/all/modules/redis/redis.path.inc';
  $conf['cache_backends'][]       = 'sites/all/modules/contrib/redis/redis.autoload.inc';
  $conf['cache_default_class']    = 'Redis_Cache';

}
