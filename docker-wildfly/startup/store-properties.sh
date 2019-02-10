#!/bin/sh -eu

# Blacklist passwords and internal configuration settings
function is_blacklisted {
    [[ "$1" =~ PASSWORD || "$1" == ADMIN_USER || "$1" == VERSION || "$1" == SHA256 || "$1" == PROPERTIES ]]
}

# Write properties to file (exclude passwords and interal config)
printenv | while read line; do
    if [[ ${line} =~ WILDFLY_(.*)=(.*) ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        if ! $(is_blacklisted ${key}); then
            property=$(echo ${key} | tr '[:upper:]_' '[:lower:].')
            echo "${property}=${value}" >> ${WILDFLY_PROPERTIES}
            echo "Stored property ${property}=${value}"
        fi
     fi
done