<?php
// Memcache Configuration
$conf['memcache_servers'] = array(
'<%= @Memcache_server1 %>:<%= @Memcache_port1  %>' => 'default',
'<%= @Memcache_server2 %>:<%= @Memcache_port2  %>' => 'drucloud',
);

$conf['memcache_bins'] = array(
'cache' => 'default',
'cache_block' => 'drucloud',
'cache_content' => 'drucloud',
'cache_filter' => 'drucloud',
'cache_form' => 'drucloud',
'cache_menu' => 'drucloud',
'cache_page' => 'drucloud',
'cache_update' => 'drucloud',
'cache_views' => 'drucloud',
'cache_views_data' => 'drucloud',
);

$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache/memcache.inc';
$conf['cache_default_class'] = 'MemCacheDrupal';
$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
$conf['memcache_key_prefix'] = 'drucloud';
