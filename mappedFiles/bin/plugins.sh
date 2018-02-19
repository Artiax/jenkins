#!/bin/bash

set -e

mkdir -p ${JENKINS_HOME}/plugins

for plugin in $(jq '.[] | .shortName+":"+.version' $1 -r); do
  plugin=(${plugin//:/ })
  shortName=${plugin[0]}
  version=${plugin[1]}
  [[ -z ${version} ]] && version="latest"

  echo "Installing plugin ${shortName}:${version}"

  curl -fsSL ${JENKINS_PLUGINS_URL}/${shortName}/${version}/${shortName}.hpi -o ${JENKINS_HOME}/plugins/${shortName}.jpi

  unzip -qo ${JENKINS_HOME}/plugins/${shortName}.jpi
done
