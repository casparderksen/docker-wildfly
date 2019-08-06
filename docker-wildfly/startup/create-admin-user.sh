#!/bin/sh -eu

${JBOSS_HOME}/bin/add-user.sh -sc ${JBOSS_HOME}/standalone/configuration "${WILDFLY_ADMIN_USER}" "${WILDFLY_ADMIN_PASSWORD}"