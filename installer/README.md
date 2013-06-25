# Use it local

__Thanks to [Vagrant](http://www.vagrantup.com/) the local usage of the piecemaker API is super easy.__ 

Vagrant is a tool to create and configure lightweight, reproducible, and portable development environments.

## Installation (do this once)
1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install
1. Download [Vagrant](http://downloads.vagrantup.com) and install
1. ```git clone https://github.com/fjenett/piecemaker2.git``

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
```vagrant up``` creates a virtual debian machine. It then configures this machine 
with details coming from ```Vagrantfile``` using [Puppet](https://puppetlabs.com). 
The API is then started as daemon. Have a look at the log files in ```api/logs```.

Packages being installed:
 * Apache
 * Nodejs
 * MySQL tdb

 
