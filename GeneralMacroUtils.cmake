#[=======================================================[.rst:
    General macros for the CMake framework.
#]=======================================================]

# Check the eligibility of current CMake version
MACRO(BUILDER_GREATER MAJOR_VER MINOR_VER PATCH_VER)
    SET(VALID_BUILDER_VERSION OFF)
    IF(CMAKE_MAJOR_VERSION GREATER MAJOR_VER)
        SET(VALID_BUILDER_VERSION ON)
    ELSEIF(CMAKE_MAJOR_VERSION EQUAL MAJOR_VER)
        IF(CMAKE_MINOR_VERSION GREATER MINOR_VER)
            SET(VALID_BUILDER_VERSION ON)
        ELSEIF(CMAKE_MINOR_VERSION EQUAL MINOR_VER)
            IF(CMAKE_PATCH_VERSION EQUAL PATCH_VER)
                SET(VALID_BUILDER_VERSION ON)
            ENDIF()
        ENDIF()
    ENDIF()
ENDMACRO(BUILDER_GREATER MAJOR_VER MINOR_VER PATCH_VER)

# Add compile definitions for a TARGET
MACRO(SETUP_TARGET_CONFIG_DEFINITIONS _TARGET_NAME _TARGET_TYPE)
    SET(_CONFIG_DEFINITIONS_GENERATOR "$<1:${${_TARGET_TYPE}_GENERAL_DEFINITIONS}>")
    LIST(LENGTH GLOBAL_CONFIGURATION_TYPES _LIST_LEN)
    FOREACH(i RANGE ${_LIST_LEN})
        IF(${i} EQUAL ${_LIST_LEN})
            BREAK()
        ENDIF()
        LIST(GET GLOBAL_CONFIGURATION_TYPES ${i} _CONFIG)
        STRING(TOPPER ${_CONFIG} _CONFIG)
        SET(_CONFIG_ITEM "$<$<CONFIG:${_CONFIG}>:${${_TARGET_TYPE}_DEFINITIONS_${_CONFIG}}>")
        SET(_CONFIG_DEFINITIONS_GENERATOR "${_CONFIG_DEFINITIONS_GENERATOR};${_CONFIG_ITEM}")
    ENDFOREACH()
    SET_PROPERTY(TARGET ${_TARGET_NAME} APPEND PROPERTY COMPILE_DEFINITIONS ${_CONFIG_DEFINITIONS_GENERATOR})
ENDMACRO(SETUP_TARGET_CONFIG_DEFINITIONS _TARGET_NAME _TARGET_TYPE)

# Add compile options for a TARGET
MACRO(SETUP_TARGET_CONFIG_COMPILE_OPTIONS _TARGET_NAME _TARGET_TYPE)
    SET(_CONFIG_OPTIONS_GENERATOR "$<1:${${_TARGET_TYPE}_GENERAL_OPTIONSS}>")
    LIST(LENGTH GLOBAL_CONFIGURATION_TYPES _LIST_LEN)
    FOREACH(i RANGE ${_LIST_LEN})
        IF(${i} EQUAL ${_LIST_LEN})
            BREAK()
        ENDIF()
        LIST(GET GLOBAL_CONFIGURATION_TYPES ${i} _CONFIG)
        STRING(TOPPER ${_CONFIG} _CONFIG)
        SET(_CONFIG_ITEM "$<$<CONFIG:${_CONFIG}>:${${_TARGET_TYPE}_OPTIONS_${_CONFIG}}>")
        SET(_CONFIG_OPTIONS_GENERATOR "${_CONFIG_OPTIONS_GENERATOR};${_CONFIG_ITEM}")
    ENDFOREACH()
SET_PROPERTY(TARGET ${_TARGET_NAME} APPEND PROPERTY COMPILE_OPTIONS ${_CONFIG_OPTIONS_GENERATOR})
ENDMACRO(SETUP_TARGET_CONFIG_COMPILE_OPTIONS _TARGET_NAME _TARGET_TYPE)

