#!/bin/bash

# Move baked in jobs to the persistent volume
mv -f /tmp/jobs/* ${JENKINS_HOME}/jobs

# Start the main jenkins java process
exec java -jar ${JENKINS_HOME}/jenkins.war \
  -Djenkins.install.runSetupWizard=false \
  --httpPort=${JENKINS_MASTER_PORT}
