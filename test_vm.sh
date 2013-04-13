#!/bin/bash

printf "\e[1;34mCloning test repo...\e[0m\n"
printf "\e[33mIf you are asked for password, something is not right.\n\e[0m"
DIR=tmp-gitolite-admin
git clone git@vagrant:gitolite-admin $DIR

if [ -d "$DIR" ]; then
	rm -rf $DIR
	printf "\e[1;32mVagrant VM is set up properly and your host machine is configured fine\e[0m\n"
else
	printf "\e[1;31mThere has been an error cloning the gitolite-admin repo.\n"
	printf "\e[1mHave you configured your ssh agent to look for IdentityFile at ./keys?\e[0m\n"
fi
