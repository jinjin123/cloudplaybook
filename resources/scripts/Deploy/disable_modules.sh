#!/bin/bash
USER_HOME=""
WEB_ROOT=""
USER=""

while getopts h:r:u: opt
do
  case $opt in
    h)  USER_HOME=$OPTARG;;
    r)  WEB_ROOT=$OPTARG;;
    u)  USER=$OPTARG;;
    *)  echo "-$opt not recognized";;
  esac
done


## declare an array variable
declare -a arr=("apachesolr" "advagg_css_cdn" "advagg_js_cdn" "memcache" "cdn" "apachesolr_search")

## now loop through the above array
for i in "${arr[@]}"
do
  su -c "source $USER_HOME/.bashrc;cd $WEB_ROOT/sites/default;$USER_HOME/.composer/vendor/bin/drush dis $i -y || true" -m $USER
done
