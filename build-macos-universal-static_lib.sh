#!/usr/bin/env bash

set -e

BUILD_DIR=${BUILD_DIR:=build/static_lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static_lib}

cd $(dirname $0)

(
    ARCH=arm64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH $CMAKE_OPTIONS"
    SKIP_TESTS=true
    source ./build-static_lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH -D CMAKE_SYSTEM_NAME=Darwin -D CMAKE_SYSTEM_PROCESSOR=$ARCH $CMAKE_OPTIONS"
    SKIP_TESTS=true
    source ./build-static_lib.sh
)

lipo -remove x86_64 -output \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.a \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.a \
    | true

lipo -remove arm64 -output \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.a \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.a \
    | true

mkdir -p $OUTPUT_DIR/lib

lipo -create -output \
    $OUTPUT_DIR/lib/libtensorflowlite.a \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.a \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.a

cp -r $OUTPUT_DIR-arm64/include $OUTPUT_DIR

(
    ARCH=arm64
    BUILD_DIR=$BUILD_DIR-$ARCH
    TESTS_CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH $TESTS_CMAKE_OPTIONS"
    SKIP_BUILD=true
    source ./build-static_lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    TESTS_CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH -D CMAKE_SYSTEM_NAME=Darwin -D CMAKE_SYSTEM_PROCESSOR=$ARCH $TESTS_CMAKE_OPTIONS"
    SKIP_BUILD=true
    source ./build-static_lib.sh
)
