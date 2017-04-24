name             'bootdev_customdomain'
maintainer       'BootDev'
maintainer_email 'keithyau@bootdev.com'
license          'All rights reserved'
description      'Bind domain for each users to access bootdev dockers'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends 'docker', '~> 2.0'
depends 'route53', '~> 1.1'
