#!/usr/bin/env bash

set -e

BUILD_DIR=${BUILD_DIR:=build/static-lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static-lib}
TENSORFLOW_VERSION=${TENSORFLOW_VERSION:=$(cat TENSORFLOW_VERSION)}

(
    ARCH=arm64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH"
    SKIP_TESTS=true
    source ./build-static-lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    OUTPUT_DIR=$OUTPUT_DIR-$ARCH
    CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH"
    SKIP_TESTS=true
    source ./build-static-lib.sh
)

lipo -remove x86_64 -output \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a

lipo -remove arm64 -output \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a

mkdir -p $OUTPUT_DIR/lib

lipo -create -output \
    $OUTPUT_DIR/lib/libtensorflowlite.$TENSORFLOW_VERSION.a \
    $OUTPUT_DIR-arm64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a \
    $OUTPUT_DIR-x86_64/lib/libtensorflowlite.$TENSORFLOW_VERSION.a

ln -sf libtensorflowlite.$TENSORFLOW_VERSION.a $OUTPUT_DIR/lib/libtensorflowlite.a

cp -r $OUTPUT_DIR-x86_64/include $OUTPUT_DIR

(
    ARCH=arm64
    BUILD_DIR=$BUILD_DIR-$ARCH
    TESTS_CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH"
    SKIP_BUILD=true
    source ./build-static-lib.sh
)

(
    ARCH=x86_64
    BUILD_DIR=$BUILD_DIR-$ARCH
    TESTS_CMAKE_OPTIONS="-D CMAKE_OSX_ARCHITECTURES=$ARCH"
    SKIP_BUILD=true
    source ./build-static-lib.sh
)
