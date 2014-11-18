name             'activelamp_drupal'
maintainer       'Bez Hermoso, ActiveLAMP'
maintainer_email 'bez@activelamp.com'
license          'Apache v2.0'
description      'Cookbook for deploying Drupal websites and for installing Drush'
long_description 'Provides the `drupal_make` resource for Drupal deploys, and the `drupal_make::drush` recipe.'
version          '0.0.4'

provides 'activelamp_drupal::drush'
provides 'drupal_make[/path/to/deploy]'

recommends 'activelamp_composer'

supports 'ubuntu'
supports 'debian'
supports 'redhat'