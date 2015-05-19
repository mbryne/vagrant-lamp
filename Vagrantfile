# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, guest: 3306, host: 33066    
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.33.10"

  # Either NFS or default virtual box additions
  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder "../sites", "/sites", mount_options: ['dmode=777','fmode=666']
  else 
    config.vm.synced_folder "../sites", "/sites", type: "nfs", :mount_options => ['actimeo=2']  
  end
   
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest
  config.ssh.forward_agent = true
  
  config.vm.provision :chef_solo do |chef|
    #chef.log_level = :debug
    chef.custom_config_path = "Vagrantfile.chef" 
    chef.data_bags_path = "data_bags"    

    # List of recipes to run
    chef.add_recipe "vagrant-lamp"
    chef.add_recipe "vagrant-lamp::wordpress"
    chef.add_recipe "vagrant-lamp::node"
    chef.add_recipe "vagrant-lamp::sites"
        
  end
  
end
