#! /bin/sh

#Disable SELinux, otherwise, docker mount with permission fail
echo "SELINUX=disabled" > /etc/sysconfig/selinux
setenforce 0

# Sync time
yum -y install ntp ntpdate ntp-doc
ntpdate pool.ntp.org

#Assume Centos and login as root
cd /root

#Install Chef-solo
CHECKING_CHEFSOLO=`command -v chef-solo|wc -l`
if [ "$CHECKING_CHEFSOLO" != "0" ]; then
    echo "Chef Solo exists"
else
    echo "Installing Chef Solo"
    /usr/bin/curl -L https://www.opscode.com/chef/install.sh | bash
fi

#Create Chef-repo
mkdir -p /root/bootdev/chef/chef-repo
#just in case
mkdir -p /home/keithyau/bootdev/shadowdock/
cd /root/bootdev/chef/chef-repo

#curl upgrade
yum -y update
yum -y install curl git

#checkout working branch
git clone -b docker-general https://keithyau:thomas123@bitbucket.org/bootdevsys/bootcloud.git .

#Update this server password: ToDo Random a password
echo 'thomas1234!' | passwd root --stdin

#Make this Linux Unique ID
thisuniqueid="$(dmidecode | grep -i uuid | head -1 | awk -F" " '{print $2}')"

#get own IP and register to laravel, tell Laravel this server's password
ownip=`/usr/bin/curl --user "keithyau@163.com":thomas123 -F "linux_uid=${thisuniqueid}" -F 'spot_sshpass=thomas1234!' -F "spot_sshroot=root" http://d.bootdev.com/spot-register`

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

chef-solo -c ./settings/solo.rb -o "recipe[bootdev_customdomain]" -j user_jsons/self_domain.json


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

#Generate required role per docker run
cat <<EOF > roles/singleusercreate.json
{
   "name":"singleusercreate",
   "description":"this add a single new user docker to shadowdock",
   "json_class":"Chef::Role",
   "default_attributes":{
      "deployuser":"root",
      "externalmode":"bootproxy",
      "projectname":"shadowdock",
      "domainname":"shadowdock.com",
      "domain_type":"A",
      "thisserver":"${changeme}.shadowdock.com",
      "docker": {
          "privaterepo":"dockerpriv.shadowdock.com",
          "username":"keithyau",
          "password":"thomas123"
      },
      "deploycode":{
         "basedirectory":"/home/keithyau/bootdev/shadowdock/"
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
      "recipe[deploycode]",
      "recipe[drupalsetting]",
      "recipe[bootdev_customdomain]"
   ],
   "env_run_lists":{

   }
}

EOF



#Finally run chef and init all setups E.G. Docker install
chef-solo -c ./settings/solo.rb -o "role[chefsoloinit]"
