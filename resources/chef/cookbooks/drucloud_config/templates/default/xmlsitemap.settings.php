<?php
//XMLSitemap setting
$conf['xmlsitemap_base_url'] = 'http://<%= @LoadBalancerDNS %>';
$conf['xmlsitemap_path'] = '<%= @S3bucket %>/xmlsitemap/drucloud';
