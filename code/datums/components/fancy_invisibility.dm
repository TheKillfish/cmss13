/// A component that handles fancy visual distortion invisibility.
/datum/component/fancy_invisibility
	/// Atom for ensuring the user can still be clicked
	var/atom/movable/click_target_atom
	var/image/click_overlay

/datum/component/fancy_invisibility/Initialize()
	. = ..()

	src.click_target_atom = new()

	click_target_atom.appearance_flags |= ( RESET_COLOR | RESET_TRANSFORM)
	click_target_atom.vis_flags |= (VIS_INHERIT_ID | VIS_INHERIT_LAYER)

/datum/component/fancy_invisibility/Destroy(force, silent)
	QDEL_NULL(click_target_atom)
	return ..()

/datum/component/fancy_invisibility/proc/engage_invisibility(mob/host_mob, target_alpha)
	SIGNAL_HANDLER

	if(!ismob(host_mob))
		return

	click_target_atom.pixel_x = 0
	click_target_atom.pixel_y = 0
	click_target_atom.plane = DISPLACEMENT_PLATE_RENDER_LAYER + 1

	host_mob.vis_contents.Add(click_target_atom)
	host_mob.plane = DISPLACEMENT_PLATE_RENDER_LAYER

	if(target_alpha)
		animate(host_mob, alpha = target_alpha, time = 1.5 SECONDS, easing = SINE_EASING|EASE_OUT)

/datum/component/fancy_invisibility/proc/disengage_invisibility(mob/host_mob)
	if(!ismob(host_mob))
		return

	host_mob.vis_contents -= click_target_atom
	host_mob.plane = initial(host_mob.plane)
