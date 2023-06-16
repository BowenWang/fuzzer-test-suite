#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#. $(dirname $0)/../custom-build.sh $1 $2
#. $(dirname $0)/../common.sh
export CXX=clang++
export CC=clang

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
  (cd BUILD/build && ./autogen.sh && cd .. && ./configure --disable-shared --without-nettle && make -j $JOBS)
}

get_git_revision https://github.com/libarchive/libarchive.git 51d7afd3644fdad725dd8faa7606b864fd125f88 SRC
build_lib
#build_fuzzer

# We don't need this
#if [[ $FUZZING_ENGINE == "hooks" ]]; then
#  # Link ASan runtime so we can hook memcmp et al.
#  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
#fi
#$CC $CFLAGS -c -w ./afl-llvm-rt.o.c
$CXX $CXXFLAGS -std=c++11 -O2 -c ./afl_driver.cpp
#ar r $LIB_FUZZING_ENGINE afl_driver.o afl-llvm-rt.o.o
#rm *.o

set -x
$CXX $CXXFLAGS -std=c++11 ./libarchive_fuzzer.cc -I BUILD/libarchive BUILD/.libs/libarchive.a $LIB_FUZZING_ENGINE -lz  ./afl_driver.o -lbz2 -lxml2 -lcrypto -lssl -llzma -o ./target-libarchive
