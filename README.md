Vagrant Berkshelf LAMP
============

My default LAMP development stack configuration for Vagrant.

Initially ported cookbooks and all from https://github.com/r8/vagrant-lamp so credit is due regarding the vagrant-main cookbook.  

Now with added Berkshelf and stripped back of everything I don't personally use.

Installation:
-------------

Download and install the following:

* [VirtualBox](http://www.virtualbox.org/)
* [vagrant](http://vagrantup.com/)
* [berkshelf](http://berkshelf.com/)
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)

Clone this repository

Go to the repository folder and launch the box

    $ cd [repo]
    $ vagrant up

What's inside:
--------------

Installed software:

* Apache
* MySQL
* php
* git, subversion
* phpMyAdmin
* vim, curl
* [Composer](http://getcomposer.org/)
* Phing
* Drupal utils:
    * [Drush](http://drupal.org/project/drush)
* Wordpress utils:
    * [WP-Cli](http://wp-cli.org/)

Notes
-----

### Apache virtual hosts

You can add virtual hosts to apache by adding a file to the `data_bags/sites`
directory. The docroot of the new virtual host will be a directory within the
`public/` folder matching the `host` you specified. Alternately you may specify
a docroot explicitly by adding a `docroot` key in the json file.

### MySQL

The guests local 3306 port is available on the host at port 33066. It is also available on every domain. Logging in can be done with username=root, password=vagrant.

### phpMyAdmin

phpMyAdmin is available on every domain. For example:

    http://local.dev/phpmyadmin

### XDebug

XDebug is configured to connect back to your host machine on port 9000 when 
starting a debug session from a browser running on your host. A debug session is 
started by appending GET variable XDEBUG_SESSION_START to the URL (if you use an 
integrated debugger like Eclipse PDT, it will do this for you).

XDebug is also configured to generate cachegrind profile output on demand by 
adding GET variable XDEBUG_PROFILE to your URL. For example:

    http://local.dev/index.php?XDEBUG_PROFILE

### Composer

Composer binary is installed globally (to `/usr/local/bin`), so you can simply call `composer` from any directory.
