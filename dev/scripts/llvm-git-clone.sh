#!/usr/bin/env bash

# set configuration vars

CMD_OPTS=":r:h"
REPO="http://llvm.org/git"


read -r -d '' HELP_STR <<'EOF'
Usage: scriptname -h -r [repo URL]

Output Options:
  -r [repo URL]     Use this as a repo URL, otherwise default value.
  -h                This help screen.
EOF


# parse command-line options

OPT_R_USED=false

while getopts "${CMD_OPTS}" opt; do
  case $opt in
    r)
      ${OPT_R_USED} && echo "Option: -$opt used more than once." >&2 && exit 1
      echo ${OPTARG}
      REPO=${OPTARG}
      OPT_R_USED=true
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

git clone ${REPO}/llvm.git

pushd llvm/tools
git clone ${REPO}/clang.git
git clone ${REPO}/lldb.git 
popd

pushd llvm/projects
git clone ${REPO}/libcxx.git
git clone ${REPO}/libcxxabi.git
git clone ${REPO}/compiler-rt.git
git clone ${REPO}/openmp.git
git clone ${REPO}/test-suite.git
popd

exit 0

