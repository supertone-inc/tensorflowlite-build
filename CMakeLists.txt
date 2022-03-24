cmake_minimum_required(VERSION 3.16)
project(TFLiteBuildCheck)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(TFLITE_VERSION "2.7.1")

if (APPLE)
    set(OS_NAME "macos")
    execute_process(
        COMMAND uname -m
        OUTPUT_VARIABLE ARCH_NAME
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(OS_NAME "linux")
    set(ARCH_NAME ${CMAKE_SYSTEM_PROCESSOR})
endif()


set(TFLITE_DIST_DIR ${CMAKE_SOURCE_DIR}/tflite-dist/${TFLITE_VERSION}/${OS_NAME}-${ARCH_NAME})

message(STATUS "APPLE is " ${APPLE})
message(STATUS "CMAKE_SYSTEM_NAME is " ${CMAKE_SYSTEM_NAME})
message(STATUS "CMAKE_SYSTEM_PROCESSOR is " ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS "ARCH_NAME is " ${ARCH_NAME})
message(STATUS "CMAKE_SHARED_LIBRARY_SUFFIX is " ${CMAKE_SHARED_LIBRARY_SUFFIX})
message(STATUS "TFLITE_DIST_DIR is " ${TFLITE_DIST_DIR})

INCLUDE_DIRECTORIES(${TFLITE_DIST_DIR}/include)

find_library(
    LibTFLite
    NAMES libtensorflowlite${CMAKE_SHARED_LIBRARY_SUFFIX}
    PATHS ${TFLITE_DIST_DIR}/lib
    REQUIRED
    NO_CMAKE_FIND_ROOT_PATH
    )

add_executable(TFLiteBuildCheck src/main.cpp)
target_link_libraries(TFLiteBuildCheck ${LibTFLite})