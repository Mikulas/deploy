#!/bin/bash

#USER="git"
USER="git"
# POSIX command lookup example
DEPS="ssh git perl"



create_user() {
	echo "creating user $1"
}

ud() {
	sudo -u $USER -H $1 $2 $3 $4 $5 $6 $7 $8 $9
}


for i in $DEPS
do
	# command -v will return >0 when the $i is not found
	command -v $i >/dev/null && continue || {
		echo "$i not found - is this dependency installed?";
		echo "Debian/Ubuntu: apt-get update && apt-get install $i";
		exit 1;
	}
done

if id -u $USER >/dev/null 2>&1; then
	echo "User $USER already exists."
	echo "Would you like to create a different account for your deploy setup?"
	echo "Note that this will effect the repo url: 'account@host:repo'."
else
	echo "User $USER does not exist."
	echo "Would you like to:"
	echo "[1] create it and continue this setup"
	echo "[2] choose a different account for you deploy setup"
	while true; do
		read -p "Please select 1 or 2: " yn
		case $yn in
			[1]* ) create_user $USER; break;;
			[2]* )
				read -p "Enter the desired account name: " USER
				create_user $USER
				break;;
			* ) echo "Invalid option.";;
		esac
	done
fi

# by now $USER now holds a valid username

# TODO check if not empty prompt or die
sudo rm -rf ~$USER/.ssh/authorized_keys

# TODO prompt for PUBLIC key .pub path and copy it to ~$HOME/name.pub

exit 1
ud -i '
	git clone git://github.com/sitaramc/gitolite

	mkdir -p $HOME/bin
	gitolite/install -to $HOME/bin

    $home/bin/gitolite setup -pk YourName.pub
'

#TODO add gitolite to $PATH
