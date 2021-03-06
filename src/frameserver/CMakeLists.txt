# Expects:
#  FSRV_PLATFORM (defined by platforms/CMakeLists.*)
#  FSRV_INCLUDES (defined by CMakeLists.txt + platforms/CMakeLists.*)
#  arcan_shmif (target)

# Options:
#  [ SPLIT_FRAMESERVER ] (different outputs)
#  [ DISABLE_FRAMESERVERS ] ignored entirely
#  FSRV_[ATYPE = subgroup (if not set, default is used)
#  FSRV_[ATYPE = subgroup]_REQUIRED (set if the module should fail on deps)
#
# Defines:
#  FSRV_MODES (list of ENABLE_FSRV_ATYPE)
#  FRAMESERVER_MODESTRING (exposed to scripting API)
#

if (NOT FSRV_PLATFORM)
	set(FSRV_PLATFORM ${FSRV_PLATFORM}
		${CMAKE_CURRENT_SOURCE_DIR}/frameserver.h
		${CMAKE_CURRENT_SOURCE_DIR}/frameserver.c
	)
endif()

set(FSRV_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
set(FSRV_ROOT ${FSRV_ROOT} PARENT_SCOPE)

set(FRAMESERVER_MODESTRING " ")

set(ARCHETYPES
	terminal
	net
	game
	decode
	encode
	remoting
	avfeed
)

foreach(archetype ${ARCHETYPES})
	add_subdirectory(${archetype})
endforeach()

#
# afsrv is a chainloader, it takes a mode as first argument that
# matches any of the specified archetypes to allow for a non-interactive,
# non-parsing loader that can be given additional capabilities / privileges
# that are then dropped when setting up the specific sandbox.
#
# it is also used to track descriptor / environment leaks from the parent
#
add_executable(arcan_frameserver frameserver.c)
target_compile_definitions(arcan_frameserver PRIVATE AFSRV_CHAINLOADER)
install(TARGETS arcan_frameserver DESTINATION bin)
amsg("${CL_YEL}Frameservers:${CL_GRN} ${FRAMESERVER_MODESTRING}${CL_RST}")
set(FRAMESERVER_MODESTRING ${FRAMESERVER_MODESTRING} PARENT_SCOPE)
