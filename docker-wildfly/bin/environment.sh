: ${TIME_ZONE:=UTC}
: ${JAVA_OPTS:="-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djava.security.egd=file:/dev/./urandom -Duser.timezone=${TIME_ZONE}"}
: ${WILDFLY_ADMIN_USER:=admin}
: ${WILDFLY_ADMIN_PASSWORD:=$(cat /dev/urandom | tr -cd '[:print:]' | head -c 32)}
: ${WILDFLY_KEYSTORE_PASSWORD:=changeit}
: ${WILDFLY_KEY_PASSWORD:=changeit}
: ${WILDFLY_PROPERTIES:=${JBOSS_HOME}/standalone/configuration/wildfly.properties}