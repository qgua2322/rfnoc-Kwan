INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_KWAN_CROSS kwan_cross)

FIND_PATH(
    KWAN_CROSS_INCLUDE_DIRS
    NAMES kwan_cross/api.h
    HINTS $ENV{KWAN_CROSS_DIR}/include
        ${PC_KWAN_CROSS_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    KWAN_CROSS_LIBRARIES
    NAMES gnuradio-kwan_cross
    HINTS $ENV{KWAN_CROSS_DIR}/lib
        ${PC_KWAN_CROSS_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(KWAN_CROSS DEFAULT_MSG KWAN_CROSS_LIBRARIES KWAN_CROSS_INCLUDE_DIRS)
MARK_AS_ADVANCED(KWAN_CROSS_LIBRARIES KWAN_CROSS_INCLUDE_DIRS)

