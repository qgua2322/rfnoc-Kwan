# Copyright 2011,2012 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIRS})

list(APPEND kwan_cross_sources
    Latencytest_impl.cc
    Latencytest_block_ctrl_impl.cpp
)


set(kwan_cross_sources "${kwan_cross_sources}" PARENT_SCOPE)
if(NOT kwan_cross_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT kwan_cross_sources)

add_library(gnuradio-kwan_cross SHARED ${kwan_cross_sources})
target_link_libraries(gnuradio-kwan_cross ${Boost_LIBRARIES} ${GNURADIO_ALL_LIBRARIES} ${ETTUS_LIBRARIES})
set_target_properties(gnuradio-kwan_cross PROPERTIES DEFINE_SYMBOL "gnuradio_kwan_cross_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-kwan_cross PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
install(TARGETS gnuradio-kwan_cross
    LIBRARY DESTINATION lib${LIB_SUFFIX} # .so/.dylib file
    ARCHIVE DESTINATION lib${LIB_SUFFIX} # .lib file
    RUNTIME DESTINATION bin              # .dll file
)

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

include_directories(${CPPUNIT_INCLUDE_DIRS})

list(APPEND test_kwan_cross_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/test_kwan_cross.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/qa_kwan_cross.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/qa_Latencytest.cc
)

add_executable(test-kwan_cross ${test_kwan_cross_sources})

target_link_libraries(
  test-kwan_cross
  ${GNURADIO_RUNTIME_LIBRARIES}
  ${Boost_LIBRARIES}
  ${CPPUNIT_LIBRARIES}
  ${ETTUS_LIBRARIES}
  ${PC_ETTUS_LIBDIR}
  gnuradio-kwan_cross
)



GR_ADD_TEST(test_kwan_cross test-kwan_cross)
