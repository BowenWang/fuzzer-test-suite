#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#. $(dirname $0)/../custom-build.sh $1 $2
#. $(dirname $0)/../common.sh

CXXFLAGS="${CXXFLAGS} -std=gnu++98"
export CXX=g++
export CC=gcc

get_git_tag() {
  GIT_REPO="$1"
  GIT_TAG="$2"
  TO_DIR="$3"
  [ ! -e $TO_DIR ] && git clone $GIT_REPO $TO_DIR && (cd $TO_DIR && git checkout $GIT_TAG)
}

get_git_revision() {
  GIT_REPO="$1"
  GIT_REVISION="$2"
  TO_DIR="$3"
  [ ! -e $TO_DIR ] && git clone $GIT_REPO $TO_DIR && (cd $TO_DIR && git reset --hard $GIT_REVISION)
}


build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && make clean &&  make -j $JOBS obj/libre2.a)
}

get_git_revision https://github.com/google/re2.git 499ef7eff7455ce9c9fae86111d4a77b6ac335de SRC
build_lib
#build_fuzzer

#if [[ $FUZZING_ENGINE == "hooks" ]]; then
#  # Link ASan runtime so we can hook memcmp et al.
#  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
#fi
set -x
$CXX $CXXFLAGS -std=c++11 -O2 -c ./afl_driver.cpp
$CXX $CXXFLAGS ../target.cc  -I BUILD/ BUILD/obj/libre2.a -lpthread ./afl_driver.o -o ./target-re2
