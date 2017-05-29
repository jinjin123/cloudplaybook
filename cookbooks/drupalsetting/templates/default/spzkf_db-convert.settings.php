<?php
// Database connection to sharing hosts
$databases['default']['default'] = array (
  'database' => 'datacache',
  'username' => 'db-convert',
  'password' => 'Xx6VMChtxRHv',
  'host' => '172.16.103.203',
  'port' => '',
  'driver' => 'mysql',
  'prefix' => '',
);
$databases['de']['default'] = array (
  'database' => 'de',
  'username' => 'de',
  'password' => '1nBA2Qt9krXQwl35dyyB',
  'host' => '172.16.103.188',
  'port' => '',
  'driver' => 'mysql',
  'prefix' => '',
);
$databases['erp']['default'] = array (
  'database' => 'erp',
  'username' => 'erp',
  'password' => 's5BBRsQ9m8L6OPmU6q',
  'host' => '172.16.103.125',
  'port' => '',
  'driver' => 'mysql',
  'prefix' => '',
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

$conf['reverse_proxy'] = TRUE;
$conf['reverse_proxy_addresses'] = array(
  '172.16.102.108',
  '172.16.102.111',
  '172.16.102.109',
);
#### memcached config ###
if (extension_loaded('memcached')) {
  // /app/web/de => de. /app/web/erp => erp
  $document_array = explode('/', $_SERVER['DOCUMENT_ROOT']);
  $memcache_prefix = end($document_array);

  $conf['cache_backends'][] = 'sites/all/modules/memcache_storage/memcache_storage.inc';
  $conf['cache_default_class'] = 'MemcacheStorage';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  $conf['memcache_storage_key_prefix'] = $memcache_prefix;
  $conf['memcache_storage_debug'] = FALSE;
  $conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
  $conf['memcache_servers'] = array(
    '172.16.102.107:11211' => 'default',
    #'172.16.102.112:11222' => 'default',
    #'172.16.102.113:11222' => 'default',
  );
  $conf['memcache_extension'] = 'Memcached';
  $conf['memcache_options'] = array(
    Memcached::OPT_TCP_NODELAY => TRUE,
    Memcached::OPT_NO_BLOCK => TRUE,
    Memcached::OPT_BINARY_PROTOCOL => TRUE,
  );
  #$conf['lock_inc'] = 'sites/all/modules/memcache_storage/includes/lock.inc';
}
if (extension_loaded('redisx')) {
  $conf['redis_client_interface'] = 'Predis'; // Can be "Predis".
  $conf['redis_client_host'] = '172.16.102.107';  // Your Redis instance hostname.
  #$conf['lock_inc'] = 'sites/all/modules//redis/redis.lock.inc';
  #$conf['path_inc'] = 'sites/all/modules/redis/redis.path.inc';
  $conf['cache_backends'][] = 'sites/all/modules/redis/redis.autoload.inc';
  $conf['cache_default_class'] = 'Redis_Cache';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
}
$conf['commerce_entitycache_cache_products'] = TRUE;
ini_set('display_errors', TRUE);
