/datum/caste_datum/terraformer
	caste_type = XENO_CASTE_TERRAFORMER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = XENO_DAMAGE_TIER_2
	max_health = XENO_HEALTH_TIER_12
	plasma_gain = XENO_PLASMA_GAIN_TIER_10
	plasma_max = XENO_PLASMA_TIER_10
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_2

	evolution_allowed = FALSE
	caste_desc = "Truly become one with the weeds."
	deevolves_to = list(XENO_CASTE_HIVELORD)
	can_hold_facehuggers = 1
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	weed_level = WEED_LEVEL_STANDARD
	build_time_mult = BUILD_TIME_MULT_HIVELORD
	behavior_delegate_type = /datum/behavior_delegate/terraformer_base
	max_build_dist = 7

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 25
	tacklestrength_min = 4
	tacklestrength_max = 5

	aura_strength = 2

	minimum_evolve_time = 15 MINUTES

	minimap_icon = "terraformer"

/datum/caste_datum/terraformer/New()
	. = ..()

	resin_build_order = GLOB.resin_build_order_terraformer

/mob/living/carbon/xenomorph/terraformer
	caste_type = XENO_CASTE_TERRAFORMER
	name = XENO_CASTE_TERRAFORMER
	desc = "A twitching, half-melted mass of weeds and alien flesh."
	icon = 'icons/mob/xenos/castes/tier_3/terraformer.dmi'
	icon_size = 64
	icon_state = "Terraformer Walking"
	plasma_types = list(PLASMA_PURPLE)
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	organ_value = 1500

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		// No Tailstab; you have no tail to stab with
		// No corrosive acid; you produce a special acid via a special ability
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/place_construction,
		/datum/action/xeno_action/onclick/plant_weeds, //first macro
		/datum/action/xeno_action/onclick/choose_resin, //second macro
		/datum/action/xeno_action/activable/secrete_resin/hivelord, //third macro
		/datum/action/xeno_action/activable/transfer_plasma/hivelord, // to be consistent with drone placement
		/datum/action/xeno_action/active_toggle/toggle_speed, //fourth macro
		/datum/action/xeno_action/active_toggle/toggle_meson_vision,
		)

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	icon_xeno = 'icons/mob/xenos/castes/tier_2/hivelord.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_2/hivelord.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Hivelord_1","Hivelord_2","Hivelord_3")
	weed_food_states_flipped = list("Hivelord_1","Hivelord_2","Hivelord_3")

	skull = /obj/item/skull/terraformer
	pelt = /obj/item/pelt/terraformer

	// Terraformer Vars
	var/fused_with_weeds = FALSE

/mob/hologram/terraformer
	name = "Terraformer Eye"
	action_icon_state = "queen_exit"
	motion_sensed = TRUE

	color = "#a800a8"

	hud_possible = list(XENO_STATUS_HUD)
	var/mob/is_watching

	var/hivenumber = XENO_HIVE_NORMAL
	var/next_point = 0

	var/point_delay = 1 SECONDS


/mob/hologram/terraformer/Initialize(mapload, mob/living/carbon/xenomorph/terraformer/terra_user)
	if(!terra_user)
		return INITIALIZE_HINT_QDEL

	if(!istype(terra_user))
		stack_trace("Tried to initialize a /mob/hologram/queen on type ([terra_user.type])")
		return INITIALIZE_HINT_QDEL

	if(!terra_user.fused_with_weeds)
		return INITIALIZE_HINT_QDEL

	// Make sure to turn off any previous overwatches
	terra_user.overwatch(stop_overwatch = TRUE)

	. = ..()
	RegisterSignal(terra_user, COMSIG_MOB_PRE_CLICK, PROC_REF(handle_overwatch))
	RegisterSignal(terra_user, COMSIG_QUEEN_DISMOUNT_OVIPOSITOR, PROC_REF(exit_hologram))
	RegisterSignal(terra_user, COMSIG_XENO_OVERWATCH_XENO, PROC_REF(start_watching))
	RegisterSignal(terra_user, list(
		COMSIG_XENO_STOP_OVERWATCH,
		COMSIG_XENO_STOP_OVERWATCH_XENO
	), PROC_REF(stop_watching))
	RegisterSignal(terra_user, COMSIG_MOB_REAL_NAME_CHANGED, PROC_REF(on_name_changed))
	RegisterSignal(src, COMSIG_MOVABLE_TURF_ENTER, PROC_REF(turf_weed_only))

	// Default color
	if(terra_user.hive.color)
		color = terra_user.hive.color

	hivenumber = terra_user.hivenumber
	med_hud_set_status()
	add_to_all_mob_huds()

	terra_user.sight |= SEE_TURFS|SEE_OBJS

/mob/hologram/terraformer/proc/exit_hologram()
	SIGNAL_HANDLER

	var/obj/structure/tent/tent = locate() in ((get_turf(linked_mob)).contents)

	var/atom/movable/screen/plane_master/roof/roof_plane = linked_mob.hud_used.plane_masters["[ROOF_PLANE]"]

	if(!tent)
		roof_plane?.invisibility = 0
	else if (roof_plane?.invisibility == 0)
		roof_plane?.invisibility = INVISIBILITY_MAXIMUM

	qdel(src)

