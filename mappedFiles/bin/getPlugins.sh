#!/bin/bash

# Iterate over currently installed plugins
# Create a map of plugin:version
# Convert the map into a JSON objects using jq
# Wrap JSON objects with an array using jq
find ${JENKINS_HOME}/plugins -maxdepth 1 -mindepth 1 -type d -exec cat {}/META-INF/MANIFEST.MF \; \
  | grep -E 'Short-Name|Plugin-Version' | awk '{ print $2 }' | tr -d ' \r' | paste -d ':' - - | sort \
  | jq -Rn '["plugin","version"] as $keys | (inputs | split(":")) as $plugins | [[$keys, $plugins] | transpose[] | {key:.[0],value:.[1]}] | from_entries' \
  | jq -n '[inputs]'
