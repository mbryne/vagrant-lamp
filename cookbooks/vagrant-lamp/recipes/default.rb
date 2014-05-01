include_recipe "apt"
include_recipe "git"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_apc"
include_recipe "php::module_curl"
include_recipe "apache2::mod_php5"
include_recipe "database::mysql"
include_recipe "composer"
include_recipe "phing"

# Required packages
%w{ debconf vim subversion curl make g++ }.each do |a_package|
  package a_package
end

# Generate selfsigned ssl
execute "make-ssl-cert" do
  command "make-ssl-cert generate-default-snakeoil --force-overwrite"
  ignore_failure true
  action :nothing
end

# Initialize sites data bag
sites = []
begin
  sites = data_bag("sites")
rescue
  puts "Unable to load sites data bag."
end

# Configure prompt
cookbook_file "/home/vagrant/.bash_profile" do
  source "bash_profile"
  owner "vagrant"
  group "vagrant"
  mode "0644"
  action :create_if_missing
end
cookbook_file "/root/.bash_profile" do
  source "bash_profile"
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
end

# Configure sites
sites.each do |name|
  site = data_bag_item("sites", name)

  # Add site to apache config
  web_app site["host"] do
    template "sites.conf.erb"
    server_name site["host"]
    server_aliases site["aliases"]
    server_include site["include"]
    docroot site["docroot"]?site["docroot"]:"/vagrant/public/#{site["host"]}/www"
  end
  
  # create database
  mysql_database site["id"] do
    connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
    action :create
  end
  
  # create database user
  mysql_database_user site["id"] do
    connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
    password site["id"]
    database_name site["id"]
    privileges [:select,:update,:insert,:create,:delete]
    action :grant
  end
  
  # Add site info in /etc/hosts
  bash "hosts" do
   code "echo 127.0.0.1 #{site["host"]} #{site["aliases"].join(' ')} >> /etc/hosts"
  end
end

# Disable default site
apache_site "default" do
  enable false
end

# Setup Display Errors
template "#{node['php']['ext_conf_dir']}/display_errors.ini" do
  source "display_errors.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end

# Install phpmyadmin
cookbook_file "/tmp/phpmyadmin.deb.conf" do
  source "phpmyadmin.deb.conf"
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"
cookbook_file "/etc/phpmyadmin/config-db.php" do
  source "config-db.php"
  owner "vagrant"
  group "www-data"
  mode "0640"
  action :create
end

# Install Xdebug
php_pear "xdebug" do
  action :install
end
template "#{node['php']['ext_conf_dir']}/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end
