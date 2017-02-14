<?php

$databases = array (
  'default' => array (
    'default' => array (
      'database' => 'erp',
      'username' => 'keithyau',
      'password' => 'thomas123',
      'host' => 'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
  'slave' => array (
    'default' => array (
      'database' => 'cc2',
      'username' => 'terry',
      'password' => 'Abcd@1234~',
      'host' => '172.16.103.189',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
$databases['oc']['default'] = array(
  'driver' => 'mysql',
  'database' => 'newposoc',
  'username' => 'npcreadonly',
  'password' => 'uH2zVJ0C7fEcI96wvpPk',
  'host' => '172.16.103.191',
  'prefix' => '',
);
$databases['gfs']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'ocselect',
  'password' => 'AZTfjuCFoppEC6wR',
  'host' => '172.16.103.186',
  'prefix' => '',
);
//?~P~H并?~P~N?~Z~DOC
$databases['oc_final']['default'] = array(
  'driver' => 'mysql',
  'database' => 'oc',
  'username' => 'newpos',
  'password' => 'newpos',
  'host' => '172.16.103.207',
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
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)|(?:system\/files)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';

//$conf['memcache_servers'] = array('172.16.102.113:11211' => 'default');
#$conf['cache_backends'][] = 'sites/all/modules/memcache/memcache.inc';
#$conf['lock_inc'] = 'sites/all/modules/memcache/memcache-lock.inc';
//$conf['cache_backends'][] = 'sites/all/modules/memcache_storage/memcache_storage.inc';
//$conf['lock_inc'] = 'sites/all/modules/memcache_storage/includes/lock.inc';
//$conf['memcache_stampede_protection'] = TRUE;
//$conf['cache_default_class'] = 'MemCacheStorage';
//$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
//$conf['memcache_key_prefix'] = 'erp';
//$conf['memcache_extension'] = 'Memcache';


#https://www.drupal.org/node/2241311
$drupal_hash_salt = '9f73c3525e701728fca984152b17279f300889fc8885b8bc6e78c';
$conf['drupal_private_key'] = '5a30ab2454c9e4154909366ddcd697344cb9b53457210e1ae27fe58fde85019f';

