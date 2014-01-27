# Author : Katt Tom
# # Cookbook Name : sourcecode
# # Attributes:: sourcecode
# # Copyright 2013
# #
#
#source configuration
default[:sourcecode][:appdir] = "/var/www/html"
default[:sourcecode][:gitrepo] = "git@bitbucket.org:mobingi/mobingi_server.git"
default[:sourcecode][:appuser] = "webapp"
default[:sourcecode][:appusergroup] = "apache"

#nfs configuration
default[:sourcecode][:nfssharefolder] = "/opt/nfs/source"
default[:sourcecode][:localsourcefolder] = "/opt/nfs/app"
default[:sourcecode][:nfsserverip] = "10.0.0.245"


#db.settings.php configuration
default[:sourcecode][:dburl] = "cmt8vhxjv77gza.c0ao1k8qfl2y.ap-northeast-1.rds.amazonaws.com"
default[:sourcecode][:dbuser] = "root"
default[:sourcecode][:dbpwd] = "mxm4inch"
default[:sourcecode][:devprofile] = "standard"
default[:sourcecode][:route53zoneid] = "Z9W2DUX1AMJCJ"
