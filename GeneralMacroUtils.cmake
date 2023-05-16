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
MACRO(SETUP_CONFIG_LINK_FLAGS _TARGET_NAME _TARGET_TYPE)
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

ENDMACRO(SETUP_CONFIG_LINK_FLAGS _TARGET_NAME _TARGET_TYPE)