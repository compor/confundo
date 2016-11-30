#!/usr/bin/env bash

# set configuration vars

CMD_OPTS=":d:b:h"
SEARCH_DIR=$(pwd)
BRANCH="master"

SUFFIX='.git'


read -r -d '' HELP_STR <<'EOF'
Usage: scriptname -h -r [repo URL]

Output Options:
  -d [dir]          Use this directory, otherwise the PWD.
  -b [branch tag]   Use this as checkout tag, otherwise default value.
  -h                This help screen.
EOF


# parse command-line options

OPT_D_USED=false
OPT_B_USED=false

while getopts "${CMD_OPTS}" opt; do
  case $opt in
    d)
      ${OPT_D_USED} && echo "Option: -$opt used more than once." >&2 && exit 1
      echo ${OPTARG}
      SEARCH_DIR=${OPTARG}
      OPT_D_USED=true
      ;;
    b)
      ${OPT_B_USED} && echo "Option: -$opt used more than once." >&2 && exit 1
      echo ${OPTARG}
      BRANCH=${OPTARG}
      OPT_B_USED=true
      ;;
    h)
      echo "${HELP_STR}" >&2
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG." >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


#

REPO_DIRS=$(find ${SEARCH_DIR} -name ${SUFFIX} -a -type d)

for d in ${REPO_DIRS}; do 
  echo "status: working with git subproject: ${d}"

  pushd ${d%${SUFFIX}}
    git checkout ${BRANCH}
  popd
done 


exit 0

