#!/usr/bin/env bash

# set configuration vars

REPO="http://llvm.org/git"

if [ -z "$1" ]; then 
  echo "warning: repo url was not provided" 
  echo "warning: using default fallback url: ${REPO}"
else
  REPO="$1"
fi


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

