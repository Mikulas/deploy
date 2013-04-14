#!/usr/bin/env bash

cd ~

chmod 400 ~/.ssh/id_rsa
cp /vagrant/keys/alice.pub ~/.ssh/id_rsa.pub
cp /vagrant/keys/alice.pub ~/Alice.pub


printf "\n\e[34mGitolite setup"
git clone git://github.com/sitaramc/gitolite
mkdir -p ~/bin
gitolite/install -to ~/bin
cat /vagrant/provision/config/gitolite.rc > ~/.gitolite.rc
~/bin/gitolite setup -pk Alice.pub

git config --global user.name "Deploybot"
git config --global user.email deploybot@localhost

echo "NoHostAuthenticationForLocalhost yes" >> ~/.ssh/config


printf "\n\e[34mDeploy hooks setup"
git clone git@localhost:gitolite-admin
cd gitolite-admin

cat /vagrant/provision/config/gitolite_append.conf >> conf/gitolite.conf
git add conf/gitolite.conf
chmod ugo+r conf/gitolite.conf
git commit -m "add custom update hook via VREF for @all"
git push origin master

cd ..
rm -rf gitolite-admin


printf "\n\e[34mSetup testing repo"
git clone git@localhost:testing
cd testing
cat /vagrant/provision/config/deploy.json > deploy.json
chmod 644 deploy.json
git add deploy.json
git commit -m "add deploy configuration"
git push origin master
cd ..
rm -rf testing
