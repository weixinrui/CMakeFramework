#[=======================================================[.rst:
    PlatformDetermine for the CMake framework.
#]=======================================================]

SET(WINDOWS 0)
SET(WINDOWS_BUILD_32 0)
SET(WINDOWS_BUILD_64 0)

SET(MAC 0)
SET(MAC_BUILD_XX 0)

SET(UNIX 0)
SET(UNIX_BUILD_XX 0)

IF(WIN32)
    SET(WINDOWS 1)
    IF(CMAKE_CL_64)
        SET(WINDOWS_BUILD_64 1)
    ELSE()
        SET(WINDOWS_BUILD_32 1)
    ENDIF()

    IF(MSVC_VERSION LESS 1900)
        MESSAGE(FATAL_ERROR "XXX does not support the compiler")
    ELSEIF(MSVC_VERSION LESS 1910)
        SET(MSVC_140 1)
    ELSE()
        SET(MSVC_141 1)
    ENDIF()
ENDIF()

IF(APPLE)
    SET(MAC 1)
    SET(MAC_BUILD_XX 1)
ENDIF()

IF(UNIX)
    SET(UNIX 1)
    SET(UNIX_BUILD_XX 1)
ENDIF()

IF(WINDOWS_BUILD_32)
    MESSAGE("XXX build windows 32")
ELSEIF(WINDOWS_BUILD_64)
    MESSAGE("XXX build windows 64")
ELSEIF(MAC_BUILD_XX)
    MESSAGE("XXX build mac xx")
ELSEIF(UNIX_BUILD_XX)
    MESSAGE("XXX build unix xx")
ELSE()
    MESSAGE(FATAL_ERROR "XXX build unknown")
ENDIF()