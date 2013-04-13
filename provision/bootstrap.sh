#!/usr/bin/env bash

printf "\e[34mInstall git"
#sudo apt-get update
sudo apt-get install -y git

printf "\n\e[34mCreate git user"
if id -u git >/dev/null 2>&1; then
	echo "User git already exists"
else
	sudo useradd -m -d /home/git -s /bin/bash git
	echo "Done"
fi

sudo su git -c '/vagrant/provision/git_user.sh'

printf "\n\e[1;34mProvisioning complete\e[0m\n"
printf "\e[1;34mIt is recommended to test VM and git setup with:\n\t\e[33msh test_vm.sh\e[0m\n"
