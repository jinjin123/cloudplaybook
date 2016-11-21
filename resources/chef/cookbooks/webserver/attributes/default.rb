
#source configuration
default[:webserver][:code_owner] = "ec2-user"
default[:webserver][:code_group] = "ec2-user"
default[:webserver][:gitrepo] = "git@bitbucket.org:samseart/drucloud7-system.git"
default[:webserver][:localsourcefolder] = "/var/www/html"
default[:webserver][:checkout] = ""
