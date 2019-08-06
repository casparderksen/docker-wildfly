#!/bin/sh -eu

function run_config_script() {
    FILE=$1
    echo "Running ${FILE}"
    if [[ ${FILE} == *.sh ]]; then
        source ${FILE}
    elif [[ ${FILE} == *.cli ]]; then
        ${JBOSS_HOME}/bin/jboss-cli.sh --file=${FILE}
    fi
}

for ARG in $*; do
    if [[ -d ${ARG} ]]; then
        find ${ARG} -type f | while read FILE; do
            run_config_script ${FILE}
        done
    else
        run_config_script ${ARG}
    fi
done