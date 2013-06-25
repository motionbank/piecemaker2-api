# Use it local

__Thanks to [Vagrant](http://www.vagrantup.com/) the local usage of the piecemaker API is super easy.__ 

Vagrant is a tool to create and configure lightweight, reproducible, and portable development environments.

## Installation
1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install
1. Download [Vagrant](http://downloads.vagrantup.com) and install

## Usage
Open your terminal ...

1. ```cd /to/directory``` where the Vagrantfile is saved
1. Run ```vagrant up```
1. Wait ... until ready
1. You are now able to connect to the piecemaker API under 10.10.55.10
1. Stop virtual machine with ```vagrant halt```

## Update
Do steps from 'Usage' again or open your terminal if the virtual machine is still running ...

1. ```cd /to/directory``` where the Vagrantfile is saved
1. Type ```vagrant ssh``` to connect to the virtual machine with SSH
1. To update, type ```cd piecemaker2 && git pull```
