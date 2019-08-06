FROM caspard/wildfly

# Install wait-for and netcat utilities (used by wait-for-oracle startup script)
USER root
RUN curl -s https://raw.githubusercontent.com/eficode/wait-for/master/wait-for > /usr/local/bin/wait-for \
    && chmod +x /usr/local/bin/wait-for \
    && yum install -y nc
USER jboss

# Add Oracle driver module
COPY modules $JBOSS_HOME/modules

# Copy environment settings
COPY environment ${JBOSS_HOME}/environment

# Copy setup scripts
COPY setup ${JBOSS_HOME}/setup

# Copy startup scripts
COPY startup ${JBOSS_HOME}/startup

# Run setup scripts and cleanup config
RUN ${JBOSS_HOME}/bin/run-config-scripts.sh ${JBOSS_HOME}/setup/oracle-ds.cli \
    && rm -r ${JBOSS_HOME}/standalone/data \
    && rm -r ${JBOSS_HOME}/standalone/log \
    && rm -r ${JBOSS_HOME}/standalone/tmp/vfs \
    && rm -r ${JBOSS_HOME}/standalone/configuration/standalone_xml_history