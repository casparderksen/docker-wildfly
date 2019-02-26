#!/bin/sh -eu

# Load configuration variables and defaults
source $JBOSS_HOME/bin/environment.sh

# Export variables for use in config scripts
export $(compgen -v | grep ^WILDFLY_)

if [ "$1" = "wildfly" ]; then

    # Run config scripts before server startup
    $JBOSS_HOME/bin/run-config-scripts.sh $JBOSS_HOME/startup

    # Unset passwords from environment
    unset $(compgen -v | grep PASSWORD)

    # Configure Java options
    export JAVA_OPTS="${JAVA_OPTS} -Djboss.tx.node.id=$(hostname)"

    # Ensure standalone.sh script forwards Unix signals to the JVM process for graceful shutdown
    export LAUNCH_JBOSS_IN_BACKGROUND=true

    # Replace shell with WildFly in standalone mode and bind to all interface
    exec ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 --properties=${WILDFLY_PROPERTIES}
fi

exec "$@"