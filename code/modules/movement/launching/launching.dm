/datum/launch_metadata
	// Parameters
	var/pass_flags = NO_FLAGS // Pass flags to add temporarily
	var/call_all = FALSE // Whether to perform all callback calls or none of them

	var/atom/target
	var/range
	var/speed
	var/atom/thrower
	var/spin

	// A list of callbacks to invoke when an atom of a specific type is hit (keys are typepaths and values are proc paths)
	// These should only be for CUSTOM procs to invoke when an atom of a specific type is collided with, otherwise will default to using
	// the appropriate mob/obj/turf collision procs
	// The callbacks can be standard or dynamic, though dynamic callbacks can only be called by the atom being thrown
	var/list/collision_callbacks

	/// A list of callbacks to invoke when the throw completes successfully
	var/list/end_throw_callbacks

	// Tracked information
	var/dist = 0

/datum/launch_metadata/Destroy(force, ...)
	target = null
	thrower = null
	return ..()


/datum/launch_metadata/proc/get_collision_callbacks(atom/A)
	var/highest_matching = null
	var/list/matching = list()

	if (isnull(collision_callbacks))
		return null

	for (var/path in collision_callbacks)
		if (ispath(path) && istype(A, path))
			// A is going to be of type `path` and `highest_matching`, so check whether
			// `highest_matching` is a parent of `path` (lower in the type tree)
			if (isnull(highest_matching) || !ispath(highest_matching, path))
				highest_matching = path
			matching += path

	if (!call_all)
		if (isnull(highest_matching))
			return null
		return list(collision_callbacks[highest_matching])
	else
		if (length(matching) == 0)
			return null
		var/list/matching_procs = list()
		for(var/path in matching)
			matching_procs += collision_callbacks[path]
		return matching_procs

/// Invoke end_throw_callbacks on this metadata.
/// Takes argument of type /atom/movable
/datum/launch_metadata/proc/invoke_end_throw_callbacks(atom/movable/movable_atom)
	if(length(end_throw_callbacks))
		for(var/datum/callback/callback as anything in end_throw_callbacks)
			if(istype(callback, /datum/callback/dynamic))
				callback.Invoke(movable_atom)
			else
				callback.Invoke()

/atom/movable/var/datum/launch_metadata/launch_metadata = null

//called when src is thrown into hit_atom
/atom/movable/proc/launch_impact(atom/hit_atom)
	if (isnull(launch_metadata))
		CRASH("launch_impact called without any stored metadata")

	var/list/collision_callbacks = launch_metadata?.get_collision_callbacks(hit_atom)
	if (islist(collision_callbacks))
		for(var/datum/callback/CB as anything in collision_callbacks)
			if(istype(CB, /datum/callback/dynamic))
				CB.Invoke(src, hit_atom)
			else
				CB.Invoke(hit_atom)
	else if (isliving(hit_atom))
		mob_launch_collision(hit_atom)
	else if (isobj(hit_atom)) // Thrown object hits another object and moves it
		obj_launch_collision(hit_atom)
	else if (isturf(hit_atom))
		var/turf/T = hit_atom
		if (T.density)
			turf_launch_collision(T)

	throwing = FALSE
	rebounding = FALSE

/atom/movable/proc/mob_launch_collision(mob/living/L)
	if (!rebounding)
		L.hitby(src)

/atom/movable/proc/obj_launch_collision(obj/O)
	if (!O.anchored && !rebounding && !isxeno(src))
		O.Move(get_step(O, dir))
	else if (!rebounding && rebounds)
		var/oldloc = loc
		var/launched_speed = cur_speed
		addtimer(CALLBACK(src, PROC_REF(rebound), oldloc, launched_speed), 0.5)

	if (!rebounding)
		O.hitby(src)

/atom/movable/proc/turf_launch_collision(turf/T)
	if (!rebounding && rebounds)
		var/oldloc = loc
		var/launched_speed = cur_speed
		addtimer(CALLBACK(src, PROC_REF(rebound), oldloc, launched_speed), 0.5)

	if (!rebounding)
		T.hitby(src)

/atom/movable/proc/rebound(oldloc, launched_speed)
	if (loc == oldloc)
		rebounding = TRUE
		var/datum/launch_metadata/LM = new()
		LM.target = get_step(src, turn(dir, 180))
		LM.range = 1
		LM.speed = launched_speed
		LM.pass_flags = PASS_UNDER
		LM.pass_flags |= (ismob(src) ? PASS_OVER_THROW_MOB : PASS_OVER_THROW_ITEM)

		launch_towards(LM)

/atom/movable/proc/try_to_throw(mob/living/user)
	return TRUE

