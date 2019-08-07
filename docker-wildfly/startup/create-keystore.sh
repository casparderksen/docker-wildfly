#!/bin/sh -eu

# Define file system locations (same as in base.cli)
KEYSTORE_DIR=${JBOSS_HOME}/standalone/configuration/security
KEYSTORE_FILE=${KEYSTORE_DIR}/keystore.jks

# Cleanup file left from previous container start (if any)
rm -f ${KEYSTORE_FILE}

# Create keystore with self-signed certificate
keytool -genkeypair \
        -keyalg RSA \
        -keysize 2048 \
        -validity 365 \
        -alias localhost \
        -dname "CN=localhost" \
        -storetype pkcs12 \
        -keystore ${KEYSTORE_FILE} \
        -keypass ${WILDFLY_KEY_PASSWORD} \
        -storepass ${WILDFLY_KEYSTORE_PASSWORD}