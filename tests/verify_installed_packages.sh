#!/bin/bash

RELATIVE_PATH="tests/"

# Function used to verify if a packages is installed, has a working binary and passes a set of test/s.
# Arguments
## $1 : PACKAGE_NAME -> Represents the package name to verify, for example: g++
## $2 : CHECK_TOOL -> Represents the tool used to check if the package exists. Possible values, one of: [which, rpm]
### In the form of a binary with 'which' ( if exists, returns path to binary )
### In the form of a rpm installation, mostly used in redhat distros
function verifyPackageInstallation {
    PACKAGE_NAME=$1
    CHECK_TOOL=$2
    PACKAGE_INSTALLED=""
    
    # Check if there is a binary on the OS with `which` or a rpm install
    if [ "$CHECK_TOOL" == "which" ]; then
        PACKAGE_INSTALLED=`which $PACKAGE_NAME`
    elif [ "$CHECK_TOOL" == "rpm" ]; then
        PACKAGE_INSTALLED=`rpm -qa | grep $PACKAGE_NAME`
    else
        echo "Package manager $CHECK_TOOL not implemented!"
        exit 1
    fi

    # If we do not have a binary, something is wrong
    if [ -z "$PACKAGE_INSTALLED" ]
    then
        echo "Package $PACKAGE_NAME was not installed successfully!"
        echo "'which $PACKAGE_NAME' should have returned the path to the fresh installed binary but it returned '$PACKAGE_INSTALLED' instead."
        echo "Please fix the above error by ensuring you have correct permissions to be able to install a package through APT package manager."
        exit 1
    fi

    # Running a test for each binary/package we needed to have
    echo "Running test to make sure '$PACKAGE_NAME' is working as intended!"

    CWD=`pwd`
    ### MAKE
    if [[ $PACKAGE_NAME =~ "make" ]]
    then
        cd "$RELATIVE_PATH"
        MAKE_OUTPUT=`make ping`
        
        if [[ $MAKE_OUTPUT =~ "pong" ]]
        then
            echo "$PACKAGE_NAME was installed successfully and is running as it should."
        else
            echo "$PACKAGE_NAME is not running as it should!"
            echo "'make ping' should have returned back 'pong' in the output but instead it returned '$MAKE_OUTPUT'"
            exit 1
        fi
        cd "$CWD"
    ### CURL
    elif [[ $PACKAGE_NAME =~ "curl" ]]
    then
        CURL_OUTPUT=`curl -I https://www.google.com`

        if [[ $CURL_OUTPUT =~ "HTTP/2 200" ]]
        then
            echo "$PACKAGE_NAME was installed successfully and is running as it should."
        else
            echo "$PACKAGE_NAME is not running as it should!"
            echo "'curl https://www.google.com' should have returned back 'HTTP/2 200' in the output ( response code + other header information ) but instead it returned '$CURL_OUTPUT'"
            exit 1
        fi
    ### TAR
    elif [[ $PACKAGE_NAME =~ "tar" ]]
    then
        cd "$RELATIVE_PATH"
        TAR_OUTPUT=`tar -ztvf tar-test.tar.gz`

        if [[ $TAR_OUTPUT =~ "unarchived.proof" ]]
        then
            echo "$PACKAGE_NAME was installed successfully and is running as it should."
        else
            echo "$PACKAGE_NAME is not running as it should!"
            echo "'tar -ztvf tar-test.tar.gz' should have returned back 'unarchived.proof' in the output ( list of the contents of the archive ) but instead it returned '$TAR_OUTPUT'"
            exit 1
        fi
        cd "$CWD"
    ### G++
    elif [[ $PACKAGE_NAME =~ "g++" ]]
    then
        cd "$RELATIVE_PATH"

        # Build hello.cpp
        g++ -o hello hello.cpp

        if test -f "hello"; then
            echo "'hello' was built successfully!"
        else
            echo "'hello' was not build successfully using 'g++ -o hello hello.cpp' !"
            echo "Please check your 'g++' installation and make sure there are no permission issues around it!"
            exit 1
        fi

        # Verify binary output
        HELLO_OUTPUT=`./hello`

        # Execute the binary we just built
        if [ "$HELLO_OUTPUT" == "Hello, World!" ]; then
            echo "Binary output is correct, we're assuming g++ is working as it should now!"
            # Clean after us
            make clean
        else
            echo "Output from the hello binary is incorrect, it should have been 'Hello, World!' but instead we got '$HELLO_OUTPUT'"
            echo "Please check your 'g++' installation and make sure there are no permission issues around it!"
            exit 1
        fi
        cd "$CWD"
    else
        echo "A test for $PACKAGE_NAME is not yet implemented in 'verify_installed_packages.sh' !"
        exit 1
    fi
}