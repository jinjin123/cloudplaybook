<?php
// Database connection to sharing hosts
$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'payment',
      'username' => 'payment',
      'password' => 'HXuj3pZP8EM4kbY7t6mY',
      'host' => '172.16.103.188',
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

#$conf['memcache_servers'] = array('127.0.0.1:11211' => 'default');
$conf['memcache_servers'] = array(
  '172.16.102.107:11211' => 'default',
  #'172.16.102.112:11222' => 'default',
  #'172.16.102.113:11222' => 'default',
);
$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache/memcache.inc';
$conf['lock_inc'] = 'sites/all/modules/contrib/memcache/memcache-lock.inc';
//$conf['memcache_stampede_protection'] = TRUE;
$conf['cache_default_class'] = 'MemCacheDrupal';
$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
$conf['memcache_key_prefix'] = 'pmt';

ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);