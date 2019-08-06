#!/bin/sh -eu

if [ "$1" = "wildfly" ]; then

    # Load configuration variables and defaults
    for FILE in ${JBOSS_HOME}/environment/*.sh; do
        source ${FILE}
    done

    # Export WILDFLY variables for use in config scripts
    export $(compgen -v | grep ^WILDFLY_)

    # Run config scripts before server startup
    ${JBOSS_HOME}/bin/run-config-scripts.sh ${JBOSS_HOME}/startup

    # Unset secrets from environment
    unset $(compgen -v | grep -v WILDFLY_MASTER_PASSWORD | grep PASSWORD)

    # Make standalone.sh script forwards Unix signals to the JVM process for graceful shutdown
    export LAUNCH_JBOSS_IN_BACKGROUND=true

    # Export JAVA_OPTS for Wildly
    export JAVA_OPTS="${JAVA_OPTS} ${JAVA_EXTRA_OPTS}"

    # Check if debug option set
    if [[ "${WILDFLY_DEBUG}" == "true" ]]; then
        WILDFLY_SERVER_OPTS="${WILDFLY_SERVER_OPTS} --debug ${WILDFLY_DEBUG_PORT}"
    fi

    # Replace shell with WildFly in standalone mode and bind to all interfaces
    exec ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 ${WILDFLY_SERVER_OPTS}
fi

exec "$@"