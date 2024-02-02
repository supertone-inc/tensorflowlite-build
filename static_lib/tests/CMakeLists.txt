cmake_minimum_required(VERSION 3.24)
project(tests)

set(TFLITE_SOURCE_DIR ${TENSORFLOW_SOURCE_DIR}/tensorflow/lite)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(CMAKE_MODULE_PATH ${TFLITE_SOURCE_DIR}/tools/cmake/modules ${CMAKE_MODULE_PATH})

find_package(googletest REQUIRED)

add_executable(${PROJECT_NAME} model_test.cc)
target_include_directories(${PROJECT_NAME} PRIVATE
    ${TFLITE_INCLUDE_DIR}
    ${TENSORFLOW_SOURCE_DIR}
    ${TENSORFLOW_SOURCE_DIR}/third_party/xla/third_party/tsl
    ${CMAKE_CURRENT_BINARY_DIR}/../abseil-cpp
    ${CMAKE_CURRENT_BINARY_DIR}/../eigen
    ${CMAKE_CURRENT_BINARY_DIR}/../ml_dtypes
    ${CMAKE_CURRENT_BINARY_DIR}/../ml_dtypes/ml_dtypes
)
target_link_directories(${PROJECT_NAME} PRIVATE ${TFLITE_LIB_DIR})
target_link_libraries(${PROJECT_NAME} gtest_main tensorflowlite)

if(UNIX AND NOT APPLE)
    target_compile_options(gtest PRIVATE -Wno-maybe-uninitialized)
    target_link_libraries(${PROJECT_NAME} dl)
endif()

enable_testing()
add_test(
    NAME ${PROJECT_NAME}
    COMMAND ${PROJECT_NAME}
    WORKING_DIRECTORY ${TENSORFLOW_SOURCE_DIR}
)
