# Oracle DB config
: ${WILDFLY_DATASOURCE_URL:="jdbc:oracle:thin:@//oracledb:1521/ORCLPDB1"}
: ${WILDFLY_DATASOURCE_JNDINAME:="java:jboss/datasources/OracleDS"}
: ${WILDFLY_DATASOURCE_USERNAME:=scott}
: ${WILDFLY_DATASOURCE_PASSWORD:=tiger}

# Hiberbate config
: ${WILDFLY_HIBERNATE_DIALECT:="org.hibernate.dialect.Oracle12cDialect"}

# Container boot config
: ${WILDFLY_WAIT_FOR_ORACLE_TIMEOUT:=300}