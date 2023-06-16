#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#. $(dirname $0)/../custom-build.sh $1 $2
#. $(dirname $0)/../common.sh
export CXX=g++
export CC=gcc

set -x
#build_fuzzer
$CC $CFLAGS -c ../sqlite3.c
$CC $CFLAGS -c ../ossfuzz.c

#if [[ $FUZZING_ENGINE == "hooks" ]]; then
#  # Link ASan runtime so we can hook memcmp et al.
#  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
#fi
$CXX $CXXFLAGS -std=c++11 -O2 -c ./afl_driver.cpp
$CXX $CXXFLAGS -pthread sqlite3.o ossfuzz.o ./afl_driver.o -ldl -o ./target-sqlite3
