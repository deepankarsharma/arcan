-- system_collapse
-- @short: Collapse important subsystems, leaving only frameservers alive.
-- @inargs: *appname*
-- @longdescr: This function purges audio/video/events from everything not
-- strictly related to frameservers. Then, if *appname* was specified, it loads
-- and runs *appname* and invokes an appname_adopt function for each
-- frameserver related VID. This allows recovery from bad system states,
-- switching to an app that can permit the user to clean-up and save important
-- information that would otherwise be lost or simply to switch active scripts
-- while keeping core services intact. If *appname* is left undefined,
-- audio/video/event cleanup will occur, but the current Lua contexts and its
-- globals and scripts will remain intact. The caller must then be careful to
-- not have any dangling VID states around.
-- @note: frameservers existing in multiple contexts are collated down to a
-- flat, new context.
-- @note: if the number of running frameserver is higher than the current new
-- context vobj limit the vobj limit will be raised.
-- @note: if there are more running frameservers in all contexts combined than
-- what is permitted (compile-time) some frameservers will be truncated and
-- deleted.  (likely to hit system process and descriptor limits before that
-- happens).
-- @note: frameservers will have their order value set depending on the context
-- they were previously allocated in.
-- @note: the search space for *appname* is constrained to namespace defined by
-- the APPLBASE namespace.
-- @group: system
-- @cfunction: syscollapse
-- @related:
-- @exampleappl: tests/interactive/failover tests/interactive/failadopt

