# Use it local

__Thanks to [Vagrant](http://www.vagrantup.com/) the local usage of the piecemaker API is super easy.__ 

Vagrant is a tool to create and configure lightweight, reproducible, and portable development environments.

## Installation

The installation takes about 20 minutes. 

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Download and install [Vagrant](http://downloads.vagrantup.com)
1. Type the following commands in your terminal ...
  1. ```git clone https://github.com/fjenett/piecemaker2.git```
  1. ```cd piecemaker2 && git submodule init && git submodule update```
  1. ```cd installer && vagrant up && vagrant reload && vagrant halt```

## Usage 
Once you successfully run through the installation steps above, you are able to start and stop 
the virtual machine and use it for your local development and testing.

In ```piecemaker2/installer``` run ...

```
# start virtual machine
$ vagrant up

# stop virtual machine
$ vagrant halt

# update virtual machine
$ git pull && git submodule update && vagrant reload

# delete virtual machine (including mysql databases)
$ vagrant destroy
```

Once the virtual machine is running, open ```http://10.10.55.10``` in your browser. 
The API is listing at ```10.10.55.10:8070```. Please have a look at the log files in ```piecemaker2/api/logs```. 
Changes in ```piecemaker2/api``` will make the API restart.


## Bug #16262 (mysql)
Currently there is a bug in the mysql puppet module. [Bug #16262](http://projects.puppetlabs.com/issues/16262).
After the very first ```vagrant up``` run ```vagrant reload``` and you are fine.

## How it works
```vagrant up``` creates a virtual debian machine and installs packages (see below).
The complete configuration of the virtual machine is done in ```Vagrantfile```.
[Puppet](https://puppetlabs.com) is used as a Provisioner. As soon as the virtual machine
is ready, the actual Piecemaker API is started as a background daemon with [forever](https://github.com/nodejitsu/forever).

Packages being installed:
 * Apache
 * Nodejs
 * MySQL

 
