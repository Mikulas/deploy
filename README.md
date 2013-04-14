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

Add vagrant and testing hosts ips to your DNS (add following snippet to `/etc/hosts`)
```
192.168.200.200 vagrant
192.168.200.200 testing.l
192.168.200.200 staging.testing.l
```

Test your setup
```
sh test_vm.sh
cd tests
./deploy_test.sh # open browser and open testing.l
./deploy_test.sh # refresh the testing.l tab and see new version
```
