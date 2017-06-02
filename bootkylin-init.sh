#! /bin/sh

#Disable SELinux, otherwise, docker mount with permission fail
echo "SELINUX=disabled" > /etc/sysconfig/selinux
setenforce 0

# Sync time
CHECKING_NTPDATE=`command -v ntpdate|wc -l`
if [ "$CHECKING_NTPDATE" != "0" ]; then
    echo "NTPDATE exists"
else
    yum -y install ntp ntpdate ntp-doc
fi
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
mkdir -p /root/kylin/chef/chef-repo
#just in case
#mkdir -p /home/keithyau/bootdev/shadowdock/
cd /root/kylin/chef/chef-repo

#curl upgrade
yum -y update
CHECKING_GIT=`command -v git|wc -l`
if [ "$CHECKING_GIT" != "0" ]; then
    echo "GIT exists"
else
    yum -y install git
fi

#Must install
yum -y install curl wget bind-utils

#checkout working branch
git clone -b docker-general-kyligence https://keithyau:thomas123@github.com/Kyligence/kylindeploy.git .

#prepare directories
mkdir -p logs

#Make this Linux Unique ID
#thisuniqueid="$(dmidecode | grep -i uuid | head -1 | awk -F" " '{print $2}')"
#Since dmidecode code cannot get unique id, temp use mac address
#thisuniqueid=`ip addr show | grep ether | head -1 | awk -F" "  '{print $2}'`

#get own IP and register to laravel, tell Laravel this server's password
#ownip=`/usr/bin/curl --user "keithyau@163.com":thomas123 -F "linux_uid=${thisuniqueid}" -F 'spot_sshpass=thomas1234!' -F "spot_sshroot=root" http://d.bootdev.com/spot-register`

chef-solo -c ./settings/solo.rb -o "recipe[hadoop_files]" -j user_jsons/kap_emr_conf.json

