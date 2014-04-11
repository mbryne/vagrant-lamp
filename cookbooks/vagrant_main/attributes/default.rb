override['mysql']['server_root_password'] = 'vagrant'
override['mysql']['server_repl_password'] = 'vagrant'
override['mysql']['server_debian_password'] = 'vagrant'
override['mysql']['bind_address'] = '0.0.0.0'

override['drush']['install_method'] = "git"
override['drush']['version'] = "8.x-6.x"
