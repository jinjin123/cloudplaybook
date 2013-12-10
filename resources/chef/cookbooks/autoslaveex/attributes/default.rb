# Author : Katt Tom
# Cookbook Name : autoslaveex
# Attributes:: autoslaveex
# Copyright 2013
#

default[:autoslaveex][:appdir] = "/var/www/html"
default[:autoslaveex][:masterhost] = "masterxxx"
default[:autoslaveex][:slavehost] = "slavexxx"
default[:autoslaveex][:dbuser] = "root"
default[:autoslaveex][:dbpwd] = "tom123"
default[:autoslaveex][:dbname] = "drupal"
default[:autoslaveex][:port] = "3306"
default[:autoslaveex][:lockinc] = "sites/all/modules/contrib/autoslave/memcache-lock.inc"
default[:autoslaveex][:cachebackends] = "sites/all/modules/contrib/autoslave/autoslave.cache.inc"



