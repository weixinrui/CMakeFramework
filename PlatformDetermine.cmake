#[=======================================================================[.rst:
Description:
ZS_WINDOWS
ZS_WINDOWS_BUILD_32
ZS_WINDOWS_BUILD_64
ZS_MAC
Z S_MAC_BUILD_XX
ZS_UNIX
ZS_UNIX_BUILD_XX
#]=======================================================================]
SET(WINDOWS 0)
SET(WINDOWS_BUILD_32 0)
SET(WINDOWS_BUILD_64 0)
SET(MAC 0)
SET(MAC_BUILD_XX 0)
SET(UNIX 0)
SET(UNIX_BUILD_XX 0)

IF(WIN32) 
    SET(ZS WINDOWS 1) 
    IF(CMAKE_CL_64)
        SET(WINDOWS_BUILD_64 1)
    ELSE()
        SET(WINDOWS_BUILD_32 1)
    ENDIF(CMAKE_CL_64) 

    IF(MSVC_VERSION LESS 1900)
        MESSAGE(FATAL_ERROR "zsoft not support compiler")
    ELSEIF(MSVC_VERSION LESS 1910)
        SET(MSVC_140 1)
    ELSE()
        SET(MSVC_141 1)
    ENDIF() 
ENDIF(WIN32) 

IF(APPLE) 
    SET(MAC 1)
    SET(MAC_BUILD_XX 1)
ENDIF(APPLE) 

IF(UNIX)
    SET(UNIX 1)
    SET(UNIX_BUILD 1)
ENDIF() 

IF(WINDOWS_BUILD_32)
    MESSAGE("zsoft build windows 32")
ELSEIF(WINDOWS_BUILD_64)
    MESSAGE("zsoft build windows 64")
ELSEIF(MAC_BUILD_XX)
    MESSAGE("zsoft build mac xx")
ELSEIF(UNIX_BUILD)
    MESSAGE("zsoft build unix xx")
ELSE()
    MESSAGE(FATAL_ERROR "zsoft build unknow")
ENDIF() 