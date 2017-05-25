#!/bin/bash

IDENTIFIER=$1
DEPLOYJSON=$2
DATFILEDIR=/root/tools/code/azure

# Ensuring path exists
mkdir -p $DATFILEDIR/$IDENTIFIER

cd /home/kylin/chef12 && /bin/knife node delete $IDENTIFIER -y || :
cd /home/kylin/chef12 && /bin/knife client delete $IDENTIFIER -y || :

cp /etc/chef/client.rb /root/tools/code/azure/$IDENTIFIER/client.rb
sed -i "s/CHEFCLIENTNAME/$IDENTIFIER/" /root/tools/code/azure/$IDENTIFIER/client.rb

mkdir -p /root/tools/code/azure/$IDENTIFIER/data
echo $DEPLOYJSON > /root/tools/code/azure/$IDENTIFIER/deploy.json
# if [ ! -z ${var+x} ];
# then
  # echo $DEPLOYJSON > /root/tools/code/azure/$IDENTIFIER/deploy.json
  # mkdir -p /root/tools/code/azure/$IDENTIFIER/data
  # cp /root/tools/code/azure/$IDENTIFIER/deploy.json /data/$IDENTIFIER/deploy.json
# fi
# echo $2 > /root/tools/code/azure/$IDENTIFIER/deploy.json
# touch /root/tools/code/azure/$IDENTIFIER/azure.log

# Clear azure.log
echo "" > /root/tools/code/azure/$IDENTIFIER/azure.log

docker run --rm --network=host --name chef-client-$IDENTIFIER \
-v /root/tools/code/azure/$IDENTIFIER/data/:/root/tools/code/azure/$IDENTIFIER/ \
-v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
-v /etc/chef/validator.pem:/etc/chef/validator.pem \
-v /root/tools/code/azure/$IDENTIFIER/client.rb:/etc/chef/client.rb \
-v /root/tools/code/azure/$IDENTIFIER/deploy.json:/etc/chef/deploy.json \
-v /root/tools/code/azure/$IDENTIFIER/azure.log:/root/.azure/azure.err \
dockerpriv.kybot.io:5002/keithyau/chefclient:0.2 \
chef-client -o 'role[chefclient-kyligence-azure]' -j /etc/chef/deploy.json

export RETURNCODE=$?

# -v /root/tools/code/azure/$IDENTIFIER/deploy.json:/etc/chef/deploy.json \
# -o 'role[chefclient-kyligence-azure]'

cd /home/kylin/chef12 && /bin/knife node delete $IDENTIFIER -y || :
cd /home/kylin/chef12 && /bin/knife client delete $IDENTIFIER -y || :

# Setting return code of script
if [ "$RETURNCODE" -eq 0 ]
then
  true
else
  false
fi
