#!/usr/bin/env bash

printf "\n\e[34mInstall git and php5"
sudo apt-get update
sudo apt-get install -y git php5-cli

sudo git config --system receive.denyNonFastForwards true
sudo git config --system receive.denyDeletes true

printf "\n\e[34mCreate git user"
if id -u git >/dev/null 2>&1; then
	echo "User git already exists"
else
	sudo useradd -m -d /home/git -s /bin/bash git
	echo "Done"
fi

mkdir /srv/virtual_hosts
sudo chown -R www-data:git /srv/virtual_hosts
sudo chmod -R 771 /srv/virtual_hosts

sudo mkdir ~git/.ssh
sudo cp /vagrant/keys/alice ~git/.ssh/id_rsa
sudo chown -R git:git ~git
sudo su git -c '/vagrant/provision/git_user.sh'

printf "\n\e[1;34mProvisioning complete\e[0m\n"
printf "\e[1;34mIt is recommended to test VM and git setup with:\n\t\e[33m./test_vm.sh\e[0m\n"
