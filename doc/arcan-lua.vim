" Language:	Lua 4.0, Lua 5.0, Lua 5.1 and Lua 5.2
" Maintainer:	Marcus Aurelius Farias <masserahguard-lua 'at' yahoo com>
" First Author:	Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:	2012 Aug 12
" Options:	lua_version = 4 or 5
"		lua_subversion = 0 (4.0, 5.0) or 1 (5.1) or 2 (5.2)
"		default 5.2

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("lua_version")
  " Default is lua 5.2
  let lua_version = 5
  let lua_subversion = 2
elseif !exists("lua_subversion")
  " lua_version exists, but lua_subversion doesn't. So, set it to 0
  let lua_subversion = 0
endif

syn case match

" syncing method
syn sync minlines=100

" Comments
syn keyword luaTodo            contained TODO FIXME XXX
syn match   luaComment         "--.*$" contains=luaTodo,@Spell
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaComment start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]"
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  " Comments in Lua 5.1: --[[ ... ]], [=[ ... ]=], [===[ ... ]===], etc.
  syn region luaComment        matchgroup=luaComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
endif

" First line may start with #!
syn match luaComment "\%^#!.*"

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks
syn region luaParen      transparent                     start='(' end=')' contains=ALLBUT,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=ALLBUT,luaBraceError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement

syn match  luaParenError ")"
syn match  luaBraceError "}"
syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" function ... end
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" if ... then
syn region luaIfThen transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4           contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaIn nextgroup=luaThenEnd skipwhite skipempty

" then ... end
syn region luaThenEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaThenEnd,luaIn

" elseif ... then
syn region luaElseifThen contained transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" else
syn keyword luaElse contained else

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>"          contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" repeat ... until
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>"   contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" while ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaIn nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2   contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd nextgroup=luaBlock skipwhite skipempty

syn keyword luaIn contained in

" other keywords
syn keyword luaStatement return local break
if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaStatement goto
  syn match luaLabel "::\I\i*::"
endif
syn keyword luaOperator and or not
syn keyword luaConstant nil
if lua_version > 4
  syn keyword luaConstant true false
endif

" Strings
if lua_version < 5
  syn match  luaSpecial contained "\\[\\abfnrtv\'\"]\|\\[[:digit:]]\{,3}"
elseif lua_version == 5
  if lua_subversion == 0
    syn match  luaSpecial contained #\\[\\abfnrtv'"[\]]\|\\[[:digit:]]\{,3}#
    syn region luaString2 matchgroup=luaString start=+\[\[+ end=+\]\]+ contains=luaString2,@Spell
  else
    if lua_subversion == 1
      syn match  luaSpecial contained #\\[\\abfnrtv'"]\|\\[[:digit:]]\{,3}#
    else " Lua 5.2
      syn match  luaSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
    endif
    syn region luaString2 matchgroup=luaString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
  endif
endif
syn region luaString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

" integer number
syn match luaNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match luaNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=\>"
" floating point number, starting with a dot, optional exponent
syn match luaNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match luaNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
if lua_version >= 5
  if lua_subversion == 1
    syn match luaNumber "\<0[xX]\x\+\>"
  elseif lua_subversion >= 2
    syn match luaNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
  endif
endif

syn keyword luaFunc assert collectgarbage dofile error next
syn keyword luaFunc print rawget rawset tonumber tostring type _VERSION

if lua_version == 4
  syn keyword luaFunc _ALERT _ERRORMESSAGE gcinfo
  syn keyword luaFunc call copytagmethods dostring
  syn keyword luaFunc foreach foreachi getglobal getn
  syn keyword luaFunc gettagmethod globals newtag
  syn keyword luaFunc setglobal settag settagmethod sort
  syn keyword luaFunc tag tinsert tremove
  syn keyword luaFunc _INPUT _OUTPUT _STDIN _STDOUT _STDERR
  syn keyword luaFunc openfile closefile flush seek
  syn keyword luaFunc setlocale execute remove rename tmpname
  syn keyword luaFunc getenv date clock exit
  syn keyword luaFunc readfrom writeto appendto read write
  syn keyword luaFunc PI abs sin cos tan asin
  syn keyword luaFunc acos atan atan2 ceil floor
  syn keyword luaFunc mod frexp ldexp sqrt min max log
  syn keyword luaFunc log10 exp deg rad random
  syn keyword luaFunc randomseed strlen strsub strlower strupper
  syn keyword luaFunc strchar strrep ascii strbyte
  syn keyword luaFunc format strfind gsub
  syn keyword luaFunc getinfo getlocal setlocal setcallhook setlinehook
