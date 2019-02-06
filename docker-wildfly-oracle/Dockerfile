FROM caspard/wildfly

# Add Oracle driver module
COPY --chown=jboss:jboss module.xml ojdbc8.jar $JBOSS_HOME/modules/system/layers/base/com/oracle/jdbc/main/

# Configure data source
COPY cli $JBOSS_HOME/cli
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/cli/oracle.cli \
    && rm -r $JBOSS_HOME/standalone/configuration/standalone_xml_history \
    && rm -r $JBOSS_HOME/standalone/tmp/vfs

