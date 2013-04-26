#!/bin/bash

vagrant destroy -f
vagrant up

vagrant ssh -c 'sudo apt-get update && sudo apt-get install git -y'

# prompt user to upload his PUBLIC key to server
vagrant ssh
#/vagrant/install_deploy.sh