/mob/hologram/terraformer/handle_move(mob/living/carbon/xenomorph/terra_user, NewLoc, direct)
	if(is_watching && (turf_weed_only(src, is_watching.loc) & COMPONENT_TURF_DENY_MOVEMENT))
		return COMPONENT_OVERRIDE_MOVE

	terra_user.overwatch(stop_overwatch = TRUE)

	return ..()


/mob/hologram/terraformer/proc/start_watching(mob/living/carbon/xenomorph/terra_user, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	forceMove(target)
	is_watching = target

	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(target_watching_qdeleted))
	return

/mob/hologram/terraformer/proc/target_watching_qdeleted(mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	stop_watching(linked_mob, target)

/mob/hologram/terraformer/proc/stop_watching(mob/living/carbon/xenomorph/terra_user, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	if(target)
		if(loc == target)
			var/turf/turf_target = get_turf(target)

			if(turf_target)
				forceMove(turf_target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)

	if(!isturf(loc) || (turf_weed_only(src, loc) & COMPONENT_TURF_DENY_MOVEMENT))
		forceMove(terra_user.loc)

	is_watching = null
	terra_user.reset_view()
	return

/mob/hologram/terraformer/proc/on_name_changed(mob/parent, old_name, new_name)
	SIGNAL_HANDLER
	name = "[initial(src.name)] ([new_name])"

/mob/hologram/terraformer/proc/turf_weed_only(mob/self, turf/crossing_turf)
	SIGNAL_HANDLER

	if(!crossing_turf)
		return COMPONENT_TURF_DENY_MOVEMENT

	if(istype(crossing_turf, /turf/closed/wall))
		var/turf/closed/wall/crossing_wall = crossing_turf
		if(crossing_wall.turf_flags & TURF_HULL)
			return COMPONENT_TURF_DENY_MOVEMENT

	var/list/turf_area = range(3, crossing_turf)

	var/obj/effect/alien/weeds/nearby_weeds = locate() in turf_area
	if(nearby_weeds && HIVE_ALLIED_TO_HIVE(nearby_weeds.hivenumber, hivenumber))
		var/obj/effect/alien/crossing_turf_weeds = locate() in crossing_turf
		if(crossing_turf_weeds)
			crossing_turf_weeds.update_icon() //randomizes the icon of the turf when crossed over*/
		return COMPONENT_TURF_ALLOW_MOVEMENT

	return COMPONENT_TURF_DENY_MOVEMENT

/mob/hologram/terraformer/proc/handle_overwatch(mob/living/carbon/xenomorph/terraformer/terra_user, atom/atom_target, mods)
	SIGNAL_HANDLER

	var/turf/turf_target = get_turf(atom_target)
	if(!istype(turf_target))
		return

	if(mods[SHIFT_CLICK] && mods[MIDDLE_CLICK])
		if(next_point > world.time)
			return COMPONENT_INTERRUPT_CLICK

		next_point = world.time + point_delay

		var/message = SPAN_XENONOTICE("[terra_user] points at [atom_target].")

		to_chat(terra_user, message)
		for(var/mob/living/carbon/xenomorph/X in viewers(7, src))
			if(X == terra_user)
				continue
			to_chat(X, message)

		var/obj/effect/overlay/temp/point/big/queen/point = new(turf_target, src, atom_target)
		point.color = color

		return COMPONENT_INTERRUPT_CLICK

	if(!mods[CTRL_CLICK])
		return

	if(isxeno(atom_target))
		var/mob/living/carbon/xenomorph/X = atom_target
		if(X.ally_of_hivenumber(hivenumber))
			terra_user.overwatch(atom_target)
		return COMPONENT_INTERRUPT_CLICK

	if(!(turf_weed_only(src, turf_target) & COMPONENT_TURF_ALLOW_MOVEMENT))
		return

	forceMove(turf_target)
	if(is_watching)
		terra_user.overwatch(stop_overwatch = TRUE)

	return COMPONENT_INTERRUPT_CLICK

/mob/hologram/terraformer/handle_view(mob/M, atom/target)
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE

		if(is_watching)
			M.client.set_eye(is_watching)
		else
			M.client.set_eye(src)

	return COMPONENT_OVERRIDE_VIEW

/mob/hologram/terraformer/Destroy()
	if(linked_mob)
		var/mob/living/carbon/xenomorph/queen/terra_user = linked_mob
		if(terra_user.ovipositor)
			give_action(linked_mob, /datum/action/xeno_action/onclick/eye)

		linked_mob.sight &= ~(SEE_TURFS|SEE_OBJS)

	remove_from_all_mob_huds()
	is_watching = null

	return ..()

/datum/behavior_delegate/terraformer_base
	name = "Base Terraformer Behavior Delegate"
