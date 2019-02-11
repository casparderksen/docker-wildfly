FROM caspard/openjdk8 as base

# Create JBoss user and group used to launch processes
RUN groupadd -r jboss -g 1000 \
    && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss \
    && chmod 755 /opt/jboss

# Set the JBOSS_HOME and WILDFLY_VERSION environment variable
ENV JBOSS_HOME=/opt/jboss/wildfly \
    WILDFLY_VERSION=15.0.1.Final \
    WILDFLY_SHA256=7f020d67495e860e719ae8ee38bc9c9eb6e5df42fb4d4e5983431243c2f3bf06

# Install Wildfly in JBOSS_HOME
RUN curl -s -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha256sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA256 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz

# Add config script
COPY bin/run-config-scripts.sh $JBOSS_HOME/bin

# Configure logging, system properties, master-password, and TLS certificate
RUN sed -ie 's/%d{HH/%d{yyyy-MM-dd HH/' $JBOSS_HOME/standalone/configuration/logging.properties \
    && touch $JBOSS_HOME/standalone/configuration/wildfly.properties \
    && mkdir -m 700 /run/secrets \
    && chown -R jboss:jboss /run/secrets \
    && cat /dev/urandom | tr -cd '[:alnum:]' | head -c 32 > /run/secrets/master-password \
    && mkdir -m 700 $JBOSS_HOME/standalone/configuration/security \
    && keytool -genkeypair \
           -keyalg RSA \
           -keysize 1024 \
           -validity 365 \
           -alias localhost \
           -dname "CN=localhost" \
           -storetype pkcs12 \
           -keystore $JBOSS_HOME/standalone/configuration/security/keystore.jks \
           -keypass changeit \
           -storepass changeit \
    && chown -R jboss:jboss $JBOSS_HOME

##############################
### Generate configuration ###
##############################

FROM base as builder

# Add setup scripts
COPY setup $JBOSS_HOME/setup

# Run setup scripts
RUN $JBOSS_HOME/bin/run-config-scripts.sh $JBOSS_HOME/setup

############################
### Generate final image ###
############################

FROM base

# Copy configuration file from builder (credentials stores are generated at startup)
COPY --chown=jboss:jboss --from=builder $JBOSS_HOME/standalone/configuration/standalone.xml $JBOSS_HOME/standalone/configuration

# Add startup scripts
COPY --chown=jboss:jboss bin/environment.sh $JBOSS_HOME/bin
COPY --chown=jboss:jboss startup $JBOSS_HOME/startup
COPY bin/wildfly-wrapper.sh /usr/local/bin

# Switch to restricted user
USER jboss

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# Expose debug/HTTPS/management ports
EXPOSE 5005 8443 9993

# Wrapper script runs startup scripts and starts the server
CMD ["/usr/local/bin/wildfly-wrapper.sh"]
