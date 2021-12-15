cmake_minimum_required(VERSION 3.22)
project(SwigExample)

set(CMAKE_CXX_STANDARD 20)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install-${CMAKE_BUILD_TYPE}" CACHE PATH "default install prefix" FORCE)
endif (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

set(SwigBuildPrefix "${CMAKE_BINARY_DIR}/lib/site-packages")
if (NOT EXISTS "${SwigBuildPrefix}")
    file(MAKE_DIRECTORY "${SwigBuildPrefix}")
endif ()

# Add a swig target to cmake build system
# Arguments
# ----------
#   SWIG_TARGET_NAME: What to call the swig target
#   SWIG_INTERFACE_FILE one or more swig interface files
#   Any other argument to this function is assumed to be source files
#   to be added to the swig target.
macro(add_my_swig_library SWIG_TARGET_NAME SWIG_INTERFACE_FILE)
    # no harm in finding python here
    find_package(Python COMPONENTS Interpreter Development NumPy REQUIRED)
    find_package(SWIG 4.0.1 REQUIRED
            COMPONENTS python
            )
    include(UseSWIG)

    set_source_files_properties(${SWIG_INTERFACE_FILE}
            PROPERTIES
            CPLUSPLUS ON
            SWIG_FLAGS
            -py3
            )

    swig_add_library(${SWIG_TARGET_NAME}
            TYPE MODULE
            LANGUAGE python
            SOURCES ${SWIG_INTERFACE_FILE} ${ARGN}
            )

    set_target_properties(
            ${SWIG_TARGET_NAME} PROPERTIES
            # make the command "target_include_directories" work with swig targets
            SWIG_USE_TARGET_INCLUDE_DIRECTORIES TRUE
            OUTPUT_NAME ${SWIG_TARGET_NAME}
    )

    target_include_directories(${SWIG_TARGET_NAME} PUBLIC
            "${ThisSourceDirectory}" # test root
            "${CMAKE_CURRENT_SOURCE_DIR}"
            $<TARGET_PROPERTY:SwigExample-static,INCLUDE_DIRECTORIES>
            "${Python_INCLUDE_DIRS}"
            "${Python_NumPy_INCLUDE_DIRS}"
            )
    if (NOT APPLE)
        target_link_libraries(${SWIG_TARGET_NAME} PUBLIC
                Python::Python # remember, includes will just come with linking Python::Python
                Python::NumPy  # remember, includes will just come with linking Python::NumPy
                )
    else ()

        set_target_properties(${SWIG_TARGET_NAME}
                PROPERTIES
                LINK_FLAGS "-undefined dynamic_lookup"
                INSTALL_RPATH "@loader_path/../../lib;@loader_path/../../bin;@loader_path/;@loader_path/..@loader_path/../.."
                INSTALL_NAME_DIR "@rpath"
                )
        swig_link_libraries(${SWIG_TARGET_NAME} PUBLIC SwigExample-static)
    endif ()

    set(SWIG_GENERATED_PYTHON_FILE "${CMAKE_CURRENT_BINARY_DIR}/${SWIG_TARGET_NAME}.py")
    message(STATUS "Swig generated .py for target \"${SWIG_TARGET_NAME}\" will be copied to \"${SwigBuildPrefix}\" in the build tree after the target is built")


    # copy Python files to build tree post build
    add_custom_command(
            TARGET ${SWIG_TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${SWIG_TARGET_NAME}> "${SwigBuildPrefix}"
    )
    add_custom_command(
            TARGET ${SWIG_TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "${SWIG_GENERATED_PYTHON_FILE}" "${SwigBuildPrefix}"
    )
endmacro()


add_subdirectory(src)