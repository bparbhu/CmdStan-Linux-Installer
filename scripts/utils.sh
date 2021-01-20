#!/bin/bash

# Function used to check if a return code is != 0 and return an error message.
function checkReturnCode {
    CMD_RC=$1
    MESSAGE=$2
    if [[ ${CMD_RC} -ne 0 ]]; then
        echo "$MESSAGE, exited with error code: ${CMD_RC}"
        exit ${CMD_RC}
    fi
}