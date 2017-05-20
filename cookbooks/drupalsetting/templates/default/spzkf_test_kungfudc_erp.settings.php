<?php
$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'erp',
      'username' => "<%= @username %>",
      'password' => "<%= @password %>",
      'host' => "<%= @host %>",
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
$databases['slave']['default'] = array(
  'driver' => 'mysql',
  'database' => 'test1',
  'username' => 'test1',
  'password' => 'Abcd1234',
  'host' => 'rdsntd5fyuojodv4hj4xy.mysql.rds.aliyuncs.com',
  'prefix' => '',
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
/**/
#$conf['cache_backends'][] = 'sites/all/modules/memcache_storage/memcache_storage.inc';
#$conf['cache_default_class'] = 'MemcacheStorage';
#$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
#$conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
#$conf['memcache_storage_key_prefix'] = 'erp';
#$conf['memcache_storage_debug'] = FALSE;
#$conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
#$conf['memcache_servers'] = array('127.0.0.1:11211' => 'default');
#$conf['memcache_extension'] = 'Memcache';
/*$conf['memcache_options'] = array(
  Memcached::OPT_TCP_NODELAY => TRUE,
  Memcached::OPT_NO_BLOCK => TRUE,
  Memcached::OPT_BINARY_PROTOCOL => TRUE,
);*/
#$conf['lock_inc'] = 'sites/all/modules/memcache_storage/includes/lock.inc';
#$conf['session_inc'] = 'sites/all/modules/memcache_storage/includes/session.inc';
/**/
