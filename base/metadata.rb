name             '|{ .Name }|'
maintainer       'Rackspace US, Inc.'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license          'All rights reserved'
description      'Installs/Configures |{ .Name }|'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apache2', '~> 3.0.0'
depends 'database', '= 3.0.1'
depends 'platformstack', '>= 1.5.3'
depends 'stack_commons', '>= 0.0.37'
