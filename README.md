# About

This projects packages and configures Wildfly 15 in a Docker image.  The goal
of this project is to run JEE8/MicroProfile based microservices in containers
that are secure by default and respect [Twelve-Factor App](http://12factor.net) principles.
When the container starts, it must be fully configured without baking secrets 
into the image.

Wildfly is configured in standalone mode, since clustering should be managed from
the container orchestrator and not some JEE domain.

For fast startup, Wildfly is configured at build time, with references to dummy
credentials and a self signed certificate. At run time, credential stores are regenerated
with actual secrets from the environment. The self-signed certificate can be replaced with 
a bind mount.

# Building the images

A [`Makefile`](Makefile) builds the images and their depencies.

The Wildfly image is built as follows:
- CentOS-7 with OpenJDK-8 base image
- Installation of Wildlfy 15
- Generation of self-signed certificate for development environment
- Creation of credential stores with dummy passwords
- Offline configuration of Wildfly via CLI

Run the following command to build the Wildfy image:

    $ make
    
# Running a container

Type the following command to run a Wildfly container:

    $ make run

## Environment variables

Containers launched from the Wildfly image can be configured with the following environment variables:

- `TIME_ZONE`: passed as `user.timezone` property to Wildfly
- `JAVA_OPTS`: passed to Wildfy
- `WILDFLY_ADMIN_USER`: admin user name
- `WILDFLY_ADMIN_PASSWORD`: admin user password
- `WILDFLY_KEYSTORE_PASSWORD`: keystore password for TLS
- `WILDFLY_KEY_PASSWORD`: key password for TLS

See [wildfly-wrapper.sh](docker-wildfly/bin/wildfly-wrapper.sh) for defaults.

When running the container, all environment variables of the form `WILDFLY_*_PASSWORD` are stored 
as aliases in a credential store. Other environment variables of the form `WILDFLY_*` are written
to a properties files used for configuration. In this way, environment variables can be used for
dynamically configuring the container at startup.

When generating alias or property names from environment variables, the `WILDFLY_` prefix is stripped
and the name is converted to lower case. For aliases, underscores are replaced with dashes,
whereas for properties underscores are replaced with periods. For example:
- `WILDFLY_DATASOURCE_ORACLE_USERNAME` results in property `datasource.oracle.username`
- `WILDFLY_DATASOURCE_ORACLE_PASSWORD` results in alias `datasource-oracle-password`

## Ports

The following ports are exposed:
- 5005: for remote debugging
- 8443: HTTPS port
- 9993: Management port (remote+https)

## Management console

When the container is running, the management console can be accessed at:

    $ jboss-cli.sh --connect --controller=remote+https://localhost:9993

## JVM options

Newer versions of Java 8 and higher should respect CPU and memory limits.
To use all available heap configured from a container orchestrator, specify the following JVM option: `-XX:MaxRAMFraction=1`.
In order to ensure sufficient entropy, following JVM option is added by default: `-Djava.security.egd=file:/dev/./urandom`.

## Remote debugging

The `JAVA_TOOL_OPTIONS` environment variable can be specified to set Java
command line options without altering the container image. To enable remote
debugging in a Docker container, start the container with the following
environment variable:

    JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

# Security

## TLS certificate

A self-signed certificate is stored in `/opt/security/keystore.jks`.
For production, replace the certificate with a proper certificate from a bind mount.

## Admin user

When the container starts, the wrapper scripts creates an admin user with the
specified password.  If no admin password is specified, a random password is
generated, rendering the management interface inaccessible.

## Secrets

When the container starts, the wrapper script stores passwords in an Elytron
Credential Store.  The credential store is encrypted with a random password.
This password is stored in a second credential store that is encrypted with a
master password. The master password is read from `/run/secrets/master-password`.
For production, the master password can be overridden with a password stored in
an in-memory file system (e.g. Docker secret).

# Databases

## Oracle RDBMS

Download `ojdbc8.jar` from
[https://www.oracle.com/technetwork/database/application-development/jdbc/downloads/jdbc-ucp-183-5013470.html](https://www.oracle.com/technetwork/database/application-development/jdbc/downloads/jdbc-ucp-183-5013470.html)
to [`docker-wildfly-oracle`](docker-wildfly-oracle). Then run:

    make wildfly-oracle.build
    
Environment variables for configuring the datasource:

- `WILDFLY_DATASOURCE_ORACLE_URL`: connection URL
- `WILDFLY_DATASOURCE_ORACLE_USERNAME`: user name
- `WILDFLY_DATASOURCE_ORACLE_PASSWORD`: password

See [oracle.cli](docker-wildfly-oracle/cli/oracle.cli) for defaults.

# References

Wildfly:
- [Wildfly 15 documentation](http://docs.wildfly.org/15/)
- [WildFly quickstarts](https://github.com/wildfly/quickstart)
- [JBoss EAP documentation](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/)