elseif lua_version == 5
  syn keyword luaFunc getmetatable setmetatable
  syn keyword luaFunc ipairs pairs
  syn keyword luaFunc pcall xpcall
  syn keyword luaFunc _G loadfile rawequal require
  if lua_subversion == 0
    syn keyword luaFunc getfenv setfenv
    syn keyword luaFunc loadstring unpack
    syn keyword luaFunc gcinfo loadlib LUA_PATH _LOADED _REQUIREDNAME
  else
    syn keyword luaFunc load select
    syn match   luaFunc /\<package\.cpath\>/
    syn match   luaFunc /\<package\.loaded\>/
    syn match   luaFunc /\<package\.loadlib\>/
    syn match   luaFunc /\<package\.path\>/
    if lua_subversion == 1
      syn keyword luaFunc getfenv setfenv
      syn keyword luaFunc loadstring module unpack
      syn match   luaFunc /\<package\.loaders\>/
      syn match   luaFunc /\<package\.preload\>/
      syn match   luaFunc /\<package\.seeall\>/
    elseif lua_subversion == 2
      syn keyword luaFunc _ENV rawlen
      syn match   luaFunc /\<package\.config\>/
      syn match   luaFunc /\<package\.preload\>/
      syn match   luaFunc /\<package\.searchers\>/
      syn match   luaFunc /\<package\.searchpath\>/
      syn match   luaFunc /\<bit32\.arshift\>/
      syn match   luaFunc /\<bit32\.band\>/
      syn match   luaFunc /\<bit32\.bnot\>/
      syn match   luaFunc /\<bit32\.bor\>/
      syn match   luaFunc /\<bit32\.btest\>/
      syn match   luaFunc /\<bit32\.bxor\>/
      syn match   luaFunc /\<bit32\.extract\>/
      syn match   luaFunc /\<bit32\.lrotate\>/
      syn match   luaFunc /\<bit32\.lshift\>/
      syn match   luaFunc /\<bit32\.replace\>/
      syn match   luaFunc /\<bit32\.rrotate\>/
      syn match   luaFunc /\<bit32\.rshift\>/
    endif
    syn match luaFunc /\<coroutine\.running\>/
  endif
  syn match   luaFunc /\<coroutine\.create\>/
  syn match   luaFunc /\<coroutine\.resume\>/
  syn match   luaFunc /\<coroutine\.status\>/
  syn match   luaFunc /\<coroutine\.wrap\>/
  syn match   luaFunc /\<coroutine\.yield\>/
  syn match   luaFunc /\<string\.byte\>/
  syn match   luaFunc /\<string\.char\>/
  syn match   luaFunc /\<string\.dump\>/
  syn match   luaFunc /\<string\.find\>/
  syn match   luaFunc /\<string\.format\>/
  syn match   luaFunc /\<string\.gsub\>/
  syn match   luaFunc /\<string\.len\>/
  syn match   luaFunc /\<string\.lower\>/
  syn match   luaFunc /\<string\.rep\>/
  syn match   luaFunc /\<string\.sub\>/
  syn match   luaFunc /\<string\.upper\>/
  if lua_subversion == 0
    syn match luaFunc /\<string\.gfind\>/
  else
    syn match luaFunc /\<string\.gmatch\>/
    syn match luaFunc /\<string\.match\>/
    syn match luaFunc /\<string\.reverse\>/
  endif
  if lua_subversion == 0
    syn match luaFunc /\<table\.getn\>/
    syn match luaFunc /\<table\.setn\>/
    syn match luaFunc /\<table\.foreach\>/
    syn match luaFunc /\<table\.foreachi\>/
  elseif lua_subversion == 1
    syn match luaFunc /\<table\.maxn\>/
  elseif lua_subversion == 2
    syn match luaFunc /\<table\.pack\>/
    syn match luaFunc /\<table\.unpack\>/
  endif
  syn match   luaFunc /\<table\.concat\>/
  syn match   luaFunc /\<table\.sort\>/
  syn match   luaFunc /\<table\.insert\>/
  syn match   luaFunc /\<table\.remove\>/
  syn match   luaFunc /\<math\.abs\>/
  syn match   luaFunc /\<math\.acos\>/
  syn match   luaFunc /\<math\.asin\>/
  syn match   luaFunc /\<math\.atan\>/
  syn match   luaFunc /\<math\.atan2\>/
  syn match   luaFunc /\<math\.ceil\>/
  syn match   luaFunc /\<math\.sin\>/
  syn match   luaFunc /\<math\.cos\>/
  syn match   luaFunc /\<math\.tan\>/
  syn match   luaFunc /\<math\.deg\>/
  syn match   luaFunc /\<math\.exp\>/
  syn match   luaFunc /\<math\.floor\>/
  syn match   luaFunc /\<math\.log\>/
  syn match   luaFunc /\<math\.max\>/
  syn match   luaFunc /\<math\.min\>/
  if lua_subversion == 0
    syn match luaFunc /\<math\.mod\>/
    syn match luaFunc /\<math\.log10\>/
  else
    if lua_subversion == 1
      syn match luaFunc /\<math\.log10\>/
    endif
    syn match luaFunc /\<math\.huge\>/
    syn match luaFunc /\<math\.fmod\>/
    syn match luaFunc /\<math\.modf\>/
    syn match luaFunc /\<math\.cosh\>/
    syn match luaFunc /\<math\.sinh\>/
    syn match luaFunc /\<math\.tanh\>/
  endif
  syn match   luaFunc /\<math\.pow\>/
  syn match   luaFunc /\<math\.rad\>/
  syn match   luaFunc /\<math\.sqrt\>/
  syn match   luaFunc /\<math\.frexp\>/
  syn match   luaFunc /\<math\.ldexp\>/
  syn match   luaFunc /\<math\.random\>/
  syn match   luaFunc /\<math\.randomseed\>/
  syn match   luaFunc /\<math\.pi\>/
  syn match   luaFunc /\<io\.close\>/
  syn match   luaFunc /\<io\.flush\>/
  syn match   luaFunc /\<io\.input\>/
  syn match   luaFunc /\<io\.lines\>/
  syn match   luaFunc /\<io\.open\>/
  syn match   luaFunc /\<io\.output\>/
  syn match   luaFunc /\<io\.popen\>/
  syn match   luaFunc /\<io\.read\>/
  syn match   luaFunc /\<io\.stderr\>/
  syn match   luaFunc /\<io\.stdin\>/
  syn match   luaFunc /\<io\.stdout\>/
  syn match   luaFunc /\<io\.tmpfile\>/
  syn match   luaFunc /\<io\.type\>/
  syn match   luaFunc /\<io\.write\>/
  syn match   luaFunc /\<os\.clock\>/
  syn match   luaFunc /\<os\.date\>/
  syn match   luaFunc /\<os\.difftime\>/
  syn match   luaFunc /\<os\.execute\>/
  syn match   luaFunc /\<os\.exit\>/
  syn match   luaFunc /\<os\.getenv\>/
  syn match   luaFunc /\<os\.remove\>/
  syn match   luaFunc /\<os\.rename\>/
  syn match   luaFunc /\<os\.setlocale\>/
  syn match   luaFunc /\<os\.time\>/
  syn match   luaFunc /\<os\.tmpname\>/
  syn match   luaFunc /\<debug\.debug\>/
  syn match   luaFunc /\<debug\.gethook\>/
  syn match   luaFunc /\<debug\.getinfo\>/
  syn match   luaFunc /\<debug\.getlocal\>/
  syn match   luaFunc /\<debug\.getupvalue\>/
  syn match   luaFunc /\<debug\.setlocal\>/
  syn match   luaFunc /\<debug\.setupvalue\>/
  syn match   luaFunc /\<debug\.sethook\>/
  syn match   luaFunc /\<debug\.traceback\>/
  if lua_subversion == 1
    syn match luaFunc /\<debug\.getfenv\>/
    syn match luaFunc /\<debug\.setfenv\>/
    syn match luaFunc /\<debug\.getmetatable\>/
    syn match luaFunc /\<debug\.setmetatable\>/
    syn match luaFunc /\<debug\.getregistry\>/
  elseif lua_subversion == 2
    syn match luaFunc /\<debug\.getmetatable\>/
    syn match luaFunc /\<debug\.setmetatable\>/
    syn match luaFunc /\<debug\.getregistry\>/
    syn match luaFunc /\<debug\.getuservalue\>/
    syn match luaFunc /\<debug\.setuservalue\>/
    syn match luaFunc /\<debug\.upvalueid\>/
    syn match luaFunc /\<debug\.upvaluejoin\>/
  endif
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_lua_syntax_inits")
  if version < 508
    let did_lua_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink luaStatement		Statement
  HiLink luaRepeat		Repeat
  HiLink luaFor			Repeat
  HiLink luaString		String
  HiLink luaString2		String
  HiLink luaNumber		Number
  HiLink luaOperator		Operator
  HiLink luaIn			Operator
  HiLink luaConstant		Constant
  HiLink luaCond		Conditional
  HiLink luaElse		Conditional
  HiLink luaFunction		Function
  HiLink luaComment		Comment
  HiLink luaTodo		Todo
  HiLink luaTable		Structure
  HiLink luaError		Error
  HiLink luaParenError		Error
  HiLink luaBraceError		Error
  HiLink luaSpecial		SpecialChar
  HiLink luaFunc		Identifier
  HiLink luaLabel		Label

  delcommand HiLink
