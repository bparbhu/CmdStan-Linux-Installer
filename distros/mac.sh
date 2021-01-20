#!/bin/bash

# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/../scripts/utils.sh

# Import verify_installed_packages.sh to test that all the packages we just installed are working correctly
source $(dirname "$0")/../tests/verify_installed_packages.sh

# Import install_cmdstan.sh for the installCmdStan function
source $(dirname "$0")/../scripts/install_cmdstan.sh

# Tested on:
# Debian 9 
# Ubuntu 16.04
# Ubuntu 18.04

CMDSTAN_INSTALL_DIRECTORY=$1
CMDSTAN_INSTALL_VERSION=$2

verifyPackageInstallation "tar" "which"
verifyPackageInstallation "make" "which"
verifyPackageInstallation "curl" "which"
verifyPackageInstallation "g++" "which"

# Use the installCmdStan function from above imported script and install cmdstan
# It will be installed in the root repository passed
# Example: /tmp as directory and 2.24.1 as version will install cmdstan in /tmp/cmdstan-2.24.1
installCmdStan "$CMDSTAN_INSTALL_DIRECTORY" "$CMDSTAN_INSTALL_VERSION"