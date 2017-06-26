<?php
$databases['default']['default'] = array (
  'database' => 'erp',
  'username' => 'erp',
  'password' => 's5BBRsQ9m8L6OPmU6q',
  #'host' => '172.16.103.189',
  'host' => '172.16.103.125',
  'port' => '',
  'driver' => 'mysql',
  'prefix' => '',
);
$databases['nc_tmp']['default'] = array(
  'driver' => 'mysql',
  'database' => 'nc_order_tmp',
  'username' => 'root',
  'password' => 'Abcd@1234~',
  'host' => 'docs.sparkpos.cn',
  'prefix' => '',
);
//堂食OC
$databases['oc']['default'] = array(
  'driver' => 'mysql',
  'database' => 'newposoc',
  'username' => 'npcreadonly',
  'password' => 'uH2zVJ0C7fEcI96wvpPk',
  'host' => '172.16.103.191',
  'prefix' => '',
);
//GFS OC
$databases['gfs']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'ocselect',
  'password' => 'AZTfjuCFoppEC6wR',
  'host' => '172.16.103.186',
  'prefix' => '',
);
//Report DB
$databases['report']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'readonly',
  'password' => 'AZTfjuCFoppEC6wR',
  'host' => '172.16.103.203',
  'prefix' => '',
);
//Report DB 207
$databases['report-207']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'readonly',
  'password' => 'readonly',
  'host' => '172.16.103.207',
  'prefix' => '',
);
//ERP stock
$databases['stock']['default'] = array(
  'driver' => 'mysql',
  'database' => 'erp_stock',
  'username' => 'erpstock',
  'password' => 'erpstock!@#',
  'host' => '172.16.103.189',
  'prefix' => '',
);
$conf['oci8'] = array(
  'databases' => array(
    'nchr' => array(
      'default' => array(
        'database' => 'ERP',
        'username' => 'mid',
        'password' => 'YFg7D$9ota9jvJwKWL1x',
        'hosts' => array('172.16.103.62'),
        'port' => '1521',
        'character_set' => 'AL32UTF8',
      ),
    ),
    'nc-monthly' => array(
      'default' => array(
        'database' => 'ERP',
        'username' => 'BOH2NC',
        'password' => 'wt5vuw#aj2NBFkJ#NDUt',
        'hosts' => array('172.16.103.62'),
        'port' => '1521',
        'character_set' => 'AL32UTF8',
      ),
    ),
    'boh' => array(
      'default' => array(
        'database' => 'BOH',
        'username' => 'TZXSCM',
        'password' => 'zkftzxSCMpAssw0rd',
        'hosts' => array('scan-boh.zkungfu.local'),
        'port' => '1631',
        'character_set' => 'AL32UTF8',
      ),
    ),
  ),
);
$update_free_access = FALSE;
$drupal_hash_salt = '';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 3600 * 24);
ini_set('session.cookie_lifetime', 2000000);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)|(?:system\/files)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
//reverse proxy config
$conf['reverse_proxy'] = TRUE;
$conf['reverse_proxy_addresses'] = array(
  '172.16.102.108',
  '172.16.102.111',
  '172.16.102.109',
);
$conf['reverse_proxy_header'] = 'HTTP_X_FORWARDED_FOR';

//memcache config
if (extension_loaded('memcached')) {
  $conf['cache_backends'][] = 'sites/all/modules/memcache_storage/memcache_storage.inc';
  $conf['cache_default_class'] = 'MemcacheStorage';
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
  $conf['cache_class_cache_update'] = 'DrupalDatabaseCache';
  $conf['memcache_storage_key_prefix'] = 'erp';
  $conf['memcache_storage_debug'] = FALSE;
  $conf['memcache_storage_wildcard_invalidate'] = 60 * 60 * 24 * 1; // 5 days.
  $conf['memcache_servers'] = array(
    #'172.16.102.107:11211' => 'default',
    #'172.16.102.112:11211' => 'default',
    #'172.16.102.113:11211' => 'default',
    #'172.16.102.228:11211' => 'default',
    #'172.16.102.107:11213' => 'default',
    '172.16.102.225:11213' => 'default',
  );
  #$conf['memcache_servers'] = array('memcached:11211' => 'default');
  $conf['memcache_extension'] = 'Memcached';
  $conf['memcache_options'] = array(
    Memcached::OPT_TCP_NODELAY => TRUE,
    Memcached::OPT_NO_BLOCK => TRUE,
    Memcached::OPT_BINARY_PROTOCOL => TRUE,
  );
  $conf['lock_inc'] = 'sites/all/modules/memcache_storage/includes/lock.inc';
}


#https://www.drupal.org/node/2241311
$conf['drupal_private_key'] = '5a30ab2454c9e4154909366ddcd697344cb9b53457210e1ae27fe58fde85019f';
$conf['composer_manager_vendor_dir'] = 'sites/all/vendor';
$conf['composer_manager_file_dir'] = 'sites/default/files/composer';
ini_set('memory_limit', '1024M');
ini_set('max_input_vars', 10000);
#ini_set('display_errors', TRUE);
#ini_set('display_startup_errors', TRUE);
