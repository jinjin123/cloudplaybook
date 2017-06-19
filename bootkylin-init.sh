#! /bin/sh

#Disable SELinux, otherwise, docker mount with permission fail
echo "SELINUX=disabled" > /etc/sysconfig/selinux
setenforce 0

#Enable release in EMR master AMI
echo "releasever=latest" >> /etc/yum.conf

#Fix yum cache
rm -rf /var/cache
mkdir /var/cache

#curl upgrade
yum -y update
yum -y install git

#Must install
yum -y install curl wget bind-utils

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

#checkout working branch
git clone -b docker-general-kyligence https://keithyau:thomas123@github.com/Kyligence/kylindeploy.git .

#prepare directories
mkdir -p logs

#Key permission
chmod 400 /root/kylin/chef/chef-repo/pem/clientemr.pem

chef-solo -c ./settings/solo.rb -o "recipe[hadoop_files]" -j user_jsons/kap_emr_conf.json

#start kap, need sparate action from UI
#su hdfs
#cd /usr/local/kap/kap-2.3.7-GA-hbase1.x
#bin/kylin.sh start


#OR
#hadoop fs -mkdir /kylin
#hadoop fs -chown root:hadoop /kylin
