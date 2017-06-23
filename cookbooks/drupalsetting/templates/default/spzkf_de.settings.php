<?php
// Database connection to sharing hosts
$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'de',
      'username' => 'de',
      'password' => '1nBA2Qt9krXQwl35dyyB',
      'host' => '172.16.103.188',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
    'erp' => array (
      'database' => 'erp',
      'username' => 'erp',
      'password' => 's5BBRsQ9m8L6OPmU6q',
      'host' => '172.16.103.125',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
$databases['tmp']['default'] = array(
  'driver' => 'mysql',
  'database' => 'nc_order_tmp',
  'username' => 'root',
  'password' => 'Abcd@1234~',
  'host' => 'docs.sparkpos.cn',
  'prefix' => '',
);
$update_free_access = FALSE;
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
#ini_set('max_execution_time', 240);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)|(?:system\/files)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';

$conf['reverse_proxy'] = TRUE;
$conf['reverse_proxy_addresses'] = array(
  '172.16.102.108',
  '172.16.102.111',
  '172.16.102.109',
);
if (extension_loaded('memcached')) {
  $conf['cache_backends'][] = 'sites/all/modules/contrib/memcache_storage/memcache_storage.inc';
  #$conf['cache_default_class'] = 'MemcacheStorage';
  #$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  #$conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  $conf['memcache_storage_key_prefix'] = 'de';
  $conf['memcache_storage_debug'] = FALSE;
  $conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
  $conf['memcache_servers'] = array(
    '172.16.102.225:11212' => 'default',
    #'172.16.102.107:11212' => 'default',
    #'172.16.102.112:11222' => 'default',
    #'172.16.102.113:11222' => 'default',
  );
  $conf['memcache_extension'] = 'Memcached';
  $conf['memcache_options'] = array(
    Memcached::OPT_TCP_NODELAY => TRUE,
    Memcached::OPT_NO_BLOCK => TRUE,
    Memcached::OPT_BINARY_PROTOCOL => TRUE,
  );
  $conf['cache_class_cache_field'] = 'MemcacheStorage';
  $conf['cache_class_cache_entity_user']  = 'MemcacheStorage';
  $conf['cache_class_cache_entity_profile2']  = 'MemcacheStorage';
  $conf['cache_class_cache_entity_taxonomy_term'] = 'MemcacheStorage';
  $conf['cache_class_cache_entity_node'] = 'MemcacheStorage';
  $conf['cache_class_cache_entity_file'] = 'MemcacheStorage';
  $conf['cache_class_cache_entity_commerce_product'] = 'MemcacheStorage';
  #$conf['lock_inc'] = 'sites/all/modules/contrib/memcache_storage/includes/lock.inc';
}
if (extension_loaded('redis')) {
  //$document_array = explode('/', $_SERVER['DOCUMENT_ROOT']);
  $conf['cache_prefix'] = 'de';//end($document_array);

  $conf['redis_client_interface'] = 'Predis'; // Can be "Predis".
  $conf['redis_client_host'] = '172.16.102.226';  // Your Redis instance hostname.
  $conf['redis_client_port'] = 6377;
  $conf['lock_inc'] = 'sites/all/modules/contrib/redis/redis.lock.inc';
  #$conf['path_inc'] = 'sites/all/modules/contrib/redis/redis.path.inc';
  $conf['cache_backends'][] = 'sites/all/modules/contrib/redis/redis.autoload.inc';
  $conf['cache_default_class'] = 'Redis_Cache';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  #$conf['cache_class_cache_field'] = 'DrupalDatabaseCache';
}

$drupal_hash_salt = 'HEkZqDY6Egh#bPsKY7ziWwQ8*V6TTtzw';
$conf['drupal_private_key'] = '^*9@Qc&18iREpthJRA8^SdfDHvlK7rUc';

#$conf['commerce_entitycache_cache_products'] = TRUE;
$conf['composer_manager_vendor_dir'] = 'sites/all/vendor';
$conf['composer_manager_file_dir'] = 'sites/default/files/composer';
ini_set('display_errors', TRUE);
