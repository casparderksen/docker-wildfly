#!/bin/sh -eu

# Define file system locations (must be same values as in base.cli)
MASTER_CS_FILE=${JBOSS_HOME}/standalone/configuration/security/master.jceks
WILDFLY_CS_FILE=${JBOSS_HOME}/standalone/configuration/security/wildfly.jceks

# Read master password and generate random credential store password
MASTER_CS_PASSWORD=$(cat /run/secrets/master-password)
WILDFLY_CS_PASSWORD=$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c 32)

# Functions for managing credential stores with Elytron Tool

function master_credential_store() {
    ${JBOSS_HOME}/bin/elytron-tool.sh credential-store --location "${MASTER_CS_FILE}" --password "${MASTER_CS_PASSWORD}" $*
}

function wildlfy_credential_store() {
    ${JBOSS_HOME}/bin/elytron-tool.sh credential-store --location "${WILDFLY_CS_FILE}" --password "${WILDFLY_CS_PASSWORD}" $*
}

# Store Wildfly credential store password in master credential store
master_credential_store --create
master_credential_store --add wildfly-cs-password --secret "${WILDFLY_CS_PASSWORD}"

# Store passwords from environment in credential store
wildlfy_credential_store --create

printenv | while read line; do
    if [[ ${line} =~ WILDFLY_(.*_PASSWORD)=(.*) ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        alias=$(echo ${key} | tr '[:upper:]_' '[:lower:]-')
        wildlfy_credential_store --add "${alias}" --secret "${value}"
     fi
done
