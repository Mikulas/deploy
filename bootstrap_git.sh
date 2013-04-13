#!/usr/bin/env bash

cd ~

printf "\n\e[34mGitolite setup"
whoami
pwd
cp /vagrant/keys/id_rsa.pub ~/Alice.pub
git clone git://github.com/sitaramc/gitolite
mkdir -p ~/bin
gitolite/install -to ~/bin
~/bin/gitolite setup -pk Alice.pub
