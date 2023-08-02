SET(WORKSPACE_ROOT_DIR ${PROJECT_INCLUDE_ROOT}/..) 
SET(REPO_LIST
    applications
    behavmodeler
    backendapi
    commonbase
    dbroot
    ui
    framework
    geommodeler
    graphics
    assemmodeler
    docrepresentation
    lwrepresentation
    irepresentation
    geomentity
    wkroot
    geomkernel
    nondbroot
    resources
    viewrepresentation
) 
SET(EXIST_REPOS "")
FOREACh(_REPO {REPO LIST})
    IF(EXISTS ${WORKPACE_ROOT_DIR}/${_REPO})
        SET(EXIST_REPOS "${_REPO};${EXIST_REPOS}")
    ENDIF()
ENDFOREACH()

MACRO(WORKSPACE_SUBDIRECTORIES)
    FOREACH(_REPO ${EXIST_REPOS})
        ADD_SUBDIRECTORY(${WORKSPACE_ROOT_DIR}/${_REPO} ${WORKSPACE_ROOT_DIR}/build/${_REPO})
    ENDFOREACH()
ENDMACRO()