# Initialize sites data bag
sites = []
begin
  sites = data_bag("sites")
rescue
  puts "Unable to load sites data bag."
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
    docroot site["docroot"]?site["docroot"]:"/vagrant/sites/#{site["host"]}/www"
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
    privileges [:select,:update,:insert,:create,:delete,:"create temporary tables",:drop,:index,:alter,:"lock tables"]
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
