#!/bin/bash

IDENTIFIER=$1
DEPLOYJSON=$2

# Clearing old chef node and client
cd /home/kylin/chef12 && /bin/knife node delete $IDENTIFIER -y || :
cd /home/kylin/chef12 && /bin/knife client delete $IDENTIFIER -y || :

if [[ $DEPLOYJSON == *"azure"* ]]; then
  # if deployment is on Azure
  DATFILEDIR=/root/tools/code/azure
  # Ensuring path exists
  if [[ $DEPLOYJSON == *"resize"* ]]; then
    export IDENTIFIER=$IDENTIFIER$(( ( RANDOM % 1000 )  + 1 ))
  fi
  mkdir -p $DATFILEDIR/$IDENTIFIER

  # Preparing Chef client
  cp /etc/chef/client.rb /root/tools/code/azure/$IDENTIFIER/client.rb
  sed -i "s/CHEFCLIENTNAME/$IDENTIFIER/" /root/tools/code/azure/$IDENTIFIER/client.rb

  # Preparing Azure command line and templates
  mkdir -p /root/tools/code/azure/$IDENTIFIER/data
  echo $DEPLOYJSON > /root/tools/code/azure/$IDENTIFIER/deploy.json
  echo "" > /root/tools/code/azure/$IDENTIFIER/azure.log

  docker run --rm --network=host --name chef-client-$IDENTIFIER \
  -v /root/tools/code/azure/$IDENTIFIER/data/:/root/tools/code/azure/$IDENTIFIER/ \
  -v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
  -v /etc/chef/validator.pem:/etc/chef/validator.pem \
  -v /root/tools/code/azure/$IDENTIFIER/client.rb:/etc/chef/client.rb \
  -v /root/tools/code/azure/$IDENTIFIER/deploy.json:/etc/chef/deploy.json \
  -v /root/tools/code/azure/$IDENTIFIER/azure:/root/.azure \
  dockerpriv.kybot.io:5002/keithyau/chefclient:latest \
  chef-client -o 'role[chefclient-kyligence-azure]' -j /etc/chef/deploy.json

  if [[ $DEPLOYJSON == *"resize"* ]]; then
    cd /home/kylin/chef12 && /bin/knife node delete $IDENTIFIER -y || :
    cd /home/kylin/chef12 && /bin/knife client delete $IDENTIFIER -y || :
  fi

  export RETURNCODE=$?
else
# if deployment is on Aws
  DATFILEDIR=/root/tools/code/aws
  # Ensuring path exists
  mkdir -p $DATFILEDIR/$IDENTIFIER

  # Preparing Chef client
  cp /etc/chef/client.rb /root/tools/code/aws/$IDENTIFIER/client.rb
  sed -i "s/CHEFCLIENTNAME/$IDENTIFIER/" /root/tools/code/aws/$IDENTIFIER/client.rb

  # Preparing AWS command line and templates
  mkdir -p /root/tools/code/aws/$IDENTIFIER/data
  echo $DEPLOYJSON > /root/tools/code/aws/$IDENTIFIER/deploy.json

  # Preparing Credentials
  mkdir -p $DATFILEDIR/$IDENTIFIER/data/credentials
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/gitkey.erb $DATFILEDIR/$IDENTIFIER/data/credentials/gitkey
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/gitkey.pub.erb $DATFILEDIR/$IDENTIFIER/data/credentials/gitkey.pub
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/known_hosts.erb $DATFILEDIR/$IDENTIFIER/data/credentials/knownhost
  # cp /home/kylin/chef12/cookbooks/deploycode/templates/default/kylin.pem $DATFILEDIR/$IDENTIFIER/data/credentials/kylin.pem

  docker run --rm --network=host --name chef-client-$IDENTIFIER \
  -v /root/tools/code/aws/$IDENTIFIER/data/:/root/tools/code/aws/$IDENTIFIER/ \
  -v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
  -v /etc/chef/validator.pem:/etc/chef/validator.pem \
  -v /root/tools/code/aws/$IDENTIFIER/client.rb:/etc/chef/client.rb \
  -v /root/tools/code/aws/$IDENTIFIER/deploy.json:/etc/chef/deploy.json \
  dockerpriv.kybot.io:5002/keithyau/chefclient:latest \
  chef-client -o 'role[chefclient-kyligence-aws]' -j /etc/chef/deploy.json
  export RETURNCODE=$?
fi

# Clearing old chef node and client
cd /home/kylin/chef12 && /bin/knife node delete $IDENTIFIER -y || :
cd /home/kylin/chef12 && /bin/knife client delete $IDENTIFIER -y || :
docker stop chef-client-$IDENTIFIER;
docker rm chef-client-$IDENTIFIER;
# Setting return code of script
if [ "$RETURNCODE" -eq 0 ]
then
  true
else
  false
fi
