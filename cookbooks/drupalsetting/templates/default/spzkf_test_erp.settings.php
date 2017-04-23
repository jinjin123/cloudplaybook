<?php

$databases['default']['default'] = array (
  'database' => 'erp',
  'username' => 'erp',
  'password' => 'erp',
  'host' => '172.16.104.122',
  'port' => '',
  'driver' => 'mysql',
  'prefix' => '',
);
$databases['slave']['default'] = array(
  'driver' => 'mysql',
  'database' => 'test1',
  'username' => 'test1',
  'password' => 'Abcd1234',
  'host' => 'rdsntd5fyuojodv4hj4xy.mysql.rds.aliyuncs.com',
  'prefix' => '',
);
$databases['oc']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'test',
  'password' => 'test',
  'host' => '172.16.103.203',
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

if (extension_loaded('memcached')) {
  $conf['cache_backends'][] = 'sites/all/modules/memcache_storage/memcache_storage.inc';
  $conf['cache_default_class'] = 'MemcacheStorage';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  $conf['memcache_storage_key_prefix'] = 'erp';
  $conf['memcache_storage_debug'] = FALSE;
  $conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
  #$conf['memcache_servers'] = array('127.0.0.1:11211' => 'default');
  $conf['memcache_servers'] = array(
    #'127.0.0.1:11211' => 'default',
    'zkf_memcached:11211' => 'default',
  );
  $conf['memcache_extension'] = 'Memcached';
  $conf['memcache_options'] = array(
    Memcached::OPT_TCP_NODELAY => TRUE,
    Memcached::OPT_NO_BLOCK => TRUE,
    Memcached::OPT_BINARY_PROTOCOL => TRUE,
  );
  $conf['lock_inc'] = 'sites/all/modules/memcache_storage/includes/lock.inc';
#$conf['session_inc'] = 'sites/all/modules/memcache_storage/includes/session.inc';
}

$conf['nc_erp_api_url'] = 'http://172.16.104.104:9080/service/XChangeServlet';
$conf['oci8'] = array(
  'databases' => array(
    'nchr' => array(
      'default' => array(
        'database' => 'ERP',
        'username' => 'BOH2NC',
        'password' => '123456',
        'hosts' => array('172.16.104.52'),
        'port' => '1521',
        'character_set' => 'AL32UTF8',
      ),
    ),
    'nc-monthly' => array(
      'default' => array(
        'database' => 'ERP',
        'username' => 'BOH2NC',
        'password' => '123456',
        'hosts' => array('172.16.104.52'),
        'port' => '1521',
        'character_set' => 'AL32UTF8',
      ),
    ),
    'boh' => array(
      'default' => array(
        'database' => 'BOH',
        'username' => 'TZXSCM',
        'password' => '1234567890',
        'hosts' => array('172.16.104.50'),
        'port' => '1521',
        'character_set' => 'AL32UTF8',
      ),
    ),
  ),
);

$conf['zkf_api'] = array(
  'oc' => array(
    'api_url' => 'http://172.16.104.124:8080/oc/',
    #'api_url' => 'http://172.16.102.116:8080/',
    'api_key' => 'CCSERVER',
    'api_secret' => 'CCSERVER3345',
    'fixed_access_token' => '481A0y0722G721S5p21853gNNnc583N9DUZ4f90995lQbl6pGw229zA1652P2h56',
    'enable_log' => 1,
  ),
  'de' => array(
    'api_url' => 'http://zkf_de/',
    'api_key' => 'bPOf3a52dcWw6vkE7QtgVoRUz',
    'enable_log' => 0,
  ),
  'crm' => array(
    'api_url' => 'http://zkf_crm/',
    'api_key' => 'W/bkcCjGNmzjS/l6DTwxDA==',
    'enable_log' => 1,
  ),
  'marketing' => array(
    'api_url' => 'http://zkf_mkt/',
    'api_key' => 'zkf_ts',
    'api_secret' => 'zkf_ts_secret',
    'discount_id' => 59,
    'enable_log' => 1,
  ),
  'payment' => array(
    'api_url' => 'http://zkf_pmt/',
    'api_key' => '8a970a5f2835ad6ba323db0e73aee6f1',
    'api_security' => '369c9360b966d3a4e4154fbc96efe0f0',
    'enable_log' => 1,
  ),
  'baidu_map' => array(
    'api_url' => 'http://api.map.baidu.com/',
    'api_key' => '8c1b6507d5db2db7aca15cd249fdd385',
    'enable_log' => 1,
  ),
);
