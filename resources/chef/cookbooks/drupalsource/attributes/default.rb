# Author : Katt Tom
# # Cookbook Name : drupalsource
# # Attributes:: drupalsource
# # Copyright 2013
# #
#
#source configuration
default[:drupalsource][:appdir] = "/var/www/html"
default[:drupalsource][:gitrepo] = "git@bitbucket.org:mobingi/mobingi_server.git"
default[:drupalsource][:appuser] = "webapp"
default[:drupalsource][:appusergroup] = "apache"

#nfs configuration
default[:drupalsource][:nfssharefolder] = "/opt/nfs/source"
default[:drupalsource][:localsourcefolder] = "/opt/nfs/app"
default[:drupalsource][:nfsserverip] = "iptochange"


#db.settings.php configuration
default[:drupalsource][:dburl] = "cmt8vhxjv77gza.c0ao1k8qfl2y.ap-northeast-1.rds.amazonaws.com"
default[:drupalsource][:dbuser] = "root"
default[:drupalsource][:dbpwd] = "mxm4inch"
default[:drupalsource][:devprofile] = "standard"
default[:drupalsource][:route53zoneid] = "Z9W2DUX1AMJCJ"
