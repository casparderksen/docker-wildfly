#!/bin/bash

set -e

: ${TIME_ZONE:=UTC}
: ${JAVA_OPTS:="-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djava.security.egd=file:/dev/./urandom -Duser.timezone=${TIME_ZONE}"}
: ${WILDFLY_ADMIN_USER:=admin}
: ${WILDFLY_ADMIN_PASSWORD:=$(cat /dev/urandom | tr -cd '[:print:]' | head -c 32)}
: ${WILDFLY_KEYSTORE_PASSWORD:=changeit}
: ${WILDFLY_KEY_PASSWORD:=changeit}

set -u

# Configure file system locations

MASTER_PASSWORD_FILE=/run/secrets/master-password
SECRETS_DIR=${JBOSS_HOME}/standalone/configuration/secrets
MASTER_CS_FILE=${SECRETS_DIR}/master.jceks
WILDFLY_CS_FILE=${SECRETS_DIR}/wildfly.jceks
WILDFLY_PROPERTIES_FILE=${JBOSS_HOME}/standalone/configuration/wildfly.properties

# Read master password and generate random credential store password

MASTER_CS_PASSWORD=$(cat "${MASTER_PASSWORD_FILE}")
WILDFLY_CS_PASSWORD=$(cat /dev/urandom | tr -cd '[:print:]' | head -c 32)

# Functions for managing credential stores with Elytron Tool

function master_credential_store() {
    ${JBOSS_HOME}/bin/elytron-tool.sh credential-store --location "${MASTER_CS_FILE}" --password "${MASTER_CS_PASSWORD}" $*
}

function wildlfy_credential_store() {
    ${JBOSS_HOME}/bin/elytron-tool.sh credential-store --location "${WILDFLY_CS_FILE}" --password "${WILDFLY_CS_PASSWORD}" $*
}

# Create admin user and unset password from environment

${JBOSS_HOME}/bin/add-user.sh "${WILDFLY_ADMIN_USER}" "${WILDFLY_ADMIN_PASSWORD}"
unset WILDFLY_ADMIN_USER WILDFLY_ADMIN_PASSWORD

# Store Wildfly credential store password in master credential store

master_credential_store --create
master_credential_store --add wildfly-cs-password --secret "${WILDFLY_CS_PASSWORD}"

# Store passwords from environment in credential store, and write properties to file

wildlfy_credential_store --create
touch ${WILDFLY_PROPERTIES_FILE}

export WILDFLY_KEYSTORE_PASSWORD WILDFLY_KEY_PASSWORD
while read line; do
    if [[ ${line} =~ WILDFLY_(.*)=(.*) ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        if [[ ${key} =~ .*_PASSWORD ]]; then
            alias=$(echo ${key} | tr '[:upper:]_' '[:lower:]-')
            wildlfy_credential_store --add "${alias}" --secret "${value}"
            unset WILDFLY_${key}
        elif [[ ${key} != VERSION && ${key} != SHA256 ]]; then
            property=$(echo ${key} | tr '[:upper:]_' '[:lower:].')
            echo "${property}=${value}" >> ${WILDFLY_PROPERTIES_FILE}
            echo "Stored property ${property}=${value}"
        fi
     fi
done < <(printenv)

# Configure Java options
export JAVA_OPTS="${JAVA_OPTS} -Djboss.tx.node.id=$(hostname)"

# Ensure standalone.sh script forwards Unix signals to the JVM process for graceful shutdown
export LAUNCH_JBOSS_IN_BACKGROUND=true

# Replace shell with WildFly in standalone mode and bind to all interface
exec ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 --properties="${WILDFLY_PROPERTIES_FILE}"