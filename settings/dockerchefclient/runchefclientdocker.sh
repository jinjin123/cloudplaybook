#!/bin/bash

IDENTIFIER=$1
CLUSTERNAME=$2
DEPLOYJSON=$3

DEPLOYID=$IDENTIFIER"_"$CLUSTERNAME

# Clearing old chef node and client
cd /home/kylin/chef12 && /bin/knife node delete $DEPLOYID -y > /dev/null 2>&1 || :
cd /home/kylin/chef12 && /bin/knife client delete $DEPLOYID -y > /dev/null 2>&1 || :

echo $DEPLOYJSON > /root/tools/code/$DEPLOYID.deploy.json

if [[ $DEPLOYJSON == *"azure"* ]]; then
  # if deployment is on Azure
  DATFILEDIR=/root/tools/code/azure
  mkdir -p $DATFILEDIR/$DEPLOYID

  # Preparing Chef client
  cp /etc/chef/client.rb /root/tools/code/azure/$DEPLOYID/client.rb
  sed -i "s/CHEFCLIENTNAME/$DEPLOYID/" /root/tools/code/azure/$DEPLOYID/client.rb

  # Preparing Azure command line and templates
  mkdir -p /root/tools/code/azure/$DEPLOYID/data
  echo $DEPLOYJSON > /root/tools/code/azure/$DEPLOYID/deploy.json
  echo "" > /root/tools/code/azure/$DEPLOYID/azure.log

  docker run --rm --network=host --name chef-client-$DEPLOYID \
  -v /root/tools/code/azure/$DEPLOYID/data/:/root/tools/code/azure/$IDENTIFIER/ \
  -v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
  -v /etc/chef/validator.pem:/etc/chef/validator.pem \
  -v /root/tools/code/azure/$DEPLOYID/client.rb:/etc/chef/client.rb \
  -v /root/tools/code/azure/$DEPLOYID/deploy.json:/etc/chef/deploy.json \
  -v /root/tools/code/azure/$DEPLOYID/azure:/root/.azure \
  dockerpriv.kybot.io:5002/keithyau/chefclient:latest \
  chef-client -o 'role[chefclient-kyligence-azure]' -j /etc/chef/deploy.json --log_level debug

  export RETURNCODE=$?


else
# if deployment is on Aws
  DATFILEDIR=/root/tools/code/aws
  # Ensuring path exists
  mkdir -p $DATFILEDIR/$DEPLOYID

  # Preparing Chef client
  cp /etc/chef/client.rb $DATFILEDIR/$DEPLOYID/client.rb
  sed -i "s/CHEFCLIENTNAME/$DEPLOYID/" $DATFILEDIR/$DEPLOYID/client.rb

  # Preparing AWS command line and templates
  mkdir -p $DATFILEDIR/$DEPLOYID/data
  echo $DEPLOYJSON > $DATFILEDIR/$DEPLOYID/deploy.json

  # Preparing Credentials
  mkdir -p $DATFILEDIR/$DEPLOYID/data/credentials
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/gitkey.erb $DATFILEDIR/$DEPLOYID/data/credentials/gitkey
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/gitkey.pub.erb $DATFILEDIR/$DEPLOYID/data/credentials/gitkey.pub
  cp /home/kylin/chef12/cookbooks/deploycode/templates/default/known_hosts.erb $DATFILEDIR/$DEPLOYID/data/credentials/knownhost
  # cp /home/kylin/chef12/cookbooks/deploycode/templates/default/kylin.pem $DATFILEDIR/$IDENTIFIER/data/credentials/kylin.pem

  docker run --rm --network=host --name chef-client-$DEPLOYID \
  -v /root/tools/code/aws/$DEPLOYID/data/:/root/tools/code/aws/$IDENTIFIER/ \
  -v /etc/chef/kylin.pem:/etc/chef/kylin.pem \
  -v /etc/chef/validator.pem:/etc/chef/validator.pem \
  -v /root/tools/code/aws/$DEPLOYID/client.rb:/etc/chef/client.rb \
  -v /root/tools/code/aws/$DEPLOYID/deploy.json:/etc/chef/deploy.json \
  -v /root/tools/code/aws/$DEPLOYID/aws:/root/.aws \
  dockerpriv.kybot.io:5002/keithyau/chefclient:latest \
  chef-client -o 'role[chefclient-kyligence-aws]' -j /etc/chef/deploy.json
  export RETURNCODE=$?

fi

# Clearing old chef node and client
cd /home/kylin/chef12 && /bin/knife node delete $DEPLOYID -y > /dev/null 2>&1 || :
cd /home/kylin/chef12 && /bin/knife client delete $DEPLOYID -y > /dev/null 2>&1 || :
docker stop chef-client-$DEPLOYID;
docker rm chef-client-$DEPLOYID;

# Setting return code of script
# if [ "$RETURNCODE" -eq 0 ]
# then
#   true
# else
#   false
# fi
exit $RETURNCODE
