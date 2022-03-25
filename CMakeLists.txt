cmake_minimum_required(VERSION 3.16)
project(TFLiteBuildCheck)

set(CMAKE_CXX_STANDARD 14)

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
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(OS_NAME "windows")
    if (CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
        set(ARCH_NAME "x86_64")
    else()
        set(ARCH_NAME "x86")
    endif()
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Default build type: Release" FORCE)
endif()


set(TFLITE_DIST_DIR ${CMAKE_SOURCE_DIR}/tflite-dist/${TFLITE_VERSION}/${OS_NAME}-${ARCH_NAME})

message(STATUS "CMAKE_BUILD_TYPE is " ${CMAKE_BUILD_TYPE})
message(STATUS "APPLE is " ${APPLE})
message(STATUS "CMAKE_SYSTEM_NAME is " ${CMAKE_SYSTEM_NAME})
message(STATUS "CMAKE_SYSTEM_PROCESSOR is " ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS "ARCH_NAME is " ${ARCH_NAME})
message(STATUS "TFLITE_DIST_DIR is " ${TFLITE_DIST_DIR})

add_executable(${PROJECT_NAME} src/main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${TFLITE_DIST_DIR}/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${TFLITE_DIST_DIR}/lib)
target_link_libraries(${PROJECT_NAME} PRIVATE tensorflowlite)

if (OS_NAME STREQUAL "windows")
    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
                ${TFLITE_DIST_DIR}/lib/tensorflowlite.dll
                ${CMAKE_BINARY_DIR}/Release/
    )
endif()