#!/bin/bash
SOLR_URL=$1
cd /root/drucloudaws/
sudo echo $SOLR_URL > /var/log/solr_setting.log
if ! [[ -z $SOLR_URL && ${SOLR_URL+x} ]]
then
#/root/.composer/vendor/bin/drush en apachesolr apachesolr_search -y -r /root/drucloudaws/
/root/.composer/vendor/bin/drush solr-set-env-url $SOLR_URL -r /root/drucloudaws/
/root/.composer/vendor/bin/drush sql-query 'INSERT INTO apachesolr_index_bundles (env_id, entity_type, bundle) values ("solr","node","article");' -r /root/drucloudaws/
/root/.composer/vendor/bin/drush cc all -v -r /root/drucloudaws/
fi
