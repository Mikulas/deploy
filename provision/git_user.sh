#!/usr/bin/env bash

cd ~

chmod 400 ~/.ssh/id_rsa
cp /vagrant/keys/alice.pub ~/.ssh/id_rsa.pub
cp /vagrant/keys/alice.pub ~/Alice.pub

printf "\n\e[34mGitolite setup"
git clone git://github.com/sitaramc/gitolite
mkdir -p ~/bin
gitolite/install -to ~/bin
cat /vagrant/gitolite.rc > ~/.gitolite.rc
~/bin/gitolite setup -pk Alice.pub

git config --global user.name "Deploybot"
git config --global user.email deploybot@localhost

echo "NoHostAuthenticationForLocalhost yes" >> ~/.ssh/config

printf "\n\e[34mDeploy hooks setup"
git clone git@localhost:gitolite-admin
cd gitolite-admin
cat /vagrant/gitolite_append.conf >> conf/gitolite.conf
git add conf/gitolite.conf
git commit -m "add custom update hook via VREF for @all"
git push origin master
cd ~
rm -rf gitolite-admin
