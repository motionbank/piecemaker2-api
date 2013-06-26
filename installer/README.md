# Use it local

__Thanks to [Vagrant](http://www.vagrantup.com/) the local usage of the piecemaker API is super easy.__ 

Vagrant is a tool to create and configure lightweight, reproducible, and portable development environments.

## Installation (do this once)
1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install
1. Download [Vagrant](http://downloads.vagrantup.com) and install
1. ```git clone https://github.com/fjenett/piecemaker2.git```
1. ```cd piecemaker2 && git submodule init```

## Usage 
Open your terminal ...

```
[~/mattes]$ cd piecemaker2/installer
[~/mattes]$ git pull # optional ;-)

[~/mattes/piecemaker2/installer]$ vagrant up
[~/mattes/piecemaker2/installer]$ open http://10.10.55.10
```

Use ```vagrant halt``` to stop the machine and ```vagrant reload``` to reload it.


## How it works
```vagrant up``` creates a virtual debian machine and installs packages (see below).
The complete configuration of the virtual machine is done in ```Vagrantfile```.
[Puppet](https://puppetlabs.com) is used as a Provisioner. As soon as the virtual machine
is ready, the actual Piecemaker API is started as a background daemon with [forever](https://github.com/nodejitsu/forever).

Please have a look at log files in ```piecemaker2/api/logs```. 

Changes in ```piecemaker2/api``` will make the API restart.

Packages being installed:
 * Apache
 * Nodejs
 * MySQL

 
