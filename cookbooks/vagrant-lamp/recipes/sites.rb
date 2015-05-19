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
  siteroot = "/vagrant/sites/#{site["host"]}"
  webroot = site["webroot"] ? site["webroot"] : siteroot + "/web"
  
  # create site root
  directory siteroot do
    action :create
  end
  
  # Add site to apache config
  web_app site["host"] do
    template "sites.conf.erb"
    server_name site["host"]
    server_aliases site["aliases"]
    server_include site["include"]
    docroot webroot
  end
    
  # Checkout repository from git and setup initial site if required
  if site["repository"]    
    gitroot = site["gitroot"] ? site["gitroot"] : siteroot
    unless Dir.exist?("#{gitroot}/.git")
      git gitroot do
        repository site["repository"]
        revision "develop"
        action :checkout
        user "vagrant"
      end
    end
  end
  
  mysql_connection_info = {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}
  db_user = site["db_user"] ? site["db_user"] : site["id"]
  db_name = site["db_name"] ? site["db_name"] : site["id"]
  db_password  = site["db_password"] ? site["db_password"] : site["id"]
    
  # create database
  mysql_database db_name do
    connection mysql_connection_info
    action :create
    notifies :run, 'execute[import_db_' + site["id"] + ']', :immediately
  end
  
  # create database user
  mysql_database_user db_user[0..15] do
    connection mysql_connection_info
    password db_password
    database_name db_name
    privileges [:select,:update,:insert,:create,:delete,:"create temporary tables",:drop,:index,:alter,:"lock tables"]
    action :grant
  end
  
  # Add site info in /etc/hosts
  bash "hosts" do
   code "echo 127.0.0.1 #{site["host"]} #{site["aliases"].join(' ')} >> /etc/hosts"
  end
    
  # import initial database
  if site["sql"]
      log "IMPORTING DATABASE: " + site["sql"] do level :warn end
      execute "import_db_" + site["id"] do
        command "mysql -u root -p\"#{node['mysql']['server_root_password']}\" " + site["id"] + " < " + site["sql"]
        action :nothing
        only_if { ::File.exists?(site["sql"])}
      end
  else 
      #create dummy action if required 
      execute "import_db_" + site["id"] do
        command "echo \"no database for " + site["id"] + "\""
        action :nothing
      end
  end
    
  # # Run composer install if required
  # composer_file = siteroot + "/composer.json"
  # if !File.exist?(composer_file)
  #   composer_file = webroot + "/composer.json"
  # end
  # if File.exist?(composer_file)
  #   base_folder = File.dirname(composer_file)
  #   unless Dir.exist?(base_folder + "/vendor/")
  #     log "IMPORTING COMPOSER: " + composer_file do level :warn end
  #     composer_project base_folder do
  #         #dev true
  #         quiet false
  #         action :updateCannot retrieve metalink for repository: epel. Please verify its path and try again
  #         user "vagrant"
  #     end
  #   end
  # end
  #
  # # NPM packages install
  # packages_file = siteroot + "/package.json"
  # if !File.exist?(packages_file)
  #   packages_file = webroot + "/package.json"
  # end
  # if File.exist?(packages_file)
  #     log "TRYING NPM: " + packages_file do level :warn end
  #   base_folder = File.dirname(packages_file)
  #   unless Dir.exist?(base_folder + "/node_modules/")
  #     log "IMPORTING NPM: " + packages_file do level :warn end
  #     nodejs_npm site["id"] + 'node' do
  #       path base_folder
  #       json true
  #       user "vagrant"
  #     end
  #   else
  #     log "UN NPM: " + base_folder + "/node_modules/" do level :warn end
  #   end
  # else
  #
  #   log "NOT FOUND NPM: " + packages_file do level :warn end
  # end
  #
  
  
end

# Disable default site
apache_site "default" do
  enable false
end
