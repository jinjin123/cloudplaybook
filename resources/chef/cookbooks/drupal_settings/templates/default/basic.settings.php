<?php

/**
* Some distributions of Linux (most notably Debian) ship their PHP
* installations with garbage collection (gc) disabled. Since Drupal depends on
* PHP's garbage collection for clearing sessions, ensure that garbage
* collection occurs by using the most common settings.
*/
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);

/**
* Set session lifetime (in seconds), i.e. the time from the user's last visit
* to the active session may be deleted by the session garbage collector. When
* a session is deleted, authenticated users are logged out, and the contents
* of the user's $ _SESSION variable is discarded.
*/
ini_set('session.gc_maxlifetime', 200000);

/**
* Set session cookie lifetime (in seconds), i.e. the time from the session is
* created to the cookie expires, i.e. when the browser is expected to discard
* the cookie. The value 0 means 'until the browser is closed'.
*/
ini_set('session.cookie_lifetime', 2000000);

$conf['cron_safe_threshold'] = 0;

//For images work probably after redeploy, but less secure
$conf['image_allow_insecure_derivatives'] = TRUE;

$conf['file_public_path'] = 'sites/default/files';
$conf['file_temporary_path'] = '/tmp';
$conf['file_default_scheme'] = 'public';
     
//Social stats setting
$conf['social_stats_article'] = array (
  'Facebook' => 'Facebook',
  'Twitter' => 'Twitter',
  'Google Plus' => 0,
  'LinkedIn' => 0,
);
$conf['social_stats_essay'] = array (
  'Facebook' => 'Facebook',
  'Twitter' => 'Twitter',
  'Google Plus' => 0,
  'LinkedIn' => 0,
);
$conf['social_stats_sponsored_article'] = array (
  'Facebook' => 'Facebook',
  'Twitter' => 'Twitter',
  'Google Plus' => 0,
  'LinkedIn' => 0,
);
$conf['social_stats_cron_duration'] = '600';
$conf['social_stats_cron_interval'] = '86400';
$conf['social_stats_date_offset'] = '-30 days';
$conf['social_stats_options'] = '1';

$conf['preprocess_css'] = '1';
$conf['preprocess_js'] = '1';
