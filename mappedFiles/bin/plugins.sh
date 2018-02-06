#!/bin/bash

set -e

mkdir -p ${JENKINS_HOME}/plugins

for plugin in $(jq '.[] | .plugin+":"+.version' $1 -r); do
  plugin=(${plugin//:/ })
  name=${plugin[0]}
  version=${plugin[1]}
  [[ -n ${version} ]] || version="stable"

  echo "Downloading plugin ${name}:${version}"

  curl -fsSL ${JENKINS_UPDATES_URL}/${version}/latest/${name}.hpi -o ${JENKINS_HOME}/plugins/${name}-${version}.hpi

  unzip -qo ${JENKINS_HOME}/plugins/${name}-${version}.hpi
  touch ${JENKINS_HOME}/plugins/${name}-${version}.pinned
done