endif

syn keyword luaFunc null_surface
syn keyword luaFunc show_image
syn keyword luaFunc forward3d_model
syn keyword luaFunc net_refresh
syn keyword luaFunc freeze_image
syn keyword luaFunc image_parent
syn keyword luaFunc image_children
syn keyword luaFunc list_audio_inputs
syn keyword luaFunc set_led_rgb
syn keyword luaFunc toggle_mouse_grab
syn keyword luaFunc resize_cursor
syn keyword luaFunc utf8kind
syn keyword luaFunc bond_target
syn keyword luaFunc launch_target_capabilities
syn keyword luaFunc move_image
syn keyword luaFunc camtag_model
syn keyword luaFunc color_surface
syn keyword luaFunc alloc_surface
syn keyword luaFunc build_3dbox
syn keyword luaFunc frameserver_debugstall
syn keyword luaFunc max_current_image_order
syn keyword luaFunc image_shader
syn keyword luaFunc image_state
syn keyword luaFunc inputanalog_filter
syn keyword luaFunc video_displaymodes
syn keyword luaFunc cursor_position
syn keyword luaFunc input_filter_analog
syn keyword luaFunc target_graphmode
syn keyword luaFunc orient3d_model
syn keyword luaFunc image_origo_offset
syn keyword luaFunc reset_image_transform
syn keyword luaFunc resample_image
syn keyword luaFunc image_active_frame
syn keyword luaFunc define_nulltarget
syn keyword luaFunc scale_3dvertices
syn keyword luaFunc inputanalog_query
syn keyword luaFunc rendertarget_detach
syn keyword luaFunc save_screenshot
syn keyword luaFunc build_3dplane
syn keyword luaFunc copy_surface_properties
syn keyword luaFunc image_inherit_order
syn keyword luaFunc image_mask_clearall
syn keyword luaFunc transfer_image_transform
syn keyword luaFunc image_access_storage
syn keyword luaFunc image_set_txcos
syn keyword luaFunc pop_video_context
syn keyword luaFunc target_verbose
syn keyword luaFunc target_coreopt
syn keyword luaFunc image_texfilter
syn keyword luaFunc order_image
syn keyword luaFunc define_rendertarget
syn keyword luaFunc target_seek
syn keyword luaFunc pacify_target
syn keyword luaFunc system_identstr
syn keyword luaFunc scale3d_model
syn keyword luaFunc image_surface_properties
syn keyword luaFunc resource
syn keyword luaFunc target_configurations
syn keyword luaFunc launch_target
syn keyword luaFunc rendertarget_noclear
syn keyword luaFunc image_framecyclemode
syn keyword luaFunc fill_surface
syn keyword luaFunc rendertarget_forceupdate
syn keyword luaFunc net_authenticate
syn keyword luaFunc list_games
syn keyword luaFunc write_rawresource
syn keyword luaFunc inputanalog_toggle
syn keyword luaFunc image_get_txcos
syn keyword luaFunc map_video_display
syn keyword luaFunc benchmark_enable
syn keyword luaFunc strafe3d_model
syn keyword luaFunc current_context_usage
syn keyword luaFunc mesh_shader
syn keyword luaFunc image_mask_clear
syn keyword luaFunc image_set_txcos_default
syn keyword luaFunc force_image_blend
syn keyword luaFunc nudge_image
syn keyword luaFunc glob_resource
syn keyword luaFunc system_collapse
syn keyword luaFunc net_listen
syn keyword luaFunc net_push
syn keyword luaFunc benchmark_timestamp
syn keyword luaFunc recordtarget_gain
syn keyword luaFunc crop_image
syn keyword luaFunc system_context_size
syn keyword luaFunc play_audio
syn keyword luaFunc resize_image
syn keyword luaFunc raw_surface
syn keyword luaFunc switch_default_texmode
syn keyword luaFunc set_led
syn keyword luaFunc image_surface_resolve_properties
syn keyword luaFunc finalize_3dmodel
syn keyword luaFunc blend_image
syn keyword luaFunc link_image
syn keyword luaFunc load_asample
syn keyword luaFunc open_nonblock
syn keyword luaFunc input_samplebase
syn keyword luaFunc net_open
syn keyword luaFunc game_info
syn keyword luaFunc cursor_setstorage
syn keyword luaFunc capture_audio
syn keyword luaFunc image_surface_initial_properties
syn keyword luaFunc rendertarget_attach
syn keyword luaFunc target_displayhint
syn keyword luaFunc net_disconnect
syn keyword luaFunc target_flags
syn keyword luaFunc rotate3d_model
syn keyword luaFunc video_3dorder
syn keyword luaFunc set_image_as_frame
syn keyword luaFunc target_alloc
syn keyword luaFunc storepop_video_context
syn keyword luaFunc image_clip_off
syn keyword luaFunc new_3dmodel
syn keyword luaFunc instant_image_transform
syn keyword luaFunc image_matchstorage
syn keyword luaFunc net_accept
syn keyword luaFunc controller_leds
syn keyword luaFunc image_resize_storage
syn keyword luaFunc build_shader
syn keyword luaFunc push_video_context
syn keyword luaFunc net_discover
syn keyword luaFunc add_3dmesh
syn keyword luaFunc launch_avfeed
syn keyword luaFunc shader_uniform
syn keyword luaFunc image_mask_set
syn keyword luaFunc storepush_video_context
syn keyword luaFunc kbd_repeat
syn keyword luaFunc accept_target
syn keyword luaFunc camtaghmd_model
syn keyword luaFunc switch_default_scalemode
syn keyword luaFunc load_image
syn keyword luaFunc hide_image
syn keyword luaFunc resume_target
syn keyword luaFunc switch_default_imageproc
syn keyword luaFunc game_family
syn keyword luaFunc image_mipmap
syn keyword luaFunc move3d_model
syn keyword luaFunc image_mask_toggle
syn keyword luaFunc load_image_asynch
syn keyword luaFunc attrtag_model
syn keyword luaFunc switch_default_texfilter
syn keyword luaFunc image_transform_cycle
syn keyword luaFunc define_calctarget
syn keyword luaFunc load_movie
syn keyword luaFunc decode_modifiers
syn keyword luaFunc warning
syn keyword luaFunc move_cursor
syn keyword luaFunc define_recordtarget
syn keyword luaFunc random_surface
syn keyword luaFunc input_capabilities
syn keyword luaFunc match_keys
syn keyword luaFunc target_parent
syn keyword luaFunc stepframe_target
syn keyword luaFunc video_synchronization
syn keyword luaFunc game_genres
syn keyword luaFunc image_loaded
syn keyword luaFunc image_storage_properties
syn keyword luaFunc shader_ugroup
syn keyword luaFunc target_updatehandler
syn keyword luaFunc close_rawresource
syn keyword luaFunc scale_image
syn keyword luaFunc target_portconfig
syn keyword luaFunc game_cmdline
syn keyword luaFunc persist_image
syn keyword luaFunc target_synchronous
syn keyword luaFunc image_framesetsize
syn keyword luaFunc delete_image
syn keyword luaFunc define_feedtarget
syn keyword luaFunc snapshot_target
syn keyword luaFunc launch_decode
syn keyword luaFunc swizzle_model
syn keyword luaFunc list_targets
syn keyword luaFunc system_load
syn keyword luaFunc rotate_image
syn keyword luaFunc image_sharestorage
syn keyword luaFunc target_input
syn keyword luaFunc set_context_attachment
syn keyword luaFunc system_snapshot
syn keyword luaFunc tag_image_transform
syn keyword luaFunc nudge_cursor
syn keyword luaFunc valid_vid
syn keyword luaFunc store_key
syn keyword luaFunc render_text
syn keyword luaFunc suspend_target
syn keyword luaFunc net_push_srv
syn keyword luaFunc benchmark_data
syn keyword luaFunc image_hit
syn keyword luaFunc led_intensity
syn keyword luaFunc image_clip_on
syn keyword luaFunc image_color
syn keyword luaFunc pick_items
syn keyword luaFunc reset_target
syn keyword luaFunc image_tracetag
syn keyword luaFunc zap_resource
syn keyword luaFunc open_rawresource
syn keyword luaFunc target_framemode
syn keyword luaFunc delete_audio
syn keyword luaFunc expire_image
syn keyword luaFunc copy_image_transform
syn keyword luaFunc image_pushasynch
syn keyword luaFunc read_rawresource
syn keyword luaFunc input_target
syn keyword luaFunc image_scale_txcos
syn keyword luaFunc audio_gain
syn keyword luaFunc build_pointcloud
syn keyword luaFunc text_dimensions
syn keyword luaFunc restore_target
syn keyword luaFunc get_key
syn keyword luaFunc image_screen_coordinates
syn keyword luaFunc shutdown
syn keyword luaFunc resize_video_canvas
syn keyword luaFunc video_displaydescr
syn keyword luaConstant NET_BROADCAST
syn keyword luaConstant APPL_TEMP_RESOURCE
syn keyword luaConstant MASK_LIVING
syn keyword luaConstant MASK_FRAMESET
syn keyword luaConstant ANCHOR_LR
syn keyword luaConstant VRESH
syn keyword luaConstant FILTER_NONE
syn keyword luaConstant BLEND_MULTIPLY
syn keyword luaConstant EXIT_SUCCESS
syn keyword luaConstant API_VERSION_MAJOR
syn keyword luaConstant FORMAT_RAW32
syn keyword luaConstant HINT_FIT
syn keyword luaConstant MASK_SCALE
syn keyword luaConstant SCALE_POW2
syn keyword luaConstant FORMAT_RAW24
syn keyword luaConstant MAX_TARGETW
syn keyword luaConstant FRAMESERVER_OUTPUT
syn keyword luaConstant HINT_CROP
syn keyword luaConstant RENDERTARGET_DEPTH
syn keyword luaConstant CLIP_ON
syn keyword luaConstant KEY_CONFIG
syn keyword luaConstant MOUSE_BTNLEFT
syn keyword luaConstant APPL_STATE_RESOURCE
syn keyword luaConstant ANCHOR_UL
syn keyword luaConstant BLEND_NONE
syn keyword luaConstant MASK_UNPICKABLE
syn keyword luaConstant NOW
syn keyword luaConstant ORDER_FIRST
syn keyword luaConstant LAUNCH_EXTERNAL
syn keyword luaConstant CLIP_SHALLOW
syn keyword luaConstant KEY_TARGET
syn keyword luaConstant ALL_RESOURCES
syn keyword luaConstant HISTOGRAM_MERGE
syn keyword luaConstant TARGET_VERBOSE
syn keyword luaConstant API_ENGINE_BUILD
syn keyword luaConstant EXIT_FAILURE
syn keyword luaConstant ANCHOR_C
syn keyword luaConstant MAX_TARGETH
syn keyword luaConstant ORDER_NONE
syn keyword luaConstant API_VERSION_MINOR
syn keyword luaConstant TARGET_AUTOCLOCK
syn keyword luaConstant MOUSE_GRABOFF
syn keyword luaConstant TEX_CLAMP
syn keyword luaConstant MASK_OPACITY
syn keyword luaConstant MASK_POSITION
syn keyword luaConstant HINT_NONE
syn keyword luaConstant INTERP_EXPIN
syn keyword luaConstant BLEND_ADD
syn keyword luaConstant HISTOGRAM_MERGE_NOALPHA
syn keyword luaConstant IMAGEPROC_NORMAL
syn keyword luaConstant ANCHOR_UR
syn keyword luaConstant STACK_MAXCOUNT
syn keyword luaConstant FRAMESET_MULTITEXTURE
syn keyword luaConstant FRAMESERVER_LOOP
syn keyword luaConstant FRAMESET_NODETACH
syn keyword luaConstant MAX_SURFACEH
syn keyword luaConstant FRAMESERVER_MODES
syn keyword luaConstant HISTOGRAM_SPLIT
syn keyword luaConstant RENDERTARGET_SCALE
syn keyword luaConstant CLOCKRATE
syn keyword luaConstant PERSIST
syn keyword luaConstant TARGET_VSTORE_SYNCH
syn keyword luaConstant FRAMESERVER_INPUT
syn keyword luaConstant FORMAT_PNG_FLIP
syn keyword luaConstant DEBUGLEVEL
syn keyword luaConstant FRAMESET_SPLIT
syn keyword luaConstant ORDER_SKIP
syn keyword luaConstant HINT_ROTATE_CW_90
syn keyword luaConstant VRESW
syn keyword luaConstant LEDCONTROLLERS
syn keyword luaConstant RENDERTARGET_DETACH
syn keyword luaConstant FILTER_BILINEAR
syn keyword luaConstant CLOCK
syn keyword luaConstant APPLID
syn keyword luaConstant MOUSE_BTNRIGHT
syn keyword luaConstant INTERP_SINE
syn keyword luaConstant ANCHOR_LL
syn keyword luaConstant GL_VERSION
syn keyword luaConstant LAUNCH_INTERNAL
syn keyword luaConstant TYPE_3DOBJECT
syn keyword luaConstant FORMAT_PNG
syn keyword luaConstant RENDERTARGET_FULL
syn keyword luaConstant MASK_ORIENTATION
syn keyword luaConstant TYPE_FRAMESERVER
syn keyword luaConstant SHADER_LANGUAGE
syn keyword luaConstant ORDER_LAST
syn keyword luaConstant TEX_REPEAT
syn keyword luaConstant INTERP_EXPOUT
syn keyword luaConstant HINT_ROTATE_CCW_90
syn keyword luaConstant RENDERTARGET_COLOR
syn keyword luaConstant SCALE_NOPOW2
syn keyword luaConstant INTERP_LINEAR
syn keyword luaConstant BADID
syn keyword luaConstant ROTATE_RELATIVE
syn keyword luaConstant READBACK_MANUAL
syn keyword luaConstant FRAMESERVER_NOLOOP
syn keyword luaConstant RENDERTARGET_NODETACH
syn keyword luaConstant RENDERTARGET_NOSCALE
syn keyword luaConstant SYS_FONT_RESOURCE
syn keyword luaConstant MOUSE_GRABON
syn keyword luaConstant FILTER_LINEAR
syn keyword luaConstant FORMAT_RAW8
syn keyword luaConstant TARGET_SYNCHRONOUS
syn keyword luaConstant WORLDID
syn keyword luaConstant BLEND_NORMAL
syn keyword luaConstant INTERP_EXPINOUT
syn keyword luaConstant MOUSE_BTNMIDDLE
syn keyword luaConstant FILTER_TRILINEAR
syn keyword luaConstant IMAGEPROC_FLIPH
syn keyword luaConstant SYS_APPL_RESOURCE
syn keyword luaConstant _VERSION
syn keyword luaConstant MAX_SURFACEW
syn keyword luaConstant FRAMESET_DETACH
syn keyword luaConstant ROTATE_ABSOLUTE
syn keyword luaConstant CLIP_OFF
syn keyword luaConstant APPL_RESOURCE
syn keyword luaConstant MASK_MAPPING
syn keyword luaConstant SHARED_RESOURCE
syn keyword luaConstant NOPERSIST
syn keyword luaConstant TARGET_NOALPHA
let b:current_syntax = "arcan_lua"

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: et ts=8 sw=2
