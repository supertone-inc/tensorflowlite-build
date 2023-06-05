#!/usr/bin/env bash

set -e

BUILD_DIR=${BUILD_DIR:=build/static-lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static-lib}

cd $(dirname $0)

(
    ARCH=arm64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH $CMAKE_OPTIONS"
    SKIP_TESTS=true
    source ./build-static-lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH $CMAKE_OPTIONS"
    SKIP_TESTS=true
    source ./build-static-lib.sh
)

lipo -remove x86_64 -output \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.a \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.a

lipo -remove arm64 -output \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.a \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.a

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
    source ./build-static-lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    TESTS_CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH $TESTS_CMAKE_OPTIONS"
    SKIP_BUILD=true
    source ./build-static-lib.sh
)
