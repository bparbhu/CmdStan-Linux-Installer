#/bin/bash

# Import utils.sh for useful functions so we don't have duplicate code
source $(dirname "$0")/../scripts/utils.sh

# Function used to download and extract cmdstan to a specific directory
# Then clean, build and compile an example model examples/bernoulli/bernoulli
function installCmdStan {
    CMDSTAN_ROOT_DIR=$1
    CMDSTAN_VERSION=$2

    # Change directory to the root directory where we want cmdstan installed
    cd $CMDSTAN_ROOT_DIR

    # Clean old archive if it exists
    rm -f cmdstan-$CMDSTAN_VERSION.tar.gz

    # Download .tar.gz for this specific version release
    curl --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 https://github.com/stan-dev/cmdstan/releases/download/v$CMDSTAN_VERSION/cmdstan-$CMDSTAN_VERSION.tar.gz -O -J -L
    checkReturnCode "$?" "Github release download failed"

    # Unpack our .tar.gz release inside chosen directory
    tar -xf cmdstan-$CMDSTAN_VERSION.tar.gz
    checkReturnCode "$?" "Corrupt download file cmdstan-$CMDSTAN_VERSION.tar.gz"

    rm -f cmdstan-$CMDSTAN_VERSION.tar.gz

    # Change working directory to where we've extracted cmdstan release
    cd cmdstan-$CMDSTAN_VERSION

    # Clean
    make clean-all

    # Build
    make build

    # Compile example model
    make -j2 build examples/bernoulli/bernoulli 
}
