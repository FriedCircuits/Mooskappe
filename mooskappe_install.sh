#!/bin/bash
#
#
#
#Dependencies: cron

#Check if root
if [ $(id -u) != 0 ] ; then
        echo "$(tput setaf 1)Error please run as root (use sudo). $(tput sgr 0)"; exit 7
fi

#Begin Install
echo "$(tput setaf 2)=====================$(tput sgr 0)"
echo "Mooskappe Installer v1.0 - FriedCircuits.us"
echo "Install script by William G. and Geno N."
echo "$(tput setaf 2)=====================$(tput sgr 0)"

echo "Configuring system..."
installdir=$(dirname $(readlink -f $0))
if [ -e /etc/init.d/mooskappe.sh ] && [ -e $installdir/config.py ]; then
    upgrade=1
else
    upgrade=0
fi


#Checking if the modules are to be automatically loaded at boot
if [ $upgrade -eq 0 ]; then
    echo "Setting up I2C"
    if [ ! $(grep "i2c-bcm2708" /etc/modules) ]; then
        echo 'i2c-bcm2708' >> /etc/modules
    fi
    if [ ! $(grep "i2c-dev" /etc/modules) ]; then
        echo 'i2c-dev' >> /etc/modules
    fi
fi

#Load the necessary modules
#(This does nothing if the modules are already loaded)
modprobe -a i2c-bcm2708 i2c-dev

#Install dependencies
if [ $upgrade -eq 0 ]; then
    echo "$(tput setaf 2)=====================$(tput sgr 0)"
    echo "Installing needed packages...python-smbus i2c-tools python-dev python-rpi.gpio"
    apt-get -y install python-smbus i2c-tools python-dev python-rpi.gpio &> /dev/null
    echo "$(tput setaf 2)=====================$(tput sgr 0)"
fi

#Try to detect a Mooskappe connection
echo "Testing I2C - Making sure address 0x20 is available"
i2cdetect -y 1 > /tmp/i2c.tmp
if [[ ! $(grep " 20 " /tmp/i2c.tmp) ]]; then
    echo "$(tput setaf 1)Mooskappe not detected! Check your connections with the Mooskappe.$(tput sgr 0)"
    exit 6
else
    echo "Address 0x20 is available"
fi

#This will reset the ownership to the user that called sudo to run this script
chown -R $(logname).$(id -gn $(logname)) $installdir &> /dev/null

#Check where test python is to test LCD - skip on updates
if [ $upgrade -eq 0 ]; then
    echo "$(tput setaf 2)=====================$(tput sgr 0)"
    echo "Mooskappe test running, check LCD display"
    if [ -f $installdir/"mooskappe_test.py" ]; then
        python $installdir/"mooskappe_test.py"
    fi
fi
#Add init service to start the PiMiner software at boot time
echo "$(tput setaf 2)=====================$(tput sgr 0)"
echo "Adding init service to run Mooskappe on boot"
safedir=$(echo $installdir|sed -e 's/\//\\\//g')
sed -i 's/DIR=.*/DIR='$safedir'/g' $installdir/service.sh
sed -i 's/DAEMON=.*/DAEMON=\$DIR\/PiMiner.py/g' $installdir/service.sh
sed -i 's/DAEMON_NAME=.*/DAEMON_NAME=Mooskappe/g' $installdir/service.sh
cp -f $installdir/service.sh /etc/init.d/mooskappe.sh
chmod +x /etc/init.d/mooskappe.sh

#Add script to inittab to automatically restart the service if it fails
if [[ $(grep "Mooskappe" /etc/inittab) ]]; then
    echo "
#Spawn the Mooskappe service
M0:2345:respawn:/etc/init.d/mooskappe.sh" >> /etc/inittab
fi

if [ $upgrade -eq 1 ]; then
    echo -n "Setup detected this is an upgrade. Do you wish to overwrite your current configs? (y/N) "
    read overwrite
    if [ ! -z $overwrite ] && ([ $overwrite == "Yes" ] || [ $overwrite == "Y" ] || [ $overwrite == "yes" ] || [ $overwrite == "y" ]); then
        overwrite=1
        #Move config.py.example to config.py
        mv $installdir/config.py.example $installdir/config.py
    else
        overwrite=0
    fi
else
    overwrite=0
    cp $installdir/config.py.example $installdir/config.py
fi

    if [ $overwrite -eq 1 ] || [ $upgrade -eq 0 ]; then
    #Setup email notifications
        echo "$(tput setaf 2)=====================$(tput sgr 0)"
        echo -n "Would you like to configure email notifications? (Y/n) "
        read enote
        if [ -z $enote ] || [ $enote == "Yes" ] || [ $enote == "Y" ] || [ $enote == "yes" ] || [ $enote == "y" ]; then
            sed -i 's/ALERT_ENABLED.*/ALERT_ENABLED\ =\ 1/g' config.py
            echo -n "Enter the gmail address would you like notifications to be sent *from*: "
            read fromgmail
            echo -n "Enter the password for the gmail account: "
            read -s gpass
            echo ' '
            echo -n "Enter the gmail address would you like notifications to be sent *to*: "
            read togmail

    #Configure the config.py file for the entered user/pass/address
            if [ ! -z $fromgmail ] && [ ! -z $gpass ] && [ ! -z $togmail ]; then
                sed -i 's/GMAIL_USER.*/GMAIL_USER\ =\ \"'$fromgmail'\"/g' $installdir/config.py
                sed -i 's/GMAIL_PASS.*/GMAIL_PASS\ =\ \"'$gpass'\"/g' $installdir/config.py
                sed -i 's/RECIPIENT.*/RECIPIENT\ =\ \[\"'$togmail'\"\]/g' $installdir/config.py
            else
                echo "Failed to edit the config.py.example file! Please try again."
                exit 5
            fi
        else
            echo "Email alerts are disabled."
            sed -i 's/ALERT_ENABLED.*/ALERT_ENABLED\ =\ 0/g' $installdir/config.py
        fi
    fi

#Detect and enable temperature sensor if one present
#NOTE: Only works for one sensor right now
if [ $overwrite -eq 1 ];then
    echo "$(tput setaf 2)=====================$(tput sgr 0)"
    echo "Detecting Temperature Sensor (DS18B20)..."
    modprobe -a w1-gpio w1-therm
    if [[ ! $(ls /sys/bus/w1/devices/ | grep 28-* ) ]]; then
        echo "No temperature sensor (DS18B20) found..."
        echo "If you add one later, be sure to change TEMP_ENABLED to 1 in config.py"
    else
        echo "Temperature sensor (DS18B20) found. Adding capability."
        sed -i 's/TEMP_ENABLED.*/TEMP_ENABLED\ =\ 1/g' $installdir/config.py
    fi
fi

echo "$(tput setaf 2)=====================$(tput sgr 0)"
echo "Installation Completed!"
echo "Use sudo ./PiMiner.py to run manually"
echo -n "Would you like to start Mooskappe now? (Y/n) "
read startmoos
if [ -z $startmoos ] || [ $startmoos = "Yes" ] || [ $startmoos = "Y" ] || [ $startmoos = "yes" ] || [ $startmoos = "y" ]; then
    if [ -f $installdir/"PiMiner.py" ]; then
        python $installdir/PiMiner.py &
    fi
fi

echo "$(tput setaf 2)=====================$(tput sgr 0)"

#End Cleanup
echo "$(tput sgr 0)"
