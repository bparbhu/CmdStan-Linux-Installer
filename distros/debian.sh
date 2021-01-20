#!/bin/bash

# Import verify_installed_packages.sh to test that all the packages we just installed are working correctly
source $(dirname "$0")/../tests/verify_installed_packages.sh

# Import install_cmdstan.sh for the installCmdStan function
source $(dirname "$0")/../scripts/install_cmdstan.sh

# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/../scripts/utils.sh

# Tested on:
# Debian 9 
# Ubuntu 16.04
# Ubuntu 18.04

CMDSTAN_INSTALL_DIRECTORY=$1
CMDSTAN_INSTALL_VERSION=$2

function installAptPackage {
    PACKAGE_NAME=$1
    PACKAGE_INSTALLED=`which $PACKAGE_NAME`

    if [ -z "$PACKAGE_INSTALLED" ]
    then
      echo "Installing $PACKAGE_NAME from apt repository now ..."
      # Install package using apt
      sudo apt-get install $PACKAGE_NAME -y
      
      # Check if installing the package was successful
      checkReturnCode "$?" "Apt installation failed" 
    else
      echo "$PACKAGE_NAME already installed!"
    fi

    # Verify if package is behaving normally
    verifyPackageInstallation "$PACKAGE_NAME" "which"
}

# Update local repositories
sudo apt-get update -y

# Check if updating the apt repositories was successful
checkReturnCode "$?" "Apt update failed"

# Setting up os packages requirements
installAptPackage "curl"
installAptPackage "tar"
installAptPackage "make"
installAptPackage "g++"

# Use the installCmdStan function from above imported script and install cmdstan
# It will be installed in the root repository passed
# Example: /tmp as directory and 2.24.1 as version will install cmdstan in /tmp/cmdstan-2.24.1
installCmdStan "$CMDSTAN_INSTALL_DIRECTORY" "$CMDSTAN_INSTALL_VERSION"