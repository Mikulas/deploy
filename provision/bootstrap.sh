#!/usr/bin/env bash

printf "\n\e[34mInstall git, php5 and apache2"
sudo apt-get update
sudo apt-get install -y git php5-cli apache2

sudo git config --system receive.denyNonFastForwards true
sudo git config --system receive.denyDeletes true

printf "\n\e[34mCreate git user"
if id -u git >/dev/null 2>&1; then
	echo "User git already exists"
else
	sudo useradd -m -d /home/git -s /bin/bash git
	echo "Done"
fi

#sudo su -c 'echo "127.0.0.1 testing.l" >> /etc/hosts'
#sudo su -c 'echo "127.0.0.1 staging.testing.l" >> /etc/hosts'
sudo cp /vagrant/provision/config/apache-testing /etc/apache2/conf.d/virtual.conf
sudo rm -rf /etc/apache2/sites-enabled/000-default
sudo /etc/init.d/apache2 restart

sudo chown -R www-data:git /var/www
sudo chmod -R 771 /var/www

sudo mkdir ~git/.ssh
sudo cp /vagrant/keys/alice ~git/.ssh/id_rsa
sudo chown -R git:git ~git
sudo su git -c '/vagrant/provision/git_user.sh'

printf "\n\e[1;34mProvisioning complete\e[0m\n"
printf "\e[1;34mIt is recommended to test VM and git setup with:\n\t\e[33m./test_vm.sh\e[0m\n"
