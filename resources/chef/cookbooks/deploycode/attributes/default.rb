
#source configuration
default[:deploycode][:code_owner] = "ec2-user"
default[:deploycode][:code_group] = "ec2-user"
default[:deploycode][:gitrepo] = "git@gitlab.kybot.io:root/kybot-deployment.git"
#default[:deploycode][:gitrepo] = "http://keithyau:thomas123@gitlab.kybot.io/root/kybot-deployment.git"
default[:deploycode][:localsourcefolder] = "/home/ec2-user/tools/tomcat_dir"
default[:deploycode][:checkout] = ""
