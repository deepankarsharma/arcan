set(TSM_SOURCES
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/shl-pty.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/shl-ring.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/shl_htable.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/tsm_screen.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/tsm_unicode.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/tsm_vte.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/tsm_vte_charsets.c
	${CMAKE_CURRENT_SOURCE_DIR}/tsm/wcwidth.c
	${TERM_AUX_SOURCES}
)

if (DEBUG_TSM)
	add_executable(tsm_debug tsmdebug.c ${TSM_SOURCES})
	target_include_directories(tsm_debug PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/tsm)
	target_link_libraries(tsm_debug ${STDLIB} util)
endif()

if (FREETYPE_LIBRARIES)
	set(TERM_AUX_LIBS ${FREETYPE_LIBRARIES})
	list(APPEND TSM_SOURCES ${FSRV_ROOT}/../engine/arcan_ttf.c)
endif()

set(TERMINAL_SOURCES
	${TSM_SOURCES}
	${CMAKE_CURRENT_SOURCE_DIR}/arcterm.c
	PARENT_SCOPE
)

if (STATIC_FREETYPE)
	set(TERMINAL_DEPENDENCIES
		Freetype
		PARENT_SCOPE)
endif()

set(TERMINAL_LIBS
	util
	${TERM_AUX_LIBS}
	PARENT_SCOPE
)

set(TINC
	${FSRV_ROOT}/../engine
	${CMAKE_CURRENT_SOURCE_DIR}/tsm
)

if (FREETYPE_LIBRARIES)
	set(TERMINAL_DEFS
		TTF_SUPPORT
		SHMIF_TTF
		PARENT_SCOPE
	)

	set(TINC_AUX
		${TERMINAL_INCLUDE_DIRS}
		${FREETYPE_INCLUDE_DIRS}
	)
endif()

set(TERMINAL_INCLUDE_DIRS ${TINC} ${TINC_AUX} PARENT_SCOPE)
