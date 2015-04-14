#!/bin/bash
export HOME=/root
#. /opt/dep/firstry.sp
cd /opt/dep
#bitbucket username
buser= 

#bitbucket password
bpwd=  

#user's ec2 key
userpem=
role=
package=
while getopts u:p:k:g:r:m: opt
do
  case $opt in
    u)  buser=$OPTARG;;
    p)  bpwd=$OPTARG;;
    k)  userpem=$OPTARG;;
    g)  giturl=$OPTARG;;
    r)  role=$OPTARG;;
    m)  package=$OPTARG;;
    *)  echo "-$opt not recognized";;
  esac
done

current_buser=""
if [ -e buser.txt ]
then
  current_buser=`cat buser.txt`
else
  current_buser="notset";
fi

#register bitbucket key if not register yet
if [ -e /root/.ssh/gitkey ] && [ "$current_buser" == "$buser" ]
then
  echo "ssh key already registered ,skip register step" >> /var/log/deploy.log
else
  #Remove old key if any
  rm -f /root/.ssh/gitkey
  rm -f /root/.ssh/gitkey.pub
	
  #Generate new key
  ssh-keygen -N '' -f gitkey
  cp gitkey /root/.ssh/
  cp gitkey.pub /root/.ssh/
  chmod 600 /root/.ssh/gitkey /root/.ssh/gitkey.pub
  # Register key to Bitbucket
  php register.php $buser $bpwd
  rm -f gitkey gitkey.pub
fi

# Move key to chef workstation
if [ -d /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default ]; then
  cat /root/.ssh/gitkey > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.erb
  cat /root/.ssh/gitkey.pub > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/gitkey.pub.erb
  echo "" > /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/templates/default/known_hosts.erb
fi

# Replace the git repo entry in deploycode's Attribute
if [ -f /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb ]; then
  sed -i "/gitrepo/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
  export TEMP=`cat /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb|grep localsourcefolder`
  sed -i "/localsourcefolder/d" /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
  echo 'default[:deploycode][:gitrepo] = "'$giturl'"' >> /home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
  echo $TEMP >>/home/ec2-user/chef11/chef-repo/cookbooks/deploycode/attributes/default.rb
fi

# Replace the package value into cookbook attributes
if [ -f /home/ec2-user/chef11/chef-repo/cookbooks/drucloud_config/attributes/default.rb ]; then
  sed -i "s/Package/$package/" /home/ec2-user/chef11/chef-repo/cookbooks/drucloud_config/attributes/default.rb
fi

# Put different value into drupal_settings's attribute depends on package
search_default_module_value=""
search_node_value=""
if [ -f /home/ec2-user/chef11/chef-repo/cookbooks/drupal_settings/attributes/default.rb ]; then
  if [ "$package" = "free" ] || [ "$package" = "basic" ];
  then
    search_default_module_value="node"
    search_node_value="node"
  elif [ "$package" = "recommend" ]
  then
    search_default_module_value="apachesolr_search"
    search_node_value="0"
  fi
  sed -i "s/search_default_module_value/$search_default_module_value/" /home/ec2-user/chef11/chef-repo/cookbooks/drupal_settings/attributes/default.rb
  sed -i "s/search_node_value/$search_node_value/" /home/ec2-user/chef11/chef-repo/cookbooks/drupal_settings/attributes/default.rb
fi
echo $package >> /home/ec2-user/package.txt
echo $search_default_module_value >> /home/ec2-user/search_default_module_value.txt
echo $search_node_value >> /home/ec2-user/search_node_value.txt

# Prepare pem
#mkdir -p /home/ec2-user/.pem
#echo $userpem > /home/ec2-user/.pem/drucloud.pem
#mv  /home/ec2-user/drucloud.pem /home/ec2-user/.pem/drucloud.pem
#chmod 600 /home/ec2-user/.pem/drucloud.pem
#chown root:root /home/ec2-user/.pem/drucloud.pem 

# Configure knife to access client machine
#echo "knife[:ssh_user] = 'ec2-user'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb
#echo "knife[:identity_file] = '/home/ec2-user/.pem/drucloud.pem'" >> /home/ec2-user/chef11/chef-repo/.chef/knife.rb
#echo "configure knife ssh success"
	
#update all chef-client using knife

cd /home/ec2-user/chef11/chef-repo
echo $package >> /home/ec2-user/package.txt
if [ "$package" = "free" ]
then
  echo "chef-solo will be ran" >> /home/ec2-user/chef.log
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  sudo /usr/bin/chef-solo -o 'recipe[deploycode]' || true
  sudo /opt/dep/disable_modules.sh -h /home/ec2-user -r /var/www/html -u ec2-user 
# Disable apc for free Plan
  sudo /bin/sed -i 's/apc.enabled.*/apc.enabled = 0/' /etc/php.d/apc.ini
  exit 0
else
  if [ "$package" = "basic" ] || [ "$package" = "recommend" ]
  then
    echo "chef-client will be ran" >> /home/ec2-user/chef.log
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    /usr/bin/knife cookbook upload -a
    sleep 10 
    sudo /usr/bin/chef-solo -o 'recipe[deploycode]' || true
    /usr/bin/knife ssh "role:chefclient-base" "sudo chef-client -o 'recipe[deploycode]'" || true
  fi
  if [ "$package" = "basic" ]
  then
    sudo /opt/dep/disable_modules.sh -h /ec2-user -r /var/www/html -u ec2-user
  fi
fi
