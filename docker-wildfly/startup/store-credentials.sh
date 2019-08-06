#!/bin/sh -eu

# Define file system locations (same as in base.cli)
SECRETS_DIR=${JBOSS_HOME}/standalone/configuration/security
CREDENTIAL_STORE=${SECRETS_DIR}/secrets.jceks

# Helper function for managing credential stores with Elytron Tool
function wildlfy_credential_store() {
    ${JBOSS_HOME}/bin/elytron-tool.sh credential-store \
        --location "${CREDENTIAL_STORE}" \
        --password "${WILDFLY_MASTER_PASSWORD}" $*
}

# Create credential store
wildlfy_credential_store --create

# Store passwords from environment in credential store
printenv | grep -v WILDFLY_MASTER_PASSWORD | while read line; do
    if [[ ${line} =~ WILDFLY_(.*_PASSWORD)=(.*) ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        alias=$(echo ${key} | tr '[:upper:]_' '[:lower:]-')
        wildlfy_credential_store --add "${alias}" --secret "${value}"
     fi
done
