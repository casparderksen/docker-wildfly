#!/bin/sh -u


if [[ ! ${WILDFLY_ORACLE_DATASOURCE_URL} =~ jdbc:oracle:thin:@(//)?(.+):([0-9]+)[:/](.+) ]] ; then
    echo "Unexpected datasource URL \"${WILDFLY_ORACLE_DATASOURCE_URL}\""
    exit 1
fi

host=${BASH_REMATCH[2]}
port=${BASH_REMATCH[3]}

/usr/local/bin/wait-for ${host}:${port} -- echo "Database is up"