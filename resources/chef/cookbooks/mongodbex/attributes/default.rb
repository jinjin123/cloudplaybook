# Author  : Katt Tom
# Cookbook Name : mongodbex
# Attributes:: mongodbex
# Copyright 2013

default[:mongodbex][:appdir]="/var/www/html"
default[:mongodbex][:host] = "mongodb://drupalmongodb:drupalmongodb@ds053358-a0.mongolab.com:53358,ds053358-a1.mongolab.com:53358/sampledrupal"
default[:mongodbex][:dbname] = "sampledrupal"
default[:mongodbex][:cachebackends] = "sites/all/modules/contrib/mongodb/mongodb_cache/mongodb_cache.inc"
default[:mongodbex][:sessioninc] = "sites/all/modules/contrib/mongodb/mongodb_session/mongodb_session.inc"
