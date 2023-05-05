cmake_minimum_required(VERSION 3.24)
project(tensorflowlite)

set(TFLITE_SOURCE_DIR ${TENSORFLOW_SOURCE_DIR}/tensorflow/lite)

add_subdirectory(${TFLITE_SOURCE_DIR} tensorflow-lite EXCLUDE_FROM_ALL)
get_target_property(libraries tensorflow-lite LINK_LIBRARIES)
list(REMOVE_ITEM libraries
    Eigen3::Eigen
    NEON_2_SSE::NEON_2_SSE
    absl::variant
    gemmlowp
    ruy::ruy
)

add_library(telemetry STATIC ${TFLITE_SOURCE_DIR}/profiling/telemetry/telemetry.cc)
target_include_directories(telemetry PUBLIC ${TENSORFLOW_SOURCE_DIR})

include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME}
    tensorflow-lite
    telemetry
    ${libraries}
)

set(CMAKE_INSTALL_MESSAGE NEVER)

install(
    DIRECTORY ${TFLITE_SOURCE_DIR}/
    DESTINATION include/tensorflow/lite/
    FILES_MATCHING
    PATTERN "*.h"
)
install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/flatbuffers/include/
    DESTINATION include/
)
install(CODE "execute_process( \
    COMMAND find ${CMAKE_INSTALL_PREFIX}/include -type d -empty -delete \
)")

if(UNIX)
    execute_process(
        COMMAND bash "-c" "git describe --tags --abbrev=0 | sed 's/^v//'"
        WORKING_DIRECTORY ${TENSORFLOW_SOURCE_DIR}
        OUTPUT_VARIABLE TENSORFLOW_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/lib${PROJECT_NAME}.a
        RENAME lib${PROJECT_NAME}.${TENSORFLOW_VERSION}.a
        DESTINATION lib
    )
    install(CODE "execute_process( \
        COMMAND ${CMAKE_COMMAND} -E create_symlink \
        lib${PROJECT_NAME}.${TENSORFLOW_VERSION}.a \
        ${CMAKE_INSTALL_PREFIX}/lib/lib${PROJECT_NAME}.a \
    )")
else()
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.lib
        DESTINATION lib
    )
endif()