# Add link flags for a TARGET
MACRO(SETUP_TARGET_CONFIG_LINK_FLAGS _TARGET_NAME _TARGET_TYPE)
    SET(_LINK_FLAGS)
    FOREACH(_ITEM ${GLOBAL_LINK_FLAGS})
        SET(_LINK_FLAGS "${LINK_FLAGS};${_ITEM}")
    ENDFOREACH()
    
    FOREACH(_ITEM ${${TARGET_TYPE}_GENERAL_LINK_FLAGS})
        SET(_LINK_FLAGS "${LINK_FLAGS};${_ITEM}")
    ENDFOREACH()

    SET_PROPERTY(TARGET ${_TARGET_NAME} PROPERTY LINK_FLAGS ${LINK_FLAGS})

    FOREACH(_CONFIG ${GLOBAL_CONFIGURATION_TYPES})
        STRING(TOPPER ${_CONFIG} _CONFIG)
        SET(LINK_FLAGS_${_CONFIG})

        FOREACH(_ITEM ${GLOBAL_LINK_FLAGS_${_CONFIG}})
            SET(_LINK_FLAGS_${_CONFIG} "${_LINK_FLAGS_${_CONFIG}};${_ITEM}")
        ENDFOREACH()

        FOREACH(_ITEM ${${TARGET_TYPE}_LINK_FLAGS_${_CONFIG}})
            SET(_LINK_FLAGS_${_CONFIG} "${_LINK_FLAGS_${_CONFIG}};${_ITEM}")
        ENDFOREACH()
    SET_PROPERTY(TARGET ${_TARGET_NAME} PROPERTY LINK_FLAGS_${_CONFIG} _LINK_FLAGS_${_CONFIG})
    ENDFOREACH()

ENDMACRO(SETUP_TARGET_CONFIG_LINK_FLAGS _TARGET_NAME _TARGET_TYPE)

