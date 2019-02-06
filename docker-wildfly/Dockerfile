FROM caspard/openjdk8

# Create JBoss user and group used to launch processes
RUN groupadd -r jboss -g 1000 \
    && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss \
    && chmod 755 /opt/jboss

# Set the JBOSS_HOME and WILDFLY_VERSION environment variable
ENV JBOSS_HOME /opt/jboss/wildfly
ENV WILDFLY_VERSION 15.0.1.Final
ENV WILDFLY_SHA256 7f020d67495e860e719ae8ee38bc9c9eb6e5df42fb4d4e5983431243c2f3bf06

# Install Wildfly in JBOSS_HOME
RUN curl -s -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha256sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA256 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz

# Configure logging
COPY configuration/logging.properties $JBOSS_HOME/standalone/configuration

# Generate self signed certificate and master password.
# At run-time override the certificate with a proper certificate from a bind mount,
# and mount a random master-password from an in-memory filesystem (e.g. Docker secret).
RUN mkdir /opt/security \
    && keytool -genkeypair -keyalg RSA -keysize 1024 -validity 365 -alias localhost -dname "CN=localhost" \
        -storetype pkcs12 -keystore /opt/security/keystore.jks -keypass changeit -storepass changeit \
    && mkdir /run/secrets \
    && cat /dev/urandom | tr -cd '[:print:]' | head -c 32 > /run/secrets/master-password

# Change ownership to jboss user
RUN chown -R jboss:jboss $JBOSS_HOME

# Add startup script
COPY bin/wildfly-wrapper.sh /usr/local/bin

# Switch to restricted user
USER jboss

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# Apply static server configuration and remove dummy credential stores
COPY cli $JBOSS_HOME/cli
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/cli/base.cli \
    && chmod 700 $JBOSS_HOME/standalone/configuration/secrets \
    && rm $JBOSS_HOME/standalone/configuration/secrets/master.jceks \
    && rm $JBOSS_HOME/standalone/configuration/secrets/wildfly.jceks \
    && rm -r $JBOSS_HOME/standalone/configuration/standalone_xml_history \
    && rm -r $JBOSS_HOME/standalone/tmp/vfs

# Expose debug/HTTPS/management ports
EXPOSE 5005 8443 9993

# Wrapper script recreates credential stores and starts the server
CMD ["/usr/local/bin/wildfly-wrapper.sh"]
