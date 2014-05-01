include_recipe "php"

# Install Drush
dc = php_pear_channel "pear.drush.org" do 
  action :discover 
end

# Install drush
php_pear "drush" do
  version "6.2.0.0"
  channel dc.channel_name
  action :install
end