MACRO(SETUP_APPLICATION)
    IF(APPLICATION_MOC_SRCS)
        INCLUDE_DIRECTORIES(
            ${QT_ROOT}/include
            ${APPLICATION_MOC_INCLUDE_DIRECTORIES}/
        )
        FOREACH(MOC_SRC ${APPLICATION_MOC_SRCS})
            QT5_WRAP_CPP(_APPLICATION_MOC_CPP ${MOC_SRC} OPTIONS -f{MOC_SRC} OPTIONS -DHAVE_QT5)
        ENDFOREACH()
    ENDIF()
    QT5_WRAP_UI(_APPLICATION_UI_CPP ${APPLICATION_UI_FORMS})
    IF(DEFINED APPLICATION_RESOURCES)
        QT5_ADD_RESOURCES(_APPLICATION_QRC_SRCS ${APPLICATION_RESOURCES})
    ENDIF()

    ## Generate a rc file
    CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/Resource.rc.in ${CMAKE_BINARY_DIR}/${MODULE_GROUP_NAME}-Resource.rc)

    ## Add paths of packages to link directories
    LINK_DIRECTORIES(${LIB_DIRS}
        $<$<CONFIG:RELEASE>:${CMAKE_INSTALL_PREFIX}/Release/lib>
        $<$<CONFIG:DEBUG>:${CMAKE_INSTALL_PREFIX}/DEBUG/lib>
    )

    ADD_EXECUTABLE(${APPLICATION_NAME}
        ${APPLICATION_INCLUDE}
        ${APPLICATION_INC}
        ${APPLICATION_SRC}
        ${_APPLICATION_MOC_CPP}
        ${_APPLICATION_UI_CPP}
        ${_APPLICATION_QRC_SRCS}
        ${CMAKE_BINARY_DIR}/${MODULE_GROUP_NAME}-Resource.rc
    )

    IF(NOT APPLICATION_CUSTOM_GROUP)
        SOURCE_GROUP("include" FILES ${APPLICATION_INCLUDE})
        SOURCE_GROUP("inc" FILES ${APPLICATION_INC})
        SOURCE_GROUP("src" FILES ${APPLICATION_SRC})
    ENDIF()

    IF(APPLICATION_PCH_ENABLE)
        IF(WINDOWS)
            SET_TARGET_PROPERTIES(${APPLICATION_NAME} PEOPERTIES COMPILE_FLAGS 
                "/Yu${APPLICATION_PCH_HEADER_FILE} /Fi${APPLICATION_PCH_HEADER_FILE}"
            )
            
            SET_SOURCE_FILES_PROPERTIES(${APPLICATION_PCH_SOURCE_FILE} PEOPERTIES COMPILE_FLAGS
                "Yc${APPLICATION_PCH_HEADER_FILE}"
            )
        ELSE()
            MESSAGE(FATAL_ERROR "Current code does not support PCH.")
        ENDIF()
    ENDIF()

    FOREACH(_CONFIG ${GLOBAL_CONFIGURATION_TYPES})
        STRING(TOPPER ${_CONFIG} _CONFIG)
        SET_TARGET_PROPERTIES(${APPLICATION_NAME} PROPERTIES "OUTPUT_NAME_${_CONFIG}")
    ENDFOREACH()

    SET_TARGET_PROPERTIES(${APPLICATION_NAME} PROPERTIES FOLDER ${APPLICATION_FOLDER})
    SET_TARGET_PROPERTIES(${APPLICATION_NAME} PROPERTIES FOLDER ${APPLICATION_INCLUDE})
    SETUP_TARGET_CONFIG_DEFINITIONS(${APPLICATION_NAME} "APPLICATION")
    SETUP_TARGET_CONFIG_COMPILE_OPTIONS(${APPLICATION_NAME} "APPLICATION")
    SETUP_TARGET_CONFIG_LINK_FLAGS(${APPLICATION_NAME} "APPLICATION")

    TARGET_INCLUDE_DIRECTORIES(${APPLICATION_NAME} PUBLIC
        ${APPLICATION_INDLUCE_DIRECTORIES_PUBLIC}
    )

    TARGET_INCLUDE_DIRECTORIES(${APPLICATION_NAME} INTERFACE
        ${APPLICATION_INDLUCE_DIRECTORIES_INTERFACE}
    )

    TARGET_INCLUDE_DIRECTORIES(${APPLICATION_NAME} PRIVATE
        ${APPLICATION_INDLUCE_DIRECTORIES_PRIVATE}
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} PUBLIC
        general "${APPLICATION_LINK_LIBRARIES_PUBLIC}"
        debug "${APPLICATION_LINK_LIBRARIES_PUBLIC_DEBUG}"
        optimized "${APPLICATION_LINK_LIBRARIES_PUBLIC_OPTIMIZED}"
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} INTERFACE
        general "${APPLICATION_LINK_LIBRARIES_INTERFACE}"
        debug "${APPLICATION_LINK_LIBRARIES_INTERFACE_DEBUG}"
        optimized "${APPLICATION_LINK_LIBRARIES_INTERFACE_OPTIMIZED}"
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} PRIVATE
        general "${APPLICATION_LINK_LIBRARIES_PRIVATE}"
        debug "${APPLICATION_LINK_LIBRARIES_PRIVATE_DEBUG}"
        optimized "${APPLICATION_LINK_LIBRARIES_PRIVATE_OPTIMIZED}"
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} PUBLIC
        ${APPLICATION_USE_MODULES_PUBLIC}
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} INTERFACE
        ${APPLICATION_USE_MODULES_INTERFACE}
    )

    TARGET_LINK_LIBRARIES(${APPLICATION_NAME} PRIVATE
        ${APPLICATION_USE_MODULES_PRIVATE}
    )

    # Used to build targets under a group(repository/module) via cmake --build --target ${MODULE_GROUP_NAME}
    ADD_DEPENDENCIES(${MODULE_GROUP_NAME} ${APPLICATION_NAME})
    FOREACH(_DEPEND ${APPLICATION_NAME_DEPENDENCIES})
        ADD_DEPENDENCIES(${APPLICATION_NAME} ${_DEPEND})
    ENDFOREACH()

    IF(APPLICATION_INSTALL)
        INSTALL(
            TARGET ${APPLICATION_NAME}
            RUNTIME DESTINATION $<CONFIG>/${GLOBAL_INSTALL_BINDIR}
            COMPOINENT ${MODULE_GROUP_NAME}
        )
    ENDIF()

