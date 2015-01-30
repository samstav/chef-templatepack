# Set password for Redis instance
node.run_state['|{.Cookbook.Name}|_redis_password_session'] = 'runstatepasswordsession'
node.run_state['|{.Cookbook.Name}|_redis_password_object'] = 'runstatepasswordobject'
node.run_state['|{.Cookbook.Name}|_redis_password_page'] = 'runstatepasswordpage'