// Proc for throwing items (should only really be used for throw)
/atom/movable/proc/throw_atom(atom/target, range, speed = 0, atom/thrower, spin, launch_type = NORMAL_LAUNCH, pass_flags = NO_FLAGS, list/end_throw_callbacks, list/collision_callbacks, tracking = FALSE)
	var/temp_pass_flags = pass_flags
	switch (launch_type)
		if (NORMAL_LAUNCH)
			temp_pass_flags |= (ismob(src) ? PASS_OVER_THROW_MOB : PASS_OVER_THROW_ITEM)
		if (HIGH_LAUNCH)
			temp_pass_flags |= PASS_HIGH_OVER

	var/datum/launch_metadata/LM = new()
	LM.pass_flags = temp_pass_flags
	LM.target = target
	LM.range = range
	LM.speed = speed
	LM.thrower = thrower
	LM.spin = spin
	if(end_throw_callbacks)
		LM.end_throw_callbacks = end_throw_callbacks
	if(collision_callbacks)
		LM.collision_callbacks = collision_callbacks

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_LAUNCH, LM) & COMPONENT_LAUNCH_CANCEL)
		return

	flags_atom |= NO_ZFALL

	launch_towards(LM, tracking)

	flags_atom &= ~NO_ZFALL
	var/turf/end_turf = get_turf(src)
	if(end_turf)
		end_turf.on_throw_end(src)


// Proc for throwing or propelling movable atoms towards a target
/atom/movable/proc/launch_towards(datum/launch_metadata/LM, tracking = FALSE)
	if (!istype(LM))
		CRASH("invalid launch_metadata passed to launch_towards")
	if (!LM.target || !src)
		return

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_THROW, LM.thrower) & COMPONENT_CANCEL_THROW)
		return

	// If we already have launch_metadata (from a previous throw), reset it and qdel the old launch_metadata datum
	if (istype(launch_metadata))
		qdel(launch_metadata)
	launch_metadata = LM

	if (LM.spin)
		animation_spin(5, 1 + min(1, LM.range/20))

	var/old_speed = cur_speed
	cur_speed = clamp(LM.speed, MIN_SPEED, MAX_SPEED) // Sanity check, also ~1 sec delay between each launch move is not very reasonable
	var/delay = 10/cur_speed - 0.5 // scales delay back to deciseconds for when sleep is called
	var/pass_flags = LM.pass_flags

	throwing = TRUE

	add_temp_pass_flags(pass_flags)

	var/turf/start_turf = get_step_towards(src, LM.target)
	var/list/turf/path = get_line(start_turf, LM.target)
	var/last_loc = loc

	var/early_exit = FALSE
	LM.dist = 0
	for (var/turf/T in path)
		if (!src || !throwing || loc != last_loc || !isturf(src.loc))
			break
		if (!LM || QDELETED(LM))
			early_exit = TRUE
			break
		if (LM.dist >= LM.range)
			break
		if (!Move(T)) // If this returns FALSE, then a collision happened
			break
		last_loc = loc
		if (++LM.dist >= LM.range)
			break
		sleep(delay)

	//done throwing, either because it hit something or it finished moving
	if ((isobj(src) || ismob(src)) && throwing && !early_exit)
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		var/atom/hit_atom = ismob(LM.target) ? null : T // TODO, just check for LM.target, the ismob is to prevent funky behavior with grenades 'n crates
		if(!hit_atom)
			for(var/atom/A in T)
				if(A == LM.target)
					hit_atom = A
					break
			if(!hit_atom && tracking && get_dist(src, LM.target) <= 1 && get_dist(start_turf, LM.target) <= 1) // If we missed, but we are tracking and the target is still next to us and the turf we launched from, then we still count it as a hit
				hit_atom = LM.target
		launch_impact(hit_atom)
	if (loc)
		throwing = FALSE
		rebounding = FALSE
		cur_speed = old_speed
		remove_temp_pass_flags(pass_flags)
		LM.invoke_end_throw_callbacks(src)
	QDEL_NULL(launch_metadata)

/atom/movable/proc/throw_random_direction(range, speed = 0, atom/thrower, spin, launch_type = NORMAL_LAUNCH, pass_flags = NO_FLAGS)
	var/throw_direction = pick(CARDINAL_ALL_DIRS)

	var/turf/furthest_turf = get_turf(src)
	var/turf/temp_turf = get_turf(src)
	for (var/x in 1 to range)
		temp_turf = get_step(furthest_turf, throw_direction)
		if (!temp_turf)
			break
		furthest_turf = temp_turf

	throw_atom(furthest_turf, range, speed, thrower, spin, launch_type, pass_flags)
