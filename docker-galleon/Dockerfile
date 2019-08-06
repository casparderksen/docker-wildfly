FROM jboss/base-jdk:8

# Set Wilfdly and Galleon version
ENV WILDFLY_VERSION=17.0.1.Final \
    GALLEON_VERSION=4.0.3.Final

# Install Galleon
RUN curl -sLO https://github.com/wildfly/galleon/releases/download/${GALLEON_VERSION}/galleon-${GALLEON_VERSION}.zip \
    && unzip galleon-${GALLEON_VERSION}.zip -d /opt/jboss \
    && mv galleon-${GALLEON_VERSION} galleon \
    && rm galleon-${GALLEON_VERSION}.zip

# Add Galleon tool to path
ENV PATH=$PATH:/opt/jboss/galleon/bin

# Download Wildly features and populate .m2 repo
RUN galleon.sh install wildfly:current#${WILDFLY_VERSION} --dir=wildfly \
    && rm -r wildfly

ENTRYPOINT ["/bin/bash"]