ENDMACRO(SETUP_APPLICATION)

MACRO(SETUP_LIBRARY)
    IF(LIBRARY_MOC_SRCS)
        INCLUDE_DIRECTORIES(
            ${QT_ROOT}/include
            ${LIBRARY_MOC_INCLUDE_DIRECTORIES}
        )
        FOREACH(MOC_SRC LIBRARY_MOC_SRCS)
            QT5_WRAP_CPP(_LIBRARY_MOC_CPP ${MOC_SRC} OPTIONS -f{MOC_SRC} OPTIONS -DHAVE_QT5)
        ENDFOREACH()
    ENDIF()

    QT5_WRAP_UI(_LIBRARY_UI_CPP ${LIBRARY_UI_FORMS})

    IF(DEFINED LIBRARY_RESOURCES)
        QT5_ADD_RESOURCES(_LIBRARY_QRC_SRCS ${LIBRARY_RESOURCES})
    ENDIF()

    ## Generate a rc file
    CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/Resource.rc.in ${CMAKE_BINARY_DIR}/${MODULE_GROUP_NAME}-Resource.rc)
    
    ## Add paths of packages to link directories
    LINK_DIRECTORIES(${LIB_DIRS}
        $<$<CONFIG:RELEASE>:${CMAKE_INSTALL_PREFIX}/Release/lib>
        $<$<CONFIG:DEBUG>:${CMAKE_INSTALL_PREFIX}/DEBUG/lib>
    )

    ADD_LIBRARY(${LIBRARY_NAME}
        ${LIBRARY_INCLUDE}
        ${LIBRARY_INC}
        ${LIBRARY_SRC}
        ${_LIBRARY_MOC_CPP}
        ${_LIBRARY_UI_CPP}
        ${_LIBRARY_QRC_SRCS}
        ${CMAKE_BINARY_DIR}/${MODULE_GROUP_NAME}-Resource.rc
    )

    IF(NOT LIBRARY_CUSTOM_GROUP)
        SOURCE_GROUP("include" FILES ${LIBRARY_INCLUDE})
        SOURCE_GROUP("inc" FILES ${LIBRARY_INC})
        SOURCE_GROUP("src" FILES ${LIBRARY_SRC})
    ENDIF()

    IF(LIBRARY_PCH_ENABLE)
        IF(WINDOWS)
            SET_TARGET_PROPERTIES(${LIBRARY_NAME} PEOPERTIES COMPILE_FLAGS 
                "/Yu${LIBRARY_PCH_HEADER_FILE} /Fi${LIBRARY_PCH_HEADER_FILE}"
            )
            
            SET_SOURCE_FILES_PROPERTIES(${LIBRARY_PCH_SOURCE_FILE} PEOPERTIES COMPILE_FLAGS
                "Yc${LIBRARY_PCH_HEADER_FILE}"
            )
        ELSE()
            MESSAGE(FATAL_ERROR "Current code does not support PCH.")
        ENDIF()
    ENDIF()

    SET_TARGET_PROPERTIES(${LIBRARY_NAME} PROPERTIES FOLDER ${LIBRARY_FOLDER})
    SET_TARGET_PROPERTIES(${LIBRARY_NAME} PROPERTIES FOLDER ${LIBRARY_INCLUDE})
    SETUP_TARGET_CONFIG_DEFINITIONS(${LIBRARY_NAME} "LIBRARY")
    SETUP_TARGET_CONFIG_COMPILE_OPTIONS(${LIBRARY_NAME} "LIBRARY")
    SETUP_TARGET_CONFIG_LINK_FLAGS(${LIBRARY_NAME} "LIBRARY")

    TARGET_INCLUDE_DIRECTORIES(${LIBRARY_NAME} PUBLIC
        ${LIBRARY_INDLUCE_DIRECTORIES_PUBLIC}
    )

    TARGET_INCLUDE_DIRECTORIES(${LIBRARY_NAME} INTERFACE
        ${LIBRARY_INDLUCE_DIRECTORIES_INTERFACE}
    )

    TARGET_INCLUDE_DIRECTORIES(${LIBRARY_NAME} PRIVATE
        ${LIBRARY_INDLUCE_DIRECTORIES_PRIVATE}
    )

    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} PUBLIC
        general "${LIBRARY_LINK_LIBRARIES_PUBLIC}"
        debug "${LIBRARY_LINK_LIBRARIES_PUBLIC_DEBUG}"
        optimized "${LIBRARY_LINK_LIBRARIES_PUBLIC_OPTIMIZED}"
    )

    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} INTERFACE
        general "${LIBRARY_LINK_LIBRARIES_INTERFACE}"
        debug "${LIBRARY_LINK_LIBRARIES_INTERFACE_DEBUG}"
        optimized "${LIBRARY_LINK_LIBRARIES_INTERFACE_OPTIMIZED}"
    )

    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} PRIVATE
        general "${LIBRARY_LINK_LIBRARIES_PRIVATE}"
        debug "${LIBRARY_LINK_LIBRARIES_PRIVATE_DEBUG}"
        optimized "${LIBRARY_LINK_LIBRARIES_PRIVATE_OPTIMIZED}"
    )
    
    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} PUBLIC
        ${LIBRARY_USE_MODULES_PUBLIC}
    )

    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} INTERFACE
        ${LIBRARY_USE_MODULES_INTERFACE}
    )

    TARGET_LINK_LIBRARIES(${LIBRARY_NAME} PRIVATE
        ${LIBRARY_USE_MODULES_PRIVATE}
    )

    # Used to build targets under a group(repository/module) via cmake --build --target ${MODULE_GROUP_NAME}
    ADD_DEPENDENCIES(${MODULE_GROUP_NAME} ${LIBRARY_NAME})
    FOREACH(_DEPEND ${LIBRARY_NAME_DEPENDENCIES})
        ADD_DEPENDENCIES(${LIBRARY_NAME} ${_DEPEND})
    ENDFOREACH()

    IF(LIBRARY_INSTALL)
        INSTALL(
            TARGET ${LIBRARY_NAME}
            RUNTIME DESTINATION $<CONFIG>/${GLOBAL_INSTALL_BINDIR}
            COMPOINENT ${MODULE_GROUP_NAME}
        )
    ENDIF()
