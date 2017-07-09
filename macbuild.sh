#!/bin/bash

# Colours
BOLD='\033[1m'
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
ENDC='\033[0m'

# Display a pretty header
echo
echo -e "${BOLD}Mac Build (using Ansible)${ENDC}"
echo

# Prompt the user for their sudo password
sudo -v

# Enable passwordless sudo for the macbuild run
sudo sed -i -e "s/^%admin.*/%admin  ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

# Install xcode
echo -e "${BLUE}Installing xcode${ENDC}"

# See http://apple.stackexchange.com/questions/107307/how-can-i-install-the-command-line-tools-completely-from-the-command-line

echo "Checking Xcode CLI tools"
# Only run if the tools are not installed yet
# To check that try to print the SDK path
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "Xcode CLI tools not found. Installing them..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    head -n 1 | awk -F"*" '{print $2}' |
    sed -e 's/^ *//' |
    tr -d '\n')
  softwareupdate -i "$PROD" -v;
else
  echo "Xcode CLI tools OK"
fi

# Install Pip
echo -e "${BLUE}Installing Pip${ENDC}"
sudo easy_install pip

# Install Ansible
echo -e "${BLUE}Installing Ansible${ENDC}"
sudo pip install ansible

cd ~/src/

echo -e "${BLUE}Cloing Git${ENDC}"
git clone https://github.com/scottnasello/mac-dev-playbook.git

cd mac-dev-playbook

echo -e "${BLUE}Installing Ansible requirements${ENDC}"
ansible-galaxy install -r requirements.yml

#ansible-playbook -i inventory --ask-become-pass main.yml

# Disable passwordless sudo after the macbuild is complete
sudo sed -i -e "s/^%admin.*/%admin  ALL=(ALL) ALL/" /etc/sudoers
