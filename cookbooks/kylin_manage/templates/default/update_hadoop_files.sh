#!/bin/bash

echo "Running update_hadoop_files.sh"

# Taking Parameters
CLUSTERNAME=$1
if [ -z ${CLUSTERNAME+x} ];then
  export CLUSTERNAME=Kyligence_Enterprise_demo_architecture
fi

export EMR_MASTER=<%= node[:EMR_MASTER] %>
export COOKBOOK_PATH=/mnt/

echo "Cloning /usr/lib directory"
if [ ! -d "$COOKBOOK_PATH/usr/lib" ]; then
/bin/mkdir -p $COOKBOOK_PATH/usr/lib
fi
#jvm
for x in phoenix hadoop* bigtop* hive* hbase tez
do
/usr/bin/scp -r -i /root/.ssh/kylin.pem -oStrictHostKeyChecking=no ec2-user@$EMR_MASTER:/usr/lib/$x $COOKBOOK_PATH/usr/lib
done

echo "Cloning /etc directory"
if [ ! -d "$COOKBOOK_PATH/etc" ]; then
/bin/mkdir -p $COOKBOOK_PATH/etc
fi
for x in hadoop* hive* phoenix hbase tez
do
/usr/bin/scp -r -i /root/.ssh/kylin.pem -oStrictHostKeyChecking=no ec2-user@$EMR_MASTER:/etc/$x $COOKBOOK_PATH/etc
done

echo "Cloning /usr/bin directory"
if [ ! -d "$COOKBOOK_PATH/usr/bin" ]; then
/bin/mkdir -p $COOKBOOK_PATH/usr/bin
fi
for x in hadoop hbase hive emrfs yarn
do
/usr/bin/scp -r -i /root/.ssh/kylin.pem -oStrictHostKeyChecking=no ec2-user@$EMR_MASTER:/usr/bin/$x $COOKBOOK_PATH/usr/bin/
done

echo "Cloning /usr/share directory"
if [ ! -d "$COOKBOOK_PATH/usr/share" ]; then
/bin/mkdir -p $COOKBOOK_PATH/usr/share
fi
for x in aws
do
/usr/bin/scp -r -i /root/.ssh/kylin.pem -oStrictHostKeyChecking=no ec2-user@$EMR_MASTER:/usr/share/$x $COOKBOOK_PATH/usr/share/
done

# Update env script file
if [ ! `cat $COOKBOOK_PATH/usr/lib/hbase/conf/hbase-env.sh | grep '$HBASE_CLASSPATH'|wc -l` -eq 1 ];then
sed -i 's/export HBASE_CLASSPATH=.*/export HBASE_CLASSPATH=\$HBASE_CLASSPATH:\/etc\/hadoop\/conf\//' $COOKBOOK_PATH/usr/lib/hbase/conf/hbase-env.sh
fi

# Generation of chef client creation script
/usr/bin/chef-solo -o 'recipe[kylin_manage::client]' -j /etc/chef/parameter_emr.json


# if [ $? -eq 0 ]; then
#   /root/create_client.sh $CLUSTERNAME  >> /var/log/cfn-init.log
# fi
