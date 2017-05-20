<?php
$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'de',
      'username' => "<%= @username %>",
      'password' => "<%= @password %>",
      'host' => "<%= @host %>",
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
  'erp' => array (
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

$update_free_access = FALSE;
$drupal_hash_salt = '';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
# $conf['theme_debug'] = TRUE;
$conf['memcache_servers'] = array('127.0.0.1:11211' => 'default');
#$conf['memcache_servers'] = array('172.16.102.111:11211' => 'default');
$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache/memcache.inc';
$conf['lock_inc'] = 'sites/all/modules/contrib/memcache/memcache-lock.inc';
#$conf['memcache_stampede_protection'] = TRUE;
$conf['cache_default_class'] = 'MemCacheDrupal';
$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
$conf['memcache_key_prefix'] = 'de';
