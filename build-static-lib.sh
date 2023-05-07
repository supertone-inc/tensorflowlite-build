#!/usr/bin/env bash

set -e

SOURCE_DIR=${SOURCE_DIR:=static-lib}
BUILD_DIR=${BUILD_DIR:=build/static-lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static-lib}
TENSORFLOW_SOURCE_DIR=${TENSORFLOW_SOURCE_DIR:=tensorflow}
TENSORFLOW_VERSION=${TENSORFLOW_VERSION:=$(cat TENSORFLOW_VERSION)}
CMAKE_OPTIONS=$CMAKE_OPTIONS
CMAKE_BUILD_OPTIONS=$CMAKE_BUILD_OPTIONS
TESTS_CMAKE_OPTIONS=$TESTS_CMAKE_OPTIONS
TESTS_CMAKE_BUILD_OPTIONS=$TESTS_CMAKE_BUILD_OPTIONS
SKIP_BUILD=$SKIP_BUILD
SKIP_TESTS=$SKIP_TESTS

case $(uname -s) in
Darwin) CPU_COUNT=$(sysctl -n hw.physicalcpu) ;;
Linux) CPU_COUNT=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}') ;;
*) CPU_COUNT=$NUMBER_OF_PROCESSORS ;;
esac
PARALLEL_JOB_COUNT=${PARALLEL_JOB_COUNT:=$CPU_COUNT}

(
    git submodule update --init --depth=1 $TENSORFLOW_SOURCE_DIR
    cd $TENSORFLOW_SOURCE_DIR
    git fetch origin --tags --depth=1
    if [ $TENSORFLOW_VERSION != $(git describe --tags --abbrev=0 | sed 's/^v//') ]; then
        git checkout v$TENSORFLOW_VERSION
    fi
    git submodule update --init --depth=1 --recursive
)

if [ "$SKIP_BUILD" != true ]; then
    cmake \
        -S $SOURCE_DIR \
        -B $BUILD_DIR \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_CONFIGURATION_TYPES=Release \
        -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
        -D TENSORFLOW_SOURCE_DIR=$(realpath $TENSORFLOW_SOURCE_DIR) \
        $CMAKE_OPTIONS
    cmake \
        --build $BUILD_DIR \
        --config Release \
        --parallel $PARALLEL_JOB_COUNT \
        $CMAKE_BUILD_OPTIONS
    cmake --install $BUILD_DIR --config Release
fi

if [ "$SKIP_TESTS" != true ]; then
    cmake \
        -S $SOURCE_DIR/tests \
        -B $BUILD_DIR/tests \
        -D TENSORFLOW_SOURCE_DIR=$(realpath $TENSORFLOW_SOURCE_DIR) \
        -D TFLITE_INCLUDE_DIR=$(realpath $OUTPUT_DIR/include) \
        -D TFLITE_LIB_DIR=$(realpath $OUTPUT_DIR/lib) \
        $TESTS_CMAKE_OPTIONS
    cmake --build $BUILD_DIR/tests $TESTS_CMAKE_BUILD_OPTIONS
    ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
fi
