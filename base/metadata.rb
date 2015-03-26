name             '|{ cookbook["name"] }|'
maintainer       'Rackspace US, Inc.'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license          'All rights reserved'
description      'Installs/Configures |{ cookbook["name"] }|'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'platformstack'
depends 'users'
depends 'locale'
depends 'apt'
depends 'yum'
# Please bear in mind, due to Jinja templating, there must be TWO line breaks at the
# end of this file.

