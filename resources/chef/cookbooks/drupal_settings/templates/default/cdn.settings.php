<?php
//CDN conf
$conf['cdn_farfuture_status'] = '1';
$conf['cdn_basic_mapping'] = 'http://" . $CDN . "| .css .js
http://<%= @LoadBalancerDNS %>| .ttf .woff .svg .eot';
$conf['cdn_mode'] = 'basic';
$conf['cdn_status'] = '2';
