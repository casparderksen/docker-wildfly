: ${JAVA_OPTS:="-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m"}
: ${JAVA_EXTRA_OPTS:="-Djava.net.preferIPv4Stack=true"}

: ${WILDFLY_ADMIN_USER:=admin}
: ${WILDFLY_ADMIN_PASSWORD:=$(cat /dev/urandom | tr -cd '[:print:]' | head -c 32)}

: ${WILDFLY_MASTER_PASSWORD:=$(cat /dev/urandom | tr -cd '[:print:]' | head -c 32)}
: ${WILDFLY_KEYSTORE_PASSWORD:=changeit}
: ${WILDFLY_KEY_PASSWORD:=changeit}

: ${WILDFLY_DEBUG:=false}
: ${WILDFLY_DEBUG_PORT:=5005}

: ${TIME_ZONE:=UTC}
: ${TX_NODE_ID:=$(hostname)}
: ${WILDFLY_SERVER_OPTS:="-Duser.timezone=${TIME_ZONE} -Djboss.tx.node.id=${TX_NODE_ID}"}