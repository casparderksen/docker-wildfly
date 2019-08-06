#!/bin/sh -eu

# Set keystore dir (same as in base.cli)
KEYSTORE_DIR=${JBOSS_HOME}/standalone/configuration/security

# Create keystore with self-signed certificate
keytool -genkeypair \
        -keyalg RSA \
        -keysize 2048 \
        -validity 365 \
        -alias localhost \
        -dname "CN=localhost" \
        -storetype pkcs12 \
        -keystore ${KEYSTORE_DIR}/keystore.jks \
        -keypass ${WILDFLY_KEY_PASSWORD} \
        -storepass ${WILDFLY_KEYSTORE_PASSWORD}