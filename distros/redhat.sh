#!/bin/bash

# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/../scripts/utils.sh

# Import verify_installed_packages.sh to test that all the packages we just installed are working correctly
source $(dirname "$0")/../tests/verify_installed_packages.sh

# Import install_cmdstan.sh for the installCmdStan function
source $(dirname "$0")/../scripts/install_cmdstan.sh

# Tested on:
# CentOS 7
# CentOS 8
# RedHat 7
# RedHat 8

CMDSTAN_INSTALL_DIRECTORY=$1
CMDSTAN_INSTALL_VERSION=$2

# Represents CentOS Major version. Ex: 7
RHEL_MAJOR_VERSION=`rpm -E %{rhel}`
PLATFORM=""

# Set our PLATFORM to either redhat or centos
QUERY_CENTOS_RELEASE=`rpm --query centos-release`
if [[ $QUERY_CENTOS_RELEASE =~ "not installed" ]]; then
    PLATFORM="redhat"
else
    PLATFORM="centos"
fi

function installYumPackage {
    PACKAGE_NAME=$1
    PACKAGE_INSTALLED=`rpm -qa | grep $PACKAGE_NAME`

    if [ -z "$PACKAGE_INSTALLED" ]
    then
        echo "Installing $PACKAGE_NAME now ..."
          
        if [[ $PACKAGE_NAME =~ "devtoolset" ]]
        then
            if [ "$PLATFORM" == "centos" ]; then
                # On CentOS, install package centos-release-scl available in CentOS repository
                sudo yum install centos-release-scl -y
            else
                # On RHEL, enable RHSCL repository for you system
                sudo yum-config-manager --enable rhel-server-rhscl-7-rpms
            fi

            # Check if adding repository was successful
            checkReturnCode "$?" "Adding repository for devtoolset failed"

            # Install the collection
            sudo yum install $PACKAGE_NAME -y

            # Check if installing the package was successful
            checkReturnCode "$?" "Yum installation failed"

            # Set CXX variable to point to the devtoolset g++
            echo "export CXX=/opt/rh/$PACKAGE_NAME/root/usr/bin/g++" >> ~/.bashrc
            source ~/.bashrc

            if test -f "/usr/local/bin/g++"; then
                echo "g++ already exists, creating a backup file and adding new g++ from devtools"
                sudo mv /usr/local/bin/g++ /usr/local/bin/g++-old
                # Since we're not relying on the yum version of g++ because it's outdated, more precisely 4.8.5
                # We need create a symlink for g++ to the g++ from devtoolset
                sudo ln -s /opt/rh/devtoolset-7/root/usr/bin/g++ /usr/local/bin/g++

                # Check if creating the symlink was successful
                checkReturnCode "$?" "Creating a symlink failed 'ln -s /opt/rh/devtoolset-7/root/usr/bin/g++ /usr/local/bin/g++'"
            else
                echo "'hello' was not build successfully using 'g++ -o hello hello.cpp' !"
                echo "Please check your 'g++' installation and make sure there are no permission issues around it!"
                exit 1
            fi

            echo "CXX variable has been set to the devtools version of g++ because the base version in yum repository is 4.8.5 and NOT compatible with cmdstan."
            echo "A symlink pointing g++ to g++ from the devtoolset has been created in /usr/local/bin."
            echo "You can use 'scl enable devtoolset-7 bash' to have all devtools available to you in the shell not just g++."
        else
            # Install package with yum
            sudo yum install $PACKAGE_NAME -y

            # Check if installing the package was successful
            checkReturnCode "$?" "Yum installation failed"

            # Verify if package is behaving normally
            verifyPackageInstallation "$PACKAGE_NAME" "rpm"
        fi

        echo "$PACKAGE_NAME has been installed"
    else
        echo "Package $PACKAGE_NAME is already installed!"
    fi           
}

function installDnfGroup {
    GROUP_NAME=$1
    GROUP_INSTALLED=`dnf group list --installed | grep "$GROUP_NAME"`

    if [ -z "$GROUP_INSTALLED" ]
    then
        echo "Installing DNF Group $GROUP_NAME now ..."

        # Install DNF Group
        sudo dnf group install "$GROUP_NAME" -y

        # Verify if dnf group install was successful
        checkReturnCode "$?" "DNF Group ($GROUP_NAME) installation failed"

        # Install/Update man-pages for DNF Groups
        sudo dnf install man-pages -y
        
        # Verify if dnf group install was successful
        checkReturnCode "$?" "DNF Group (man-pages) installation failed"

        echo "DNF Group $GROUP_NAME has been installed"
    else
        echo "DNF Group $GROUP_NAME is already installed!"
    fi 
}

# Setting up os packages requirements
installYumPackage "curl"
installYumPackage "tar"
installYumPackage "make"

# Setting up toolchain dependencies
if [ "$RHEL_MAJOR_VERSION" == "7" ]; then
    installYumPackage "devtoolset-7"
elif [ "$RHEL_MAJOR_VERSION" == "8" ]; then
    installDnfGroup "Development Tools"
else
    echo "RHEL Major Version $RHEL_MAJOR_VERSION not supported in this installation script!"
fi

# We're verifying g++ after devtoolset installation
verifyPackageInstallation "g++" "which"

# Import install_cmdstan.sh for the installCmdStan function
source install_cmdstan.sh

# Use the installCmdStan function from above imported script and install cmdstan
# It will be installed in the root repository passed
# Example: /tmp as directory and 2.24.1 as version will install cmdstan in /tmp/cmdstan-2.24.1
installCmdStan "$CMDSTAN_INSTALL_DIRECTORY" "$CMDSTAN_INSTALL_VERSION"