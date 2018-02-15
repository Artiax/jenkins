#!/bin/bash

set -e

mkdir -p ${JENKINS_HOME}/plugins

for plugin in $(jq '.[] | .plugin+":"+.version' $1 -r); do
  plugin=(${plugin//:/ })
  name=${plugin[0]}
  version=${plugin[1]}
  [[ -z ${version} ]] && version="latest"

  echo "Installing plugin ${name}:${version}"

  curl -fsSL ${JENKINS_PLUGINS_URL}/${name}/${version}/${name}.hpi -o ${JENKINS_HOME}/plugins/${name}.jpi

  unzip -qo ${JENKINS_HOME}/plugins/${name}.jpi
done
