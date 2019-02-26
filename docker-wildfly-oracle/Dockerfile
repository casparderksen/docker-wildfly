FROM caspard/wildfly as base

# Add Oracle driver module
COPY --chown=jboss:jboss modules $JBOSS_HOME/modules

##############################
### Generate configuration ###
##############################

FROM base as builder

# Run setup scripts
COPY setup $JBOSS_HOME/setup
RUN $JBOSS_HOME/bin/run-config-scripts.sh $JBOSS_HOME/setup

# Extend environment parameters
COPY bin/environment.sh /tmp
RUN cat /tmp/environment.sh >> $JBOSS_HOME/bin/environment.sh

############################
### Generate final image ###
############################

FROM base

# Add startup scripts
COPY --chown=jboss:jboss startup $JBOSS_HOME/startup

# Copy configuration files from builder
COPY --chown=jboss:jboss --from=builder $JBOSS_HOME/standalone/configuration/standalone.xml $JBOSS_HOME/standalone/configuration
COPY --chown=jboss:jboss --from=builder $JBOSS_HOME/bin/environment.sh $JBOSS_HOME/bin
