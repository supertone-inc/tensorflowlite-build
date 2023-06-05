cmake_minimum_required(VERSION 3.24)
project(tensorflowlite)

set(TF_SOURCE_DIR ${TENSORFLOW_SOURCE_DIR}/tensorflow)
set(TFLITE_SOURCE_DIR ${TF_SOURCE_DIR}/lite)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(CMAKE_INSTALL_MESSAGE NEVER)

add_subdirectory(${TFLITE_SOURCE_DIR} tensorflow-lite EXCLUDE_FROM_ALL)

add_library(telemetry STATIC ${TFLITE_SOURCE_DIR}/profiling/telemetry/telemetry.cc)
target_include_directories(telemetry PUBLIC ${TENSORFLOW_SOURCE_DIR})

include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} tensorflow-lite telemetry)

install(
    FILES ${TF_SOURCE_DIR}/core/public/version.h
    DESTINATION include/tensorflow/core/public/
)
install(
    DIRECTORY ${TFLITE_SOURCE_DIR}/
    DESTINATION include/tensorflow/lite/
    FILES_MATCHING
    PATTERN "*.h"
)
install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/flatbuffers/include/
    TYPE INCLUDE
)
install(CODE "execute_process( \
    COMMAND find ${CMAKE_INSTALL_PREFIX}/include -type d -empty -delete \
)")

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
    TYPE LIB
)
