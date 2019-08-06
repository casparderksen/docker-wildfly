#########################
### Configure Wildlfy ###
#########################

FROM caspard/galleon as builder

# Set the JBOSS_HOME environment variable
ENV JBOSS_HOME=/opt/jboss/wildfly

# Provision Wildlfy server
RUN galleon.sh install wildfly:current#${WILDFLY_VERSION} --dir=${JBOSS_HOME} --layers=cloud-profile,core-server,core-tools

# Configure logging
RUN sed -ie 's/%d{HH/%d{yyyy-MM-dd HH/' ${JBOSS_HOME}/standalone/configuration/logging.properties

# Create a dummy master password (excpected by base.cli for setting up a credential store)
USER root
RUN mkdir /run/secrets \
    && echo changeit > /run/secrets/master-password \
    && chown -R jboss:jboss /run/secrets
USER jboss

# Copy environment settings
COPY environment ${JBOSS_HOME}/environment

# Copy setup scripts
COPY setup ${JBOSS_HOME}/setup

# Copy startup scripts
COPY startup ${JBOSS_HOME}/startup

# Copy script runner
COPY bin/run-config-scripts.sh ${JBOSS_HOME}/bin

# Run setup scripts and cleanup config
RUN ${JBOSS_HOME}/bin/run-config-scripts.sh ${JBOSS_HOME}/setup \
    && rm -r ${JBOSS_HOME}/{.galleon,.installation,.well-known} \
    && rm -r ${JBOSS_HOME}/standalone/{data,log} \
    && rm -r ${JBOSS_HOME}/standalone/tmp/* \
    && rm -r ${JBOSS_HOME}/standalone/configuration/standalone_xml_history \
    && rm ${JBOSS_HOME}/standalone/configuration/security/* \
    && chmod 750 ${JBOSS_HOME}/standalone/configuration/security

############################
### Generate final image ###
############################

FROM jboss/base-jdk:8

# Set the JBOSS_HOME environment variable
ENV JBOSS_HOME=/opt/jboss/wildfly

# Copy Wildfly installation from builder image
COPY --from=builder --chown=jboss:jboss ${JBOSS_HOME} ${JBOSS_HOME}

# Set the working directory to Jboss home directory
WORKDIR ${JBOSS_HOME}

# Expose debug/http/management ports
EXPOSE 5005 8080 8443 9990 9993

# Create directory for master password file (generated at startup)
USER root
RUN mkdir /run/secrets \
    && chmod 750 /run/secrets \
    && chown -R jboss:jboss /run/secrets

# Create entrypoint
COPY bin/entrypoint.sh /usr/local/bin
USER jboss

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["wildfly"]