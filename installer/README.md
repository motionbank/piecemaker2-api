# Use it local

__Thanks to [Vagrant](http://www.vagrantup.com/) the local usage of the piecemaker API is super easy.__ 

Vagrant is a tool to create and configure lightweight, reproducible, and portable development environments.

## Installation
1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install
1. Download [Vagrant](http://downloads.vagrantup.com) and install
1. ```git clone https://github.com/fjenett/piecemaker2.git``

## Usage
Open your terminal ...

```
# change to installer directory
[~/mattes]$ cd piecemaker2/installer

# start 
[~/mattes/piecemaker2/installer]$ vagrant up
[~/mattes/piecemaker2/installer]$ open http://10.10.55.10

# stop
[~/mattes/piecemaker2/installer]$ vagrant halt

# reload
[~/mattes/piecemaker2/installer]$ vagrant reload
```

## How it works
```vagrant up``` creates a virtual debian machine. It then configures this machine with details coming from
```Vagrantfile``` using [Puppet](https://puppetlabs.com). 

Packages beeing installed:
 * Apache
 * Nodejs
 * MySQL @TODO

 The API is then started as daemon. Have a look at the log files in ```api/logs```.
