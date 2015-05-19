Vagrant Berkshelf LAMP
============

LAMP development stack configuration for Vagrant.

Installation:
-------------

Download and install the following:

* [VirtualBox](http://www.virtualbox.org/)
* [vagrant](http://vagrantup.com/)
* [chef-dk](https://downloads.chef.io/chef-dk/)
* [berkshelf](http://berkshelf.com/) 	
	vagrant plugin install vagrant-berkshelf	
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
	vagrant plugin install vagrant-omnibus

Clone this repository

Generate private and public keys and put them in the following location:

* cookbooks/vagrant-lamp/files/id_rsa
* cookbooks/vagrant-lamp/files/id_rsa.pub

Upload your public key to your BitBucket profile (Manage Account > SSH Keys)

Copy the contents of hosts.txt file into your hosts file

Go to the repository folder and launch the box

    $ cd [repo]
    $ vagrant up

Copy the contents of hosts.txt into your /etc/hosts on your host machine

What's inside:
--------------

Installed software:

* Apache 2.2
* MySQL
* PHP 5.3.3
* git, subversion, vim, curl
* [Node](http://nodejs.org/)
* [Composer](http://getcomposer.org/)
* Drupal utils:
    * [Drush](http://drupal.org/project/drush)
* Wordpress utils:
    * [WP-Cli](http://wp-cli.org/)
