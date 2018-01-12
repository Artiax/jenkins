#!/bin/bash

set -e

for mapping in $(jq '.[] | .from+":"+.to' $1 -r); do
  mapping="${mapping//:/ }"
  IFS=' ' read -a file <<< "$mapping"

  from="${file[0]}"
  to="$(eval echo ${file[1]})"

  echo "Moving ${from} to ${to}"

  mkdir -p "$(echo "${to}" | grep -Eo '^.*\/')"
  mv /tmp/mappedFiles/${from} "${to}"
done
