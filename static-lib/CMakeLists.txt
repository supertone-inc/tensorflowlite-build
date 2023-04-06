cmake_minimum_required(VERSION 3.24)
project(tensorflowlite)

add_subdirectory(${TENSORFLOW_SOURCE_DIR}/tensorflow/lite tensorflow-lite EXCLUDE_FROM_ALL)
get_target_property(libraries tensorflow-lite LINK_LIBRARIES)
list(REMOVE_ITEM libraries
    Eigen3::Eigen
    NEON_2_SSE::NEON_2_SSE
    absl::variant
    gemmlowp
    ruy::ruy
)

include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} ${libraries})

install(
    DIRECTORY ${TENSORFLOW_SOURCE_DIR}/tensorflow/lite/
    DESTINATION include/tensorflow/lite/
    FILES_MATCHING
    PATTERN "*.h"
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