ENDMACRO(SETUP_LIBRARY)

MACRO(SETUP_THIRDPARTY_PACKAGE _UPDATE_PKG) # The argument is to specify whether update thirdparty package
    SET(_VALID_PACKAGE_CONFIG "Debug;Release")
    IF(_UPDATE_PKG)
        SET(_UPDATE_PKG "-u")
    ELSE()
        SET(_UPDATE_PKG "")
    ENDIF()
    FOREACH(_CONFIG ${CMAKE_CONFIGURATION_TYPES})
        SET(CONAN_CONFIG_LOCATION ${CMAKE_BINARY_DIR}/deploy/conan/${MODULE_GROUP_NAME}/{_CONFIG})
        CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/../../${MODULE_GROUP_NAME}/confile.py.in
            ${CONAN_CONFIG_LOCATION}/conanfile.py @ONLY
        )
        IF(${_CONFIG} IN_LIST _VALID_PACKAGE_CONFIG)
            EXECUTE_PROCESS(
                conan install ${CONAN_CONFIG_LOCATION} -s build_type=${_CONFIG} -if ${CMAKE_BINARY_DIR} ${_UPDATE_PKG} --remote=gitlab
            )
        ENDIF()
    ENDFOREACH()
ENDMACRO(SETUP_THIRDPARTY_PACKAGE)