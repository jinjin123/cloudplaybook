#!/bin/bash
SOLR_URL=$1
cd /var/www/html/
sudo echo $SOLR_URL > /var/log/solr_setting.log
if ! [[ -z $SOLR_URL && ${SOLR_URL+x} ]]
then
#/root/.composer/vendor/bin/drush en apachesolr apachesolr_search -y -r /var/www/html/
/root/.composer/vendor/bin/drush features-revert-all -y /var/www/html/
/root/.composer/vendor/bin/drush solr-set-env-url $SOLR_URL -r /var/www/html/
#/usr/bin/chef-solo -j <(echo '{"drupal_settings":{"web_root":"/root/drucloudaws","web_user":"root","web_group":"root"}, "run_list": "recipe[drupal_settings]"}')
/root/.composer/vendor/bin/drush cc all -v -r /var/www/html/
fi
