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
Host vagrant
	IdentityFile /Volumes/Cifrita/Projects/deploy/keys/alice
```

Add vagrant ip to your DNS
```
echo "192.168.200.200 vagrant" >> /etc/hosts
```

Test your setup
```
sh test_vm.sh
```
