# About

This projects packages and configures Wildfly in a Docker image.  The goal
of this project is to run JEE8/MicroProfile based microservices in containers
that are secure by default and respect [Twelve-Factor App](http://12factor.net) principles.
When the container starts, it must be fully configured without baking secrets 
into the image.

Wildfly is configured in standalone mode, since clustering should be managed from
the container orchestrator and not some JEE application server.

For fast startup, Wildfly is configured at build time, with references to dummy
credentials and a self signed certificate. At run time, credential stores are regenerated
with actual secrets from the environment. 

# Building the images

A [`Makefile`](Makefile) builds the images and their depencies.

The Wildfly image is built as follows:
- Jboss base image (CentOS-7, OpenJDK-8, jboss user)
- Installation of Wildlfy 17 via Galleon
- Generatibaon of self-signed certificate for development environment
- Creation of credential stores with dummy passwords
- Offline configuration of Wildfly via CLI

Run the following command to build the Wildfy image:

    $ make
    
# Running a container

Type the following command to run a Wildfly container:

    $ make run

## Environment variables

Containers launched from the Wildfly image can be configured with the following environment variables:

- `JAVA_OPTS`: JVM options (memory settings)
- `JAVA_EXTRA_OPTS`: additional JVM options
- `WILDFLY_SERVER_OPTS`: Wildfly server properties
- `WILDFLY_ADMIN_USER`: admin user name
- `WILDFLY_ADMIN_PASSWORD`: admin user password
- `WILDFLY_KEYSTORE_PASSWORD`: keystore password for TLS
- `WILDFLY_KEY_PASSWORD`: key password for TLS
- `WILDFLY_DEBUG`: if true, enable JVM debugging
- `WILDFLY_DEBUG_PORT`: JVM debug port
- `TIME_ZONE`: passed as `user.timezone` property to Wildfly
- `TX_NODE_ID`: passed as `jboss.tx.node.id` property to Wildfly

See [base-env.sh](docker-wildfly/bin/base-env.sh) for defaults.

When running the container, all environment variables of the form `WILDFLY_*_PASSWORD` are stored 
as aliases in a credential store. The `WILDFLY_` prefix is stripped, the name is converted to lower case,
and underscores are replaced with dashes. For example, `WILDFLY_DATASOURCE_PASSWORD` results in 
alias `datasource-password`.

## Ports

The following ports are exposed:
- 5005: for remote debugging
- 8080: HTTP port
- 8443: HTTPS port
- 9990: management port (redirected to secure port)
- 9993: secure management port (remote+https)

## Management console

When the container is running, the management console can be accessed at:

    $ jboss-cli.sh --connect --controller=remote+https://localhost:9993

## JVM options

Newer versions of Java 8 and higher should respect CPU and memory limits.
To use all available heap configured from a container orchestrator, specify the following JVM option: `-XX:MaxRAMFraction=1`.

# Security

## TLS certificate

A self-signed certificate is stored in `$JBOSS_HOME/standalone/configuration/security/keystore.jks`.
For production, replace the certificate with a proper certificate.

## Admin user

When the container starts, the wrapper scripts creates an admin user with the
specified password.  If no admin password is specified, a random password is
generated, rendering the management interface inaccessible.

## Secrets

When the container starts, the wrapper script stores passwords in an Elytron
Credential Store.  The credential store is encrypted with a random master password.

# Extending the base image

The base image can be extended by adding shell or CLI scripts that are ran during build or startup:
- Scripts in `$JBOSS_HOME/setup` are executed when building the image
- Scripts in `$JBOSS_HOME/environment` are sourced before running the startup scripts
- Scripts in `$JBOSS_HOME/startuo` are executed and before starting Wildlfy

See [docker-wildlfy-oracle](docker-wildfly-oracle) for an example.

## Oracle RDBMS

The [docker-wildlfy-oracle](docker-wildfly-oracle) extends the Wildfly base image with an Oracle
JDBC driver and datasource. The datasource can be configured via environment variables. 

To build the image, download `ojdbc8.jar` from
[https://www.oracle.com/technetwork/database/features/jdbc/jdbc-ucp-122-3110062.html](https://www.oracle.com/technetwork/database/features/jdbc/jdbc-ucp-122-3110062.html)
to [`docker-wildfly-oracle/modules/com/oracle/jdbc/main/ojdbc8.jar`](docker-wildfly-oracle/modules/com/oracle/jdbc/main/ojdbc8.jar).
Then run:

    make wildfly-oracle.build
    
Environment variables for configuring the datasource are:

- `WILDFLY_ORACLE_DATASOURCE_URL`: connection URL
- `WILDFLY_ORACLE_DATASOURCE_JNDINAME`: JDNI name for the datasource
- `WILDFLY_ORACLE_DATASOURCE_USERNAME`: user name
- `WILDFLY_ORACLE_DATASOURCE_PASSWORD`: password

See [oracle-env.sh](docker-wildfly-oracle/oracle-env.sh) for defaults.

## Docker-compose example

See [docker-compose](docker-compose) for an example setup of Wildfly with an Oracle database.
1. First create an Oracle database image (see [docker-oracle](https://github.com/casparderksen/docker-oracle))
2. Build the Wildfly Oracle image: `make wildfly-oracle.build`
3. Go to the [docker-compose](docker-compose) directory
4. Start the database: `docker-compose up -d oracledb`
5. Wait for the database to start: `docker logs -f <container-id>`
6. Start the Wildlfy image: `docker-compose up -d  wildfly-oracle`
7. Go to the management console at [https://localhost:9993/](https://localhost:9993/), login with `admin:changeit`
   and test the datasource connection.

# References

Wildfly:
- [Wildfly 15 documentation](http://docs.wildfly.org/15/)
- [WildFly quickstarts](https://github.com/wildfly/quickstart)
- [JBoss EAP documentation](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/)

Oracle RDBMS in Docker:
- [docker-oracle](https://github.com/casparderksen/docker-oracle)