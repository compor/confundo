#!/usr/bin/env bash

# set configuration vars

CMD_OPTS=":b:h"
BRANCH="master"


read -r -d '' HELP_STR <<'EOF'
Usage: scriptname -h -b [branch]

Output Options:
  -b [branch]       Use this 'branch' name, otherwise 'master'.
  -h                This help screen.
EOF


# parse command-line options

OPT_B_USED=false

while getopts "${CMD_OPTS}" opt; do
  case $opt in
    b)
      ${OPT_B_USED} && echo "Option: -$opt used more than once." >&2 && exit 1
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

