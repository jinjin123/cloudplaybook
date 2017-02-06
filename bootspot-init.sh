#! /bin/sh

# Sync time
yum -y install ntp ntpdate ntp-doc
ntpdate pool.ntp.org

#Assume Centos and login as root
cd /root

#Install Chef-solo
/usr/bin/curl -L https://www.opscode.com/chef/install.sh | bash

#Create Chef-repo
mkdir -p /root/bootdev/chef/chef-repo
#just in case
mkdir -p /home/keithyau/bootdev/shadowdock/
cd /root/bootdev/chef/chef-repo

#curl upgrade
yum -y update
yum -y install curl git

#checkout working branch
git clone https://keithyau:thomas123@bitbucket.org/bootdevsys/bootcloud.git .
git fetch && git checkout shadowdock_laravel_chef

#Update this server password: ToDo Random a password
echo 'thomas1234!' | passwd root --stdin
#get own IP and register to laravel, tell Laravel this server's password
ownip=`/usr/bin/curl --user "keithyau@163.com":thomas123 -F 'spot_sshpass=thomas1234!' -F "spot_sshroot=root" http://d.bootdev.com/spot-register`

#Update the Route53 cookbook self name for dockers to CNAME
changeme=`echo -n ${ownip} | md5sum | awk -F" " '{ print $1 }'`
cat <<EOF  > user_jsons/self_domain.json
{
      "deployuser":"root",
      "externalmode":"normal",
      "projectname":"shadowdock",
      "domainname":"shadowdock.com",
      "domain_type":"A",
      "domainprefix":"${changeme}",
      "thisserver":"${ownip}",
      "deploycode":{
         "basedirectory":"/home/keithyau/bootdev/shadowdock/",
         "runtime":{  
            "bootspotowndomain":{  
               "tag":"latest",
               "image":"spotdocker",
               "env":[  
                  "DUMMY"
               ],
               "command":"",
               "mountlocal":"localdir",
               "mountdocker":"/mnt",
               "proxyport":"80",
               "ports":"80"
            }
        }
      }
}
EOF

chef-solo -c solo.rb -o "recipe[bootdev_customdomain]" -j user_jsons/self_domain.json


#Save the new name into role, replace the default, put already cname domain in it
cat <<EOF  > roles/chefsoloinit.json
{
   "name":"chefsoloinit",
   "description":"this add a single new user docker to shadowdock",
   "json_class":"Chef::Role",
   "default_attributes":{
      "deployuser":"root",
      "externalmode":"bootproxy",
      "projectname":"shadowdock",
      "domainname":"shadowdock.com",
      "thisserver":"${changeme}.shadowdock.com",
      "docker": {
          "privaterepo":"dockerpriv.shadowdock.com",
          "username":"keithyau",
          "password":"thomas123"
      },
      "deploycode":{
         "basedirectory":"/home/keithyau/bootdev/shadowdock/",
         "localfolder":{  
            "shadowsocksinit":"nodownload"
         },
         "runtime":{
            "shadowsocksinit":{
               "tag":"latest",
               "image":"mritd/shadowsocks",
               "env":[
                  "DUMMY"
               ],
               "command":"",
               "mountlocal":"localdir",
               "mountdocker":"/mnt",
               "proxyport":"444",
               "ports":"5000"
            }
        }
      }
   },
   "override_attributes":{

   },
   "chef_type":"role",
   "run_list":[
      "recipe[git]",
      "recipe[build-essential]",
      "recipe[basicservice]",
      "recipe[glusterfs]",
      "recipe[webserver]",
      "recipe[deploycode]"
   ],
   "env_run_lists":{

   }
}
EOF

#Finally run chef and init all setups E.G. Docker install
chef-solo -c solo.rb -o "role[chefsoloinit]"
