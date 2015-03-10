<?php
// Configuration of Search settings
$conf['search_cron_limit'] = '100';
$conf['search_default_module'] = '<%= @search_default_module %>';
$conf['transliteration_search'] = 1;
$conf['search_active_modules'] = array (
 <% if @search_default_module == "apachesolr_search" -%>
  'apachesolr_search' => 'apachesolr_search',
 <% end -%>
  'node' => '<%= @search_node %>',
  'user' => '0',
);