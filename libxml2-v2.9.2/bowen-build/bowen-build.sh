#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#. $(dirname $0)/../custom-build.sh $1 $2
#. $(dirname $0)/../common.sh
#export CXX=afl/afl-gcc
#export CC=afl/afl-g++
export CXX=clang++
export CC=clang
#export CFLAGS="-O2 -fno-omit-frame-pointer -fsanitize=address"
#export CXXFLAGS="-O2 -fno-omit-frame-pointer -fsanitize=address"
export CFLAGS="-O2 -fno-omit-frame-pointer"
export CXXFLAGS="-O2 -fno-omit-frame-pointer"

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
  (cd BUILD && ./autogen.sh && CCLD="$CXX $CXXFLAGS" ./configure --disable-shared && make -j $JOBS)
}

get_git_tag https://gitlab.gnome.org/GNOME/libxml2.git v2.9.2 SRC
#get_git_revision https://github.com/google/afl e9be6bce2282e8db95221c9a17fd10aba9e901bc afl
build_lib
#build_fuzzer

#$CC $CFLAGS -c -w afl/llvm_mode/afl-llvm-rt.o.c
$CXX $CXXFLAGS -std=c++11 -O2 -c ./afl_driver.cpp
#ar r $LIB_FUZZING_ENGINE afl_driver.o afl-llvm-rt.o.o
#rm *.o

#cp afl/dictionaries/xml.dict .

#if [[ $FUZZING_ENGINE == "hooks" ]]; then
#  # Link ASan runtime so we can hook memcmp et al.
#  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
#fi

set -x
#$CXX $CXXFLAGS -std=c++11  ../target.cc -I BUILD/include BUILD/.libs/libxml2.a $LIB_FUZZING_ENGINE -lz -o ./target-libxml2
#$CXX $CXXFLAGS -std=c++11  ../target.cc -I BUILD/include BUILD/.libs/libxml2.a -lz afl-llvm-rt.o.o afl_driver.o -o ./target-libxml2
$CXX $CXXFLAGS -std=c++11  ../target.cc -I BUILD/include BUILD/.libs/libxml2.a -lz afl_driver.o -o ./target-libxml2
