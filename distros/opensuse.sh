#!/bin/bash

# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/../scripts/utils.sh

# Import verify_installed_packages.sh to test that all the packages we just installed are working correctly
source $(dirname "$0")/../tests/verify_installed_packages.sh

# Import install_cmdstan.sh for the installCmdStan function
source $(dirname "$0")/../scripts/install_cmdstan.sh

# Tested on:
# OpenSuse Leap 15.2

CMDSTAN_INSTALL_DIRECTORY=$1
CMDSTAN_INSTALL_VERSION=$2

function installZypperPackage {
    PACKAGE_NAME=$1
    PACKAGE_INSTALLED=`rpm -qa $PACKAGE_NAME`

    if [ -z "$PACKAGE_INSTALLED" ]
    then
        echo "Installing $PACKAGE_NAME with zypper now ..."

        # Install package using zypper
        sudo zypper -n install -y $PACKAGE_NAME

        # Check if installing the package was successful
        checkReturnCode "$?" "Zypper installation failed"
    else
        echo "$PACKAGE_NAME already installed!"
    fi
}

# Update local repositories
sudo zypper refresh

# Check if refreshing the repositories failed
checkReturnCode "$?" "Zypper refresh failed"

# Setting up os packages requirements
installZypperPackage "curl"
verifyPackageInstallation "curl" "rpm"

installZypperPackage "tar"
verifyPackageInstallation "tar" "rpm"

installZypperPackage "make"
verifyPackageInstallation "make" "rpm"

installZypperPackage "gcc-c++"
verifyPackageInstallation "g++" "which"

# Use the installCmdStan function from above imported script and install cmdstan
# It will be installed in the root repository passed
# Example: /tmp as directory and 2.24.1 as version will install cmdstan in /tmp/cmdstan-2.24.1
installCmdStan "$CMDSTAN_INSTALL_DIRECTORY" "$CMDSTAN_INSTALL_VERSION"