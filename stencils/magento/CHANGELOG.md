magento template CHANGELOG
==================


0.0.1
-----

- @martinb3 - Test cloud files install method, works flawlessly
- @martinb3 - Split install methods into ark, cloudfiles, or none
- @martinb3 - Add 'cloudfiles' install method, used rackspacecloud LWRPs
- @martinb3 - Adjust configuration of magento to write out shell script with configuration options instead of calling it inline.
- @martinb3 - Guard call to `mysql-multi::_find_master` (we probably should not be using it, opened #30 to discuss), call `mysql-multi::master` instead of base so we get a node we can find later.
- @martinb3 - Add 'expanded' default recipe in wrapper that converges separate redis instances instead of a single one. This should now handle any configuration of runlist thrown at it.
- @martinb3 - Add redisio as a direct dependency, and in Berksfile until release. redis-multi is too simplistic for this deployment, and some bugs are fixed in git that aren't released yet
- @martinb3 - Add separate redis recipes for session store and page, object caches and their slaves
- @martinb3 - Add redis sentinel recipes that find the right instance
- @martinb3 - Add expanded default recipe, that converges individual components (like 3 redis vs. single redis)
- @martinb3 - Add a redis discovery recipe that finds any redis instances in the same chef environment
- @martinb3 - Add iptables to `::redis_configure` recipe
- @martinb3 - Add tags to node before saving node, so tags are findable on node.save
- @martinb3 - Add library with methods to discover redis instances, find master instances, recompute redis attributes, and get the best IP for a node from its name
- @martinb3 - Add Apache vhost, cleanup testing for things we didn't converge
- @martinb3 - Remove return on missing attribute
- @martinb3 - Could not pass testing with listen_ports mixing node.default and node.set
- @martinb3 - Remove template for magentostack.ini, since actual source file was already removed
- @martinb3 - Switch to node.deep_fetch with additional guards, since some of the attributes were removed here
- @martinb3 - s/phpstack/magentostack/g everywhere
