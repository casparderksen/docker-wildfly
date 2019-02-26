#!/bin/sh

SCRIPTS_DIR=$1
shift
CLI_ARGS=$*

set -eu

if [[ -z "${SCRIPTS_DIR}" ]]; then
   echo "Usage: $(basename $0) <scripts-dir> [ <cli-args> ]";
   exit 1;
fi;

if [[ ! -d "${SCRIPTS_DIR}" ]]; then
   echo "$(basename $0): scripts directory expected as argument";
   exit 1;
fi;

# Run shell scripts
find ${SCRIPTS_DIR} -name '*.sh' | while read FILE; do
    echo "Running ${FILE}"
    ${FILE}
done

# Run CLI scripts
find ${SCRIPTS_DIR} -name '*.cli' | while read FILE; do
    echo "Running ${FILE}"
    ${JBOSS_HOME}/bin/jboss-cli.sh --file=${FILE} ${CLI_ARGS}
done