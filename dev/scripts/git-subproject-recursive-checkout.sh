#!/usr/bin/env bash

# set configuration vars

BRANCH="master"

if [ -z "$1" ]; then 
  echo "warning: repo branch was not provided" 
  echo "warning: using default fallback url: ${BRANCH}"
else
  BRANCH="$1"
fi

GIT_PROJECTS=( $(find . -iname ".git" | xargs) )

((nelems=${#GIT_PROJECTS[@]}))

for ((i = 0; i < nelems; i++)); do
  subproject=$(dirname ${GIT_PROJECTS[i]})
  echo "status: working with git subproject: ${subproject}"

  pushd ${subproject}
  git checkout $BRANCH 
  popd
done

exit 0

