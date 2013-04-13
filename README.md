Prereqs
-------

Install Vagrant http://www.vagrantup.com/ (and VirtualBox)

Setup
-----

Setup and run the virtual machine
```
vagrant up
```

Add the following snippet to yours ~/.ssh/config

```
Host 192.168.240.240
	IdentityFile /Volumes/Cifrita/Projects/deploy/keys/alice
```

Test your setup
```
sh test_vm.sh
```
