set(target SwigExample)
add_library(${target}-static STATIC SwigExample.h)
set_target_properties(${target}-static PROPERTIES LINKER_LANGUAGE CXX)
target_include_directories(${target}-static PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

add_my_swig_library(swig_example SwigExample.i SwigExample.h SwigExample.cpp)
add_dependencies(swig_example ${target}-static)