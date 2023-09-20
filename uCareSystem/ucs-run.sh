#!/bin/bash

set -e

	echo "########################################################"
	echo "#                                                      #"
	echo "#                      uCareSystem                     #"
    echo "#                                                      #"
	echo "########################################################"
	echo "#                                                      #"
	echo "# Welcome to all-in-one System Update and maintenance  #"
	echo "# assistant app.                                       #"
	echo "#                                                      #"
	echo "#                                                      #"
	echo "# This simple script will automatically                #"
	echo "# refresh your packagelist, download and               #"
	echo "# install updates (if there are any), remove any old   #"
	echo "# kernels, obsolete packages and configuration files   #"
	echo "# to free up disk space, without any need of user      #"
	echo "# interference                                         #" 
	echo "#                                                      #"
	echo "# If you’ve found it useful and saved you time and you #"
	echo "# think it is worth of your support, you can make a    #"
	echo "# donation via PayPal by clicking on the following:    #"
	echo "#                                                      #"
	echo "#         https://www.paypal.me/MaksymTitenko          #"
    echo "#                                                      #"	
    echo "########################################################"
	echo
	echo " uCareSystem will start in 5 seconds... "

	sleep 6

    echo
    echo "########################################################"
    echo "                      Started                           "
    echo "########################################################"
    echo
    sleep 2

    echo " uCareSystem starts working... "

# Function to print section headers
print_section_header() {
    echo
    echo "########################################################"
    echo " $1 "
    echo "########################################################"
    echo
    sleep 2
}



# Update package lists
print_section_header "Updating package lists"
sudo apt update

# Upgrade packages and libraries
print_section_header "Upgrading packages and system libraries"
sudo apt full-upgrade -y

# Remove unneeded packages
print_section_header "Removing unneeded packages"
sudo apt autoremove --purge -y

# Remove old kernels
print_section_header "Removing old kernels"
KEEP=2
APT_OPTS=
while [ ! -z "$1" ]; do
    case "$1" in
        --keep)
            KEEP="$2"
            shift 2
        ;;
        *)
            APT_OPTS="$APT_OPTS $1"
            shift 1
        ;;
    esac
done

# Build list of kernel packages to purge
CANDIDATES=$(ls -tr /boot/vmlinuz-* | head -n -${KEEP} | grep -v "$(uname -r)$" | cut -d- -f2- | awk '{print "linux-image-" $0 " linux-headers-" $0}' )
PURGE=""
for c in $CANDIDATES; do
    dpkg-query -s "$c" >/dev/null 2>&1 && PURGE="$PURGE $c"
done

if [ -z "$PURGE" ]; then
    echo "No kernels are eligible for removal"
else
    sudo apt $APT_OPTS remove -y --purge $PURGE
fi


# Remove unused config files
print_section_header "Removing unused config files"

# Function to check if a package is installed
check_package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Check if deborphan is installed, and if not, install it
if ! check_package_installed "deborphan"; then
    echo "deborphan is not installed. Installing..."
    sudo apt install deborphan -y
    echo "deborphan has been installed."
fi

sudo deborphan -n --find-config | xargs sudo apt-get -y --purge autoremove

# Clean downloaded temporary packages
print_section_header "Cleaning downloaded temporary packages"
sudo apt autoclean -y
sudo apt clean -y

# Update flatpak apps
print_section_header "Updating flatpak apps"
flatpak update

echo
echo "########################################################"
echo "           Finished cleaning and optimization           "
echo "########################################################"
echo
sleep 2

echo " uCareSystem is shutting down... "
echo " The terminal will close automatically after 5 seconds "
sleep 6
