#!/usr/bin/env bash

cd ~

mkdir .ssh
cp /vagrant/keys/alice ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
cp /vagrant/keys/alice.pub ~/.ssh/id_rsa.pub
cp /vagrant/keys/alice.pub ~/Alice.pub

printf "\n\e[34mGitolite setup"
git clone git://github.com/sitaramc/gitolite
mkdir -p ~/bin
gitolite/install -to ~/bin
~/bin/gitolite setup -pk Alice.pub

git config --global user.name "Deploybot"
git config --global user.name

printf "\n\e[34mDeploy hooks setup"
git clone git@localhost:gitolite-admin
cd gitolite-admin
cat gitolite_append.conf >> conf/gitolite.conf
git commit -am "add deploy hook VREF for @all"
git push origin master
cd ~
rm -rf gitolite-admin

cp /vagrant/hooks/deploy_hook ~/.gitolite/hooks/common/deploy_hook
~/bin/gitolite setup --hooks-only
