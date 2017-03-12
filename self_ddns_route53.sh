#! /bin/bash

cd /root/bootdev/chef/chef-repo

ownip=`dig +short myip.opendns.com @resolver1.opendns.com`

thisuniqueid="$(dmidecode | grep -i uuid | head -1 | awk -F" " '{print $2}')"

#Update the Route53 cookbook self name for dockers to CNAME
changeme=`echo -n ${thisuniqueid} | md5sum | awk -F" " '{ print $1 }'`

echo $changeme

cat <<EOF  > user_jsons/self_domain_cron.json
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

chef-solo -c ./settings/solo.rb -o "recIpe[bootdev_customdomain]" -j user_jsons/self_domain_cron.json
