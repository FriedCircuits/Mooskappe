#!/bin/bash
#
#This script updates the git repo for Mooskappe and then calls the installer script
#
#Authors: Geno N.
#
#Dependencies: bash git


installdir=$(dirname $(readlink -f $0))

#Check if this is a new install or update
echo "$(tput setaf 2)=====================$(tput sgr 0)"
if [ -d "Mooskappe" -o -d "../Mooskappe" ]; then
	echo "Previous installation detected! Updating sources..."
        cd Mooskappe &> /dev/null
        git fetch
        git reset --hard origin/master
else 
	echo "Installing Mooskappe..."
        git clone "https://github.com/FriedCircuits/Mooskappe.git" 
        cd Mooskappe &> /dev/null
fi
sudo ./mooskappe_install.sh
