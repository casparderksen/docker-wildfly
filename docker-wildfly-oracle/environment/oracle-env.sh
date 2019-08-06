# Oracle DB config
: ${ORACLE_DATASOURCE_URL:="jdbc:oracle:thin:@//oracledb:1521/ORCLPDB1"}
: ${WILDFLY_ORACLE_DATASOURCE_JNDINAME:="java:jboss/datasources/OracleDS"}
: ${WILDFLY_ORACLE_DATASOURCE_USERNAME:=scott}
: ${WILDFLY_ORACLE_DATASOURCE_PASSWORD:=tiger}

# Hiberbate config
: ${WILDFLY_HIBERNATE_DIALECT:="org.hibernate.dialect.Oracle12cDialect"}

# Container boot config
: ${WILDFLY_WAIT_FOR_ORACLE_TIMEOUT:=300}