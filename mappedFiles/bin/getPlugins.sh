#!/bin/bash

# Retrieve a list of plugins using the API
# Select only the active ones
# Output only shortName,version
# Convert objects into array of objects
# Sort the output by the .shortName
curl -sg 'http://localhost:'$JENKINS_MASTER_PORT'/pluginManager/api/json?depth=1&tree=plugins[active,shortName,version]' \
  | jq '.plugins[] | select(.active==true) | {shortName,version}' \
  | jq '[inputs] | sort_by(.shortName)'
