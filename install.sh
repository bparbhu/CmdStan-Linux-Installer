#!/bin/bash

HELP_TXT=$(cat <<-END
### HELP

# Example script call: install.sh
# Example script call: install.sh -d debian
# Example script call: install.sh -p /home/user -d debian
# Example script call: install.sh -p /home/user -d debian -v 2.24.1

### Root directory where to install cmdstan
# Argument -d: Root directory where to install cmdstan, /tmp will have cmdstan installed in /tmp/cmdstan-2.24.1
# Default: $HOME ( home directory of the user )

### Version of cmdstan release to install
# Argument -v: Version of cmdstan to instal, example 2.24.1
# Default: latest ( latest release in github )

### Distribution
# Argument -d: linux distro. Possible values, one of: [debian, mac, opensuse, redhat] 
# Required: Yes 
END
)

# How it works
# `$0` returns relative or absolute path to the executed script
# `dirname` returns relative path to directory, where the $0 script exists
# `$( dirname "$0" )` the `dirname "$0"` command returns relative path to directory of executed script, which is then used as argument for `source` command
# in "second.sh", `/first.sh` just appends the name of imported shell script
# `source` loads content of specified file into current shell
# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/scripts/utils.sh

### Parse named arguments

CMDSTAN_INSTALL_DIRECTORY=""
CMDSTAN_INSTALL_VERSION=""
OS_TYPE=""

while getopts ":d:v:" opt; do
  case $opt in
    p) CMDSTAN_INSTALL_DIRECTORY="$OPTARG"
    ;;
    d) OS_TYPE="$OPTARG"
    ;;
    v) CMDSTAN_INSTALL_VERSION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Set default if -d wasn't passed as an argument
# Based on: https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap08.html
# $HOME should always be defined by POSIX spefifications
if [ -z "$CMDSTAN_INSTALL_DIRECTORY" ]
then
    CMDSTAN_INSTALL_DIRECTORY=`echo $HOME`
fi

# Set default if -v wasn't passed as an argument
if [ -z "$CMDSTAN_INSTALL_VERSION" ]
then
    CMDSTAN_INSTALL_VERSION=`curl -s --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 https://api.github.com/repos/stan-dev/cmdstan/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")'`
    # Check if curl was successful
    checkReturnCode "$?" "Github latest version query failed"
fi

# Makes sure we have -d type
if [ -z "$OS_TYPE" ]
then
    echo -e "$HELP_TXT \n"
    echo -e "-d is required!"
    exit 1
fi

# Makes sure we have a valid -d
haystack='debian mac opensuse redhat'
if [[ " $haystack " =~ .*\ $OS_TYPE\ .* ]]; then

    # Check if script is executable
    if [[ -x "distros/$OS_TYPE.sh" ]]
    then
        echo ""
    else
        echo "File '$OS_TYPE.sh' is not executable! Setting correct permissions now ..."
        sudo chmod a+x distros/$OS_TYPE.sh
    fi

    # Execute distro specific installation script
    distros/$OS_TYPE.sh "$CMDSTAN_INSTALL_DIRECTORY" "$CMDSTAN_INSTALL_VERSION"
else
    echo -e "$HELP_TXT \n"
    echo -e "Invalid -d !"
    exit 1
fi



