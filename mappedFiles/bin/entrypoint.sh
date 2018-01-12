#!/bin/bash

exec java -jar ${JENKINS_HOME}/jenkins.war --httpPort=${JENKINS_MASTER_PORT}
