#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it first."
    exit 1
fi

# Check if gpg is installed
if ! command -v gpg &> /dev/null; then
    echo "Error: gpg is not installed. Please install it first."
    exit 1
fi

# Determine the codename of the Ubuntu release
ubuntu_codename=$(grep -oP 'UBUNTU_CODENAME=\K\w+' /etc/os-release 2>/dev/null)

# If the codename is not found, exit with an error
if [ -z "$ubuntu_codename" ]; then
    echo "Error: Unable to determine Ubuntu codename from /etc/os-release."
    exit 1
fi

# Prompt the user to enter the PPA in the format ppa:username/repository
read -p "Enter the PPA name (in the format ppa:username/repository): " ppa_input

# Validate the entered format
if [[ ! "$ppa_input" =~ ^ppa:[a-z0-9-]+/[a-z0-9-]+$ ]]; then
    echo "Error: Invalid PPA format. Example: ppa:username/repository"
    exit 1
fi

# Extract username and repository from the input
username=$(echo "$ppa_input" | cut -d ":" -f2 | cut -d "/" -f1)
repository=$(echo "$ppa_input" | cut -d ":" -f2 | cut -d "/" -f2)

# PPA URL
ppa_url="https://api.launchpad.net/devel/~$username/+archive/ubuntu/$repository"

# Get the key from the specified URL
key_url=$(curl -s "$ppa_url" | grep -oP '(?<=fingerprint": ")[^"]+')

# If the key is not found, exit
if [ -z "$key_url" ]; then
    echo "Error: Unable to extract key from the PPA."
    exit 1
fi

# Import the key into the system
gpg --keyserver keyserver.ubuntu.com --recv-keys "$key_url"

# Create the /etc/apt/keyrings/ directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Export and save the key to a file
gpg --export --armor "$key_url" | sudo gpg --dearmor -o "/etc/apt/keyrings/$repository.gpg"

# Create the repository file in the /etc/apt/sources.list.d/ directory
repo_file="/etc/apt/sources.list.d/$repository.list"
sudo mkdir -p $(dirname "$repo_file")
echo "deb [signed-by=/etc/apt/keyrings/$repository.gpg arch=amd64] https://ppa.launchpadcontent.net/$username/$repository/ubuntu $ubuntu_codename main" | sudo tee "$repo_file" > /dev/null

# Update the package list
sudo apt-get update

echo "PPA $repository added successfully!"

