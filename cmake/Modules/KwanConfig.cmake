INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_KWAN Kwan)

FIND_PATH(
    KWAN_INCLUDE_DIRS
    NAMES Kwan/api.h
    HINTS $ENV{KWAN_DIR}/include
        ${PC_KWAN_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    KWAN_LIBRARIES
    NAMES gnuradio-Kwan
    HINTS $ENV{KWAN_DIR}/lib
        ${PC_KWAN_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(KWAN DEFAULT_MSG KWAN_LIBRARIES KWAN_INCLUDE_DIRS)
MARK_AS_ADVANCED(KWAN_LIBRARIES KWAN_INCLUDE_DIRS)

