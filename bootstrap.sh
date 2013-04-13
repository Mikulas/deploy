#!/usr/bin/env bash

printf "\e[34mInstall git"
sudo apt-get update
sudo apt-get install -y git

printf "\n\e[34mCreate git user"
if id -u git >/dev/null 2>&1; then
	echo "User git already exists"
else
	sudo useradd -m -d /home/git -s /bin/bash git
fi

printf "\n\e[34mGitolite setup"
sudo su git -c '
cd ~
cp /vagrant/keys/alice.pub ~/Alice.pub
git clone git://github.com/sitaramc/gitolite
mkdir -p ~/bin
gitolite/install -to ~/bin
~/bin/gitolite setup -pk Alice.pub

git config --global user.name "Deploybot"

git clone git@localhost:gitolite-admin
cd gitolite-admin
echo "\nrepo @all\n    -    VREF/deploy_hook  =   @all\n" >> conf/gitolite.conf
git commit -am "add deploy hook VREF for @all"
git push origin master
cd ~
rm -rf gitolite-admin

cp /vagrant/hooks/deploy_hook ~/repositories/testing.git/hooks/deploy_hook
'

printf "\n\e[1;34mProvisioning complete\e[0m\n"
printf "\e[1;34mAfter the VM has booted it is recommended to test it with:\n\t\e[33msh test_vm.sh\e[0m\n"

