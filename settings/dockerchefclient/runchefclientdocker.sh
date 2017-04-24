#!/bin/bash

IDENTIFIER=$1
DEPLOYJSON=$2
DATFILEDIR=/root/tools/code/azure

# Ensuring path exists
mkdir -p $DATFILEDIR/$IDENTIFIER

cp /etc/chef/client.rb /root/tools/code/azure/$IDENTIFIER/client.rb
sed -i "s/CHEFCLIENTNAME/$IDENTIFIER/" /root/tools/code/azure/$IDENTIFIER/client.rb
echo $2 > /root/tools/code/azure/$IDENTIFIER/deploy.json

docker run --rm --network=host --name chef-client-$IDENTIFIER \
-v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
-v /etc/chef/validator.pem:/etc/chef/validator.pem \
-v /root/tools/code/azure/$IDENTIFIER/client.rb:/etc/chef/client.rb \
-v /root/tools/code/azure/$IDENTIFIER/deploy.json:/etc/chef/deploy.json \
dockerpriv.kybot.io:5002/keithyau/chefclient:0.2 \
chef-client -l debug -o 'role[chefclient-kyligence-azure]' -j /etc/chef/deploy.json

# -o 'role[chefclient-kyligence-azure]'

knife node delete $IDENTIFIER -y;
knife client delete $IDENTIFIER -y
