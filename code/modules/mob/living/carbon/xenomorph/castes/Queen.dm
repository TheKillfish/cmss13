#define XENO_QUEEN_AGE_TIME (10 MINUTES)
#define XENO_QUEEN_DEATH_DELAY (5 MINUTES)
#define YOUNG_QUEEN_HEALTH_MULTIPLIER 0.5

/datum/caste_datum/queen
	caste_type = XENO_CASTE_QUEEN
	tier = 4

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_6
	melee_vehicle_damage = XENO_DAMAGE_TIER_9 //Queen and Ravs have extra multiplier when dealing damage in multitile_interaction.dm
	max_health = XENO_HEALTH_QUEEN
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_10
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_10
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_QUEEN

	build_time_mult = BUILD_TIME_MULT_BUILDER

	is_intelligent = 1
	evolution_allowed = FALSE
	fire_immunity = FIRE_IMMUNITY_NO_DAMAGE|FIRE_IMMUNITY_NO_IGNITE
	caste_desc = "The Queen, in all her glory."
	spit_types = list(/datum/ammo/xeno/resin)
	can_hold_eggs = CAN_HOLD_ONE_HAND
	acid_level = 2
	weed_level = WEED_LEVEL_STANDARD
	can_be_revived = FALSE

	behavior_delegate_type = /datum/behavior_delegate/queen

	spit_delay = 25

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 55

	aura_strength = 4
	tacklestrength_min = 5
	tacklestrength_max = 6

	minimum_xeno_playtime = 9 HOURS
	minimum_evolve_time = 0

	minimap_icon = "xenoqueen"

	minimap_background = "xeno_ruler"

	royal_caste = TRUE


/proc/update_living_queens() // needed to update when you change a queen to a different hive
	outer_loop:
		var/datum/hive_status/hive
		for(var/hivenumber in GLOB.hive_datum)
			hive = GLOB.hive_datum[hivenumber]
			if(hive.living_xeno_queen)
				if(hive.living_xeno_queen.hivenumber == hive.hivenumber)
					continue
			for(var/mob/living/carbon/xenomorph/queen/queen in GLOB.living_xeno_list)
				if(queen.hivenumber == hive.hivenumber && !should_block_game_interaction(queen))
					hive.living_xeno_queen = queen
					xeno_message(SPAN_XENOANNOUNCE("A new Queen has risen to lead the Hive! Rejoice!"),3,hive.hivenumber)
					continue outer_loop
			hive.living_xeno_queen = null

/mob/hologram/queen
	name = "Queen Eye"
	action_icon_state = "queen_exit"
	motion_sensed = TRUE

	color = "#a800a8"

	hud_possible = list(XENO_STATUS_HUD)
	var/mob/is_watching

	var/hivenumber = XENO_HIVE_NORMAL
	var/next_point = 0

	var/point_delay = 1 SECONDS


/mob/hologram/queen/Initialize(mapload, mob/living/carbon/xenomorph/queen/queen)
	if(!queen)
		return INITIALIZE_HINT_QDEL

	if(!istype(queen))
		stack_trace("Tried to initialize a /mob/hologram/queen on type ([queen.type])")
		return INITIALIZE_HINT_QDEL

	if(!queen.ovipositor)
		return INITIALIZE_HINT_QDEL

	// Make sure to turn off any previous overwatches
	queen.overwatch(stop_overwatch = TRUE)

	. = ..()
	RegisterSignal(queen, COMSIG_MOB_PRE_CLICK, PROC_REF(handle_overwatch))
	RegisterSignal(queen, COMSIG_QUEEN_DISMOUNT_OVIPOSITOR, PROC_REF(exit_hologram))
	RegisterSignal(queen, COMSIG_XENO_OVERWATCH_XENO, PROC_REF(start_watching))
	RegisterSignal(queen, list(
		COMSIG_XENO_STOP_OVERWATCH,
		COMSIG_XENO_STOP_OVERWATCH_XENO
	), PROC_REF(stop_watching))
	RegisterSignal(queen, COMSIG_MOB_REAL_NAME_CHANGED, PROC_REF(on_name_changed))
	RegisterSignal(src, COMSIG_MOVABLE_TURF_ENTER, PROC_REF(turf_weed_only))

	queen.current_queen_eye = src

	// Default color
	if(queen.hive.color)
		color = queen.hive.color

	hivenumber = queen.hivenumber
	med_hud_set_status()
	add_to_all_mob_huds()

	queen.sight |= SEE_TURFS|SEE_OBJS

/mob/hologram/queen/proc/exit_hologram()
	SIGNAL_HANDLER
	qdel(src)

/mob/hologram/queen/handle_move(mob/living/carbon/xenomorph/X, NewLoc, direct)
	if(is_watching && (turf_weed_only(src, is_watching.loc) & COMPONENT_TURF_DENY_MOVEMENT))
		return COMPONENT_OVERRIDE_MOVE

	X.overwatch(stop_overwatch = TRUE)

	return ..()


/mob/hologram/queen/proc/start_watching(mob/living/carbon/xenomorph/X, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	forceMove(target)
	is_watching = target

	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(target_watching_qdeleted))
	return

// able to stop watching here before the loc is set to null
/mob/hologram/queen/proc/target_watching_qdeleted(mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	stop_watching(linked_mob, target)

/mob/hologram/queen/proc/stop_watching(mob/living/carbon/xenomorph/X, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	if(target)
		if(loc == target)
			var/turf/T = get_turf(target)

			if(T)
				forceMove(T)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)

	if(!isturf(loc) || (turf_weed_only(src, loc) & COMPONENT_TURF_DENY_MOVEMENT))
		forceMove(X.loc)

	is_watching = null
	X.reset_view()
	return

/mob/hologram/queen/proc/on_name_changed(mob/parent, old_name, new_name)
	SIGNAL_HANDLER
	name = "[initial(src.name)] ([new_name])"

/mob/hologram/queen/proc/turf_weed_only(mob/self, turf/crossing_turf)
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

/mob/hologram/queen/proc/handle_overwatch(mob/living/carbon/xenomorph/queen/queen, atom/A, mods)
	SIGNAL_HANDLER

	var/turf/T = get_turf(A)
	if(!istype(T))
		return

	if(mods[SHIFT_CLICK] && mods[MIDDLE_CLICK])
		if(next_point > world.time)
			return COMPONENT_INTERRUPT_CLICK

		next_point = world.time + point_delay

		var/message = SPAN_XENONOTICE("[queen] points at [A].")

		to_chat(queen, message)
		for(var/mob/living/carbon/xenomorph/X in viewers(7, src))
			if(X == queen)
				continue
			to_chat(X, message)

		var/obj/effect/overlay/temp/point/big/queen/point = new(T, src, A)
		point.color = color

		return COMPONENT_INTERRUPT_CLICK

	if(!mods[CTRL_CLICK])
		return

	if(isxeno(A))
		var/mob/living/carbon/xenomorph/X = A
		if(X.ally_of_hivenumber(hivenumber))
			queen.overwatch(A)
		return COMPONENT_INTERRUPT_CLICK

	if(!(turf_weed_only(src, T) & COMPONENT_TURF_ALLOW_MOVEMENT))
		return

	forceMove(T)
	if(is_watching)
		queen.overwatch(stop_overwatch = TRUE)

	return COMPONENT_INTERRUPT_CLICK

/mob/hologram/queen/handle_view(mob/M, atom/target)
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE

		if(is_watching)
			M.client.eye = is_watching
		else
			M.client.eye = src

	return COMPONENT_OVERRIDE_VIEW

/mob/hologram/queen/Destroy()
	if(linked_mob)
		var/mob/living/carbon/xenomorph/queen/queen = linked_mob
		if(queen.ovipositor)
			give_action(linked_mob, /datum/action/xeno_action/onclick/eye)
		queen.current_queen_eye = null

		linked_mob.sight &= ~(SEE_TURFS|SEE_OBJS)

	remove_from_all_mob_huds()
	is_watching = null

	return ..()

/mob/living/carbon/xenomorph/queen
	AUTOWIKI_SKIP(TRUE)

	caste_type = XENO_CASTE_QUEEN
	name = XENO_CASTE_QUEEN
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon_size = 64
	icon_state = "Queen Walking"
	plasma_types = list(PLASMA_ROYAL,PLASMA_CHITIN,PLASMA_PHEROMONE,PLASMA_NEUROTOXIN)
	attacktext = "bites"
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_IMMOBILE
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 4
	hive_pos = XENO_QUEEN
	small_explosives_stun = FALSE
	pull_speed = 3 //screech/neurodragging is cancer, at the very absolute least get some runner to do it for teamwork
	counts_for_slots = FALSE
	organ_value = 8000 // queen is expensive

	icon_xeno = 'icons/mob/xenos/castes/tier_4/queen.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_4/queen.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Queen_1","Queen_2","Queen_3")
	weed_food_states_flipped = list("Queen_1","Queen_2","Queen_3")

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/egg_amount = 0 //amount of eggs inside the queen
	var/screech_sound_effect_list = list('sound/voice/alien_queen_screech.ogg') //the noise the Queen makes when she screeches. Done this way for VV purposes.
	var/queen_ovipositor_icon
	var/queen_standing_icon

	// QUEEN REWORK STUFF
	// Queen eye tracker
	var/current_queen_eye = null /// Used for an onscreen hostile proximity checker
	// Building speed modifier
	var/building_mult = 1 /// This gets modified based on if enemies are nearby Queen
	// Queen Stamina vars
	var/queen_stamina = 0 /// Current stamina
	var/stamina_cap = 600 /// Maximum stamina
	var/stamina_tier = 0 /// Which tier increment is stamina at? 6 is highest, 0 is lowest.
	var/stamina_gain = 2 /// How much stamina Queen gains per second while on ovi (adjusted for tick updates)
	// Stamina Drain vars
	var/stamina_drain = -2 /// How much stamina Queen loses per second while off ovi (adjusted for tick updates)
	var/stamina_drain_delay_duration = 60
	var/stamina_drain_delay = 60 /// How long after getting off ovi will drain be delayed for?
	var/stamina_drain_delay_active = FALSE /// Is the delay for stamina draining active?
	// Screech Accuracy/Scatter Degredation
	var/screech_deg_str = 90 /// How much is human gun accuracy/scatter degraded when affected by Queen's screech?
	var/screech_deg_dur = 8 SECONDS /// How long does the accuracy/scatter degredation last?

	tileoffset = 0
	viewsize = 12

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting/queen, // Not usable on ovi
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/queen, // Not usable on ovi
		/datum/action/xeno_action/activable/corrosive_acid/queen, // Not usable on ovi
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/place_construction/queen,
		/datum/action/xeno_action/onclick/queen_word,
		/datum/action/xeno_action/onclick/send_thoughts,
		/datum/action/xeno_action/onclick/manage_hive,
		/datum/action/xeno_action/activable/info_marker/queen,
		/datum/action/xeno_action/onclick/screech, // Custom macro, needs to be mature to use
		// Mobile Abilities
		/datum/action/xeno_action/onclick/grow_ovipositor,
		/datum/action/xeno_action/onclick/plant_weeds/queen, // First macro
		/datum/action/xeno_action/onclick/choose_resin/queen_off_ovi,
		/datum/action/xeno_action/activable/secrete_resin/queen_off_ovi,
		/datum/action/xeno_action/activable/frontal_assault, // Second macro
		/datum/action/xeno_action/onclick/disarming_sweep, // Third macro
		/datum/action/xeno_action/activable/ram, // Fourth macro, needs to be mature to use
		/datum/action/xeno_action/activable/xeno_spit/queen, // Fifth macro
		/datum/action/xeno_action/activable/gut,
		// Immobile Abilities
		/datum/action/xeno_action/onclick/remove_eggsac,
		/datum/action/xeno_action/activable/expand_weeds, // Third macro
		/datum/action/xeno_action/onclick/choose_resin/queen, // Fourth macro
		/datum/action/xeno_action/activable/secrete_resin/remote/queen, // Fifth macro
		/datum/action/xeno_action/onclick/set_xeno_lead,
		/datum/action/xeno_action/activable/queen_heal, // First macro
		/datum/action/xeno_action/activable/queen_give_plasma, // Second macro
		/datum/action/xeno_action/onclick/queen_tacmap,
		/datum/action/xeno_action/onclick/eye,
	)

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/claw_toggle,
		/mob/living/carbon/xenomorph/proc/construction_toggle,
		/mob/living/carbon/xenomorph/proc/destruction_toggle,
		/mob/living/carbon/xenomorph/proc/toggle_unnesting,
		/mob/living/carbon/xenomorph/queen/proc/set_orders,
		/mob/living/carbon/xenomorph/queen/proc/hive_message,
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	claw_type = CLAW_TYPE_VERY_SHARP

	skull = /obj/item/skull/queen
	pelt = /obj/item/pelt/queen

	needs_maturity = TRUE
	maturity_time_needed = XENO_QUEEN_AGE_TIME
	utilizes_special_states = TRUE

	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/queen/can_destroy_special()
	return TRUE

/mob/living/carbon/xenomorph/queen/set_resting(new_resting, silent, instant)
	if(ovipositor)
		return
	return ..()

/mob/living/carbon/xenomorph/queen/get_organ_icon()
	return "heart_t3"

/mob/living/carbon/xenomorph/queen/corrupted
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/queen/forsaken
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_FORSAKEN

/mob/living/carbon/xenomorph/queen/forsaken/combat_ready
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_FORSAKEN
	starts_mature = TRUE

/mob/living/carbon/xenomorph/queen/alpha
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_ALPHA
	is_mature = TRUE

/mob/living/carbon/xenomorph/queen/bravo
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_BRAVO
	is_mature = TRUE

/mob/living/carbon/xenomorph/queen/charlie
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_CHARLIE
	is_mature = TRUE

/mob/living/carbon/xenomorph/queen/delta
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_DELTA
	is_mature = TRUE

/mob/living/carbon/xenomorph/queen/mutated
	AUTOWIKI_SKIP(TRUE)

	hivenumber = XENO_HIVE_MUTATED

/mob/living/carbon/xenomorph/queen/combat_ready
	AUTOWIKI_SKIP(FALSE)
	is_mature = TRUE
	queen_stamina = 600

/mob/living/carbon/xenomorph/queen/Initialize()
	. = ..()
	SStracking.set_leader("hive_[hivenumber]", src)
	if(!should_block_game_interaction(src))//so admins can safely spawn Queens in Thunderdome for tests.
		xeno_message(SPAN_XENOANNOUNCE("A new Queen has risen to lead the Hive! Rejoice!"),3,hivenumber)
		notify_ghosts(header = "New Queen", message = "A new Queen has risen.", source = src, action = NOTIFY_ORBIT)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)
	set_resin_build_order(GLOB.resin_build_order_drone)
	for(var/datum/action/xeno_action/action in actions)
		// Also update the choose_resin icon since it resets
		if(istype(action, /datum/action/xeno_action/onclick/choose_resin))
			var/datum/action/xeno_action/onclick/choose_resin/choose_resin_ability = action
			if(choose_resin_ability)
				choose_resin_ability.update_button_icon(selected_resin)
				break // Don't need to keep looking

	AddComponent(/datum/component/footstep, 2 , 35, 11, 4, "alien_footstep_large")
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_block))

/mob/living/carbon/xenomorph/queen/proc/check_block(mob/queen, turf/new_loc)
	SIGNAL_HANDLER
	if(body_position == LYING_DOWN || stat == UNCONSCIOUS)
		return
	for(var/mob/living/carbon/xenomorph/xeno in new_loc.contents)
		if(xeno == queen)
			continue
		if(xeno.stat == DEAD)
			continue
		if(xeno.pass_flags.flags_pass & (PASS_MOB_THRU_XENO|PASS_MOB_THRU) || xeno.flags_pass_temp & PASS_MOB_THRU)
			continue
		if(xeno.hivenumber == hivenumber && !(queen.client?.prefs?.toggle_prefs & TOGGLE_AUTO_SHOVE_OFF))
			xeno.KnockDown((5 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
			playsound(src, 'sound/weapons/alien_knockdown.ogg', 25, 1)

/mob/living/carbon/xenomorph/queen/generate_name()
	if(!nicknumber)
		generate_and_set_nicknumber()
	var/name_prefix = hive.prefix
	if(is_mature)
		age_xeno()
		switch(age)
			if(XENO_YOUNG)
				name = "[name_prefix]Young Queen" //Young
			if(XENO_NORMAL)
				name = "[name_prefix]Queen"  //Regular
			if(XENO_MATURE)
				name = "[name_prefix]Elder Queen"  //Mature
			if(XENO_ELDER)
				name = "[name_prefix]Elder Empress"  //Elite
			if(XENO_ANCIENT)
				name = "[name_prefix]Ancient Empress" //Ancient
			if(XENO_PRIME)
				name = "[name_prefix]Prime Empress" //Primordial
	else
		age = XENO_NORMAL
		if(client)
			hud_update()

		name = "[name_prefix]Immature Queen"

	var/name_client_prefix = ""
	var/name_client_postfix = ""
	if(client)
		name_client_prefix = "[(client.xeno_prefix||client.xeno_postfix) ? client.xeno_prefix : "XX"]-"
		name_client_postfix = client.xeno_postfix ? ("-"+client.xeno_postfix) : ""
		if(client?.prefs?.show_queen_name)
			name += " (" + replacetext((name_client_prefix + name_client_postfix), "-","") + ")"


	full_designation = "[name_client_prefix][nicknumber][name_client_postfix]"
	color = hive.color

	//Update linked data so they show up properly
	change_real_name(src, name)

/mob/living/carbon/xenomorph/queen/set_hive_and_update(new_hivenumber)
	if(!..())
		return FALSE
	update_living_queens()

/mob/living/carbon/xenomorph/queen/reach_maturity()
	. = ..()
	recalculate_actions()
	recalculate_health()
	generate_name()

/mob/living/carbon/xenomorph/queen/recalculate_health()
	. = ..()
	if(!is_mature)
		maxHealth *= YOUNG_QUEEN_HEALTH_MULTIPLIER

	if(health > maxHealth)
		health = maxHealth

/mob/living/carbon/xenomorph/queen/Destroy()
	if(observed_xeno)
		overwatch(observed_xeno, TRUE)

	if(hive && hive.living_xeno_queen == src)
		var/mob/living/carbon/xenomorph/queen/next_queen = null
		for(var/mob/living/carbon/xenomorph/queen/queen in hive.totalXenos)
			if(!should_block_game_interaction(queen) && queen != src && !QDELETED(queen))
				next_queen = queen
				break
		hive.set_living_xeno_queen(next_queen) // either null or a queen

	return ..()

/mob/living/carbon/xenomorph/queen/Life(delta_time)
	..()

	if(stat != DEAD)
		if(++breathing_counter >= rand(22, 27)) //Increase the breathing variable each tick. Play it at random intervals.
			playsound(loc, pick('sound/voice/alien_queen_breath1.ogg', 'sound/voice/alien_queen_breath2.ogg'), 15, 1, 4)
			breathing_counter = 0 //Reset the counter

		if(observed_xeno)
			if(observed_xeno.stat == DEAD || QDELETED(observed_xeno))
				overwatch(observed_xeno, TRUE)

		switch(queen_stamina)
			if(0 to 120)
				stamina_tier = 0
			if(121 to 240)
				stamina_tier = 1
			if(241 to 360)
				stamina_tier = 2
			if(361 to 480)
				stamina_tier = 3
			if(481 to 600)
				stamina_tier = 4

		if(ovipositor && !is_mob_incapacitated(TRUE))
			egg_amount += 0.07 //one egg approximately every 30 seconds
			if(egg_amount >= 1)
				if(isturf(loc))
					var/turf/T = loc
					if(length(T.contents) <= 25) //so we don't end up with a million object on that turf.
						egg_amount--
						new /obj/item/xeno_egg(loc, hivenumber)

			if(stamina != 0)
				modify_stamina(stamina_gain) // Approx. 1 stamina per second based on how ticks work

			var/current_presence
			if(current_queen_eye)
				current_presence = current_queen_eye
			else
				current_presence = src
			var/turf/turf = get_turf(current_presence)
			if(hostiles_in_proximity(turf)) // Check if hostiles are close to wherever you are doing stuff (i.e. where your Queen Eye is if you're using that)
				building_mult = 2
			else
				building_mult = 0.7

		if(!ovipositor)
			if(stamina_drain_delay_active == TRUE)
				if(hostiles_in_proximity(get_turf(src))) // If someone is near the Queen, disable this grace period
					stamina_drain_delay_active = FALSE
				else
					stamina_drain_delay_countdown(stamina_drain)

			if(queen_stamina > 0)
				if(stamina_drain_delay_active != TRUE)
					modify_stamina(stamina_drain) // Also approx. 1 stamina per second
				stamina_speed_buff(stamina_tier)

/mob/living/carbon/xenomorph/queen/proc/hostiles_in_proximity(turf/current_turf)
	var/list/mobs_in_range = oviewers(7, current_turf)

	for(var/mob/living/carbon/mob in mobs_in_range)
		if(mob.stat == DEAD || HAS_TRAIT(mob, TRAIT_NESTED) || HAS_TRAIT(mob, TRAIT_CLOAKED))
			continue
		if(src.can_not_harm(mob))
			continue

		return TRUE

	return FALSE

/mob/living/carbon/xenomorph/queen/proc/modify_stamina(amount)
	queen_stamina += amount
	if(queen_stamina > stamina_cap)
		queen_stamina = stamina_cap
	if(queen_stamina < 0)
		queen_stamina = 0

/mob/living/carbon/xenomorph/queen/proc/stamina_drain_delay_countdown(amount)
	stamina_drain_delay += amount
	if(stamina_drain_delay < 0)
		stamina_drain_delay = 0
		stamina_drain_delay_active = FALSE

/mob/living/carbon/xenomorph/queen/proc/stamina_speed_buff(gear = 0)
	var/speed_buff = 0
	switch(gear)
		if(0)
			speed_buff = 0
		if(1)
			speed_buff = -0.3
		if(2)
			speed_buff = -0.6
		if(3)
			speed_buff = -0.9
		if(4)
			speed_buff = -1.2
	speed_modifier = speed_buff
	recalculate_speed()

/mob/living/carbon/xenomorph/queen/get_status_tab_items()
	. = ..()
	var/stored_larvae = GLOB.hive_datum[hivenumber].stored_larva
	var/xeno_leader_num = hive?.queen_leader_limit - length(hive?.open_xeno_leader_positions)

	. += "Pooled Larvae: [stored_larvae]"
	. += "Leaders: [xeno_leader_num] / [hive?.queen_leader_limit]"
	. += "Royal Resin: [hive?.buff_points]"
	if(queen_stamina != 0)
		. += "Vigor: [round((queen_stamina / stamina_cap) * 100, 0.01)]%"
	if(!is_mature && maturity_timer_id != TIMER_ID_NULL)
		. += "Maturity: [time2text(timeleft(maturity_timer_id), "mm:ss")] remaining"

/mob/living/carbon/xenomorph/queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(!check_state())
		return
	if(last_special > world.time)
		return
	if(!check_plasma(50))
		return
	use_plasma(50)

	var/txt = strip_html(input("Set the hive's orders to what? Leave blank to clear it.", "Hive Orders",""))
	if(txt)
		xeno_message("<B>The Queen's will overwhelms your instincts...</B>", 3, hivenumber)
		xeno_message("<B>\""+txt+"\"</B>", 3, hivenumber)
		xeno_maptext(txt, "Hive Orders Updated", hivenumber)
		hive.hive_orders = txt
		log_hiveorder("[key_name(usr)] has set the Hive Order to: [txt]")
	else
		hive.hive_orders = ""

	last_special = world.time + 15 SECONDS

/mob/living/carbon/xenomorph/queen/proc/hive_message()
	set category = "Alien"
	set name = "Word of the Queen (50)"
	set desc = "Send a message to all aliens in the hive that is big and visible"
	if(client.prefs.muted & MUTE_IC)
		to_chat(src, SPAN_DANGER("You cannot send Announcements (muted)."))
		return
	if(health <= 0)
		to_chat(src, SPAN_WARNING("You can't do that while unconscious."))
		return FALSE
	if(!check_plasma(50))
		return FALSE

	// Get a reference to the ability to utilize cooldowns
	var/datum/action/xeno_action/onclick/queen_word/word_ability
	for(var/datum/action/xeno_action/action in actions)
		if(istype(action, /datum/action/xeno_action/onclick/queen_word))
			word_ability = action
			if(!word_ability.action_cooldown_check())
				return FALSE
			break

	var/input = stripped_multiline_input(src, "This message will be broadcast throughout the hive.", "Word of the Queen", "")
	if(!input)
		return FALSE

	use_plasma(50)
	if(word_ability)
		word_ability.apply_cooldown()

	xeno_announcement(input, hivenumber, "The words of the [name] reverberate in our head...")

	message_admins("[key_name_admin(src)] has created a Word of the Queen report:")
	log_admin("[key_name_admin(src)] Word of the Queen: [input]")
	return TRUE

/mob/living/carbon/xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(stat)
		to_chat(src, SPAN_WARNING("You can't do that now."))
		return

	if(!hive)
		to_chat(src, SPAN_WARNING("You can't do that now."))
		CRASH("[src] attempted to toggle slashing without a linked hive")

	if(pslash_delay)
		to_chat(src, SPAN_WARNING("You must wait a bit before you can toggle this again."))
		return

	pslash_delay = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/xenomorph, do_claw_toggle_cooldown)), 30 SECONDS)

	var/choice = tgui_input_list(usr, "Choose which level of slashing hosts to permit to your hive.","Harming", list("Allowed", "Restricted - Hosts of Interest", "Forbidden"), theme="hive_status")

	if(choice == "Allowed")
		to_chat(src, SPAN_XENONOTICE("You allow slashing."))
		xeno_message(SPAN_XENOANNOUNCE("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!"), 2, hivenumber)
		hive.slashing_allowed = XENO_SLASH_ALLOWED
	else if(choice == "Forbidden")
		to_chat(src, SPAN_XENONOTICE("You forbid slashing entirely."))
		xeno_message(SPAN_XENOANNOUNCE("The Queen has <b>forbidden</b> the harming of hosts. You can no longer slash your enemies."), 2, hivenumber)
		hive.slashing_allowed = XENO_SLASH_FORBIDDEN

/mob/living/carbon/xenomorph/proc/do_claw_toggle_cooldown()
	pslash_delay = FALSE

/mob/living/carbon/xenomorph/proc/construction_toggle()
	set name = "Permit/Disallow Construction Placement"
	set desc = "Allows you to permit the hive to place construction nodes freely."
	set category = "Alien"

	if(stat)
		to_chat(src, SPAN_WARNING("You can't do that now."))
		return

	var/choice = tgui_input_list(usr, "Choose which level of construction placement freedom to permit to your hive.","Harming", list("Queen", "Leaders", "Anyone"), theme="hive_status")

	if(choice == "Anyone")
		to_chat(src, SPAN_XENONOTICE("You allow construction placement to all builder castes."))
		xeno_message("The Queen has <b>permitted</b> the placement of construction nodes to all builder castes!", hivenumber = src.hivenumber)
		hive.construction_allowed = NORMAL_XENO
	else if(choice == "Leaders")
		to_chat(src, SPAN_XENONOTICE("You restrict construction placement to leaders only."))
		xeno_message("The Queen has <b>restricted</b> the placement of construction nodes to leading builder castes only.", hivenumber = src.hivenumber)
		hive.construction_allowed = XENO_LEADER
	else if(choice == "Queen")
		to_chat(src, SPAN_XENONOTICE("You forbid construction placement entirely."))
		xeno_message("The Queen has <b>forbidden</b> the placement of construction nodes to all but herself.", hivenumber = src.hivenumber)
		hive.construction_allowed = XENO_QUEEN

/mob/living/carbon/xenomorph/proc/destruction_toggle()
	set name = "Permit/Disallow Special Structure Destruction"
	set desc = "Allows you to permit the hive to destroy special structures freely."
	set category = "Alien"

	if(stat)
		to_chat(src, SPAN_WARNING("You can't do that now."))
		return

	var/choice = tgui_input_list(usr, "Choose which level of destruction freedom to permit to your hive.","Harming", list("Queen", "Leaders", "Anyone"), theme="hive_status")

	if(choice == "Anyone")
		to_chat(src, SPAN_XENONOTICE("You allow special structure destruction to all builder castes and leaders."))
		xeno_message("The Queen has <b>permitted</b> the destruction of special structures to all builder castes and leaders!", hivenumber = src.hivenumber)
		hive.destruction_allowed = NORMAL_XENO
	else if(choice == "Leaders")
		to_chat(src, SPAN_XENONOTICE("You restrict special structure destruction to leaders only."))
		xeno_message("The Queen has <b>restricted</b> the destruction of special structures to leaders only.", hivenumber = src.hivenumber)
		hive.destruction_allowed = XENO_LEADER
	else if(choice == "Queen")
		to_chat(src, SPAN_XENONOTICE("You forbid special structure destruction entirely."))
		xeno_message("The Queen has <b>forbidden</b> the destruction of special structures to all but herself.", hivenumber = src.hivenumber)
		hive.destruction_allowed = XENO_QUEEN

/mob/living/carbon/xenomorph/proc/toggle_unnesting()
	set name = "Permit/Disallow Unnesting"
	set desc = "Allows you to restrict unnesting to drones."
	set category = "Alien"

	if(stat)
		to_chat(src, SPAN_WARNING("You can't do that now."))
		return

	hive.unnesting_allowed = !hive.unnesting_allowed

	if(hive.unnesting_allowed)
		to_chat(src, SPAN_XENONOTICE("You have allowed everyone to unnest hosts."))
		xeno_message("The Queen has allowed everyone to unnest hosts.", hivenumber = src.hivenumber)
	else
		to_chat(src, SPAN_XENONOTICE("You have forbidden anyone to unnest hosts, except for the drone caste."))
		xeno_message("The Queen has forbidden anyone to unnest hosts, except for the drone caste.", hivenumber = src.hivenumber)

/mob/living/carbon/xenomorph/queen/handle_screech_act(mob/self, mob/living/carbon/xenomorph/queen/queen)
	return COMPONENT_SCREECH_ACT_CANCEL

/mob/living/carbon/xenomorph/queen/proc/screech_ready()
	to_chat(src, SPAN_WARNING("You feel your throat muscles vibrate. You are ready to screech again."))
	for(var/Z in actions)
		var/datum/action/A = Z
		A.update_button_icon()

/mob/living/carbon/xenomorph/queen/proc/queen_gut(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_HAULED))
		to_chat(src, SPAN_XENOWARNING("[target] needs to be released first."))
		return FALSE
	var/mob/living/carbon/victim = target

	if(get_dist(src, victim) > 1)
		return FALSE

	if(!check_state())
		return FALSE

	if(issynth(victim))
		var/obj/limb/head/synthhead = victim.get_limb("head")
		if(synthhead.status & LIMB_DESTROYED)
			return FALSE

	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/xeno = victim
		if(hivenumber == xeno.hivenumber)
			to_chat(src, SPAN_WARNING("You can't bring yourself to harm a fellow sister to this magnitude."))
			return FALSE

	var/turf/cur_loc = victim.loc
	if(!istype(cur_loc))
		return FALSE

	if(action_busy)
		return FALSE

	if(!check_plasma(200))
		return FALSE

	visible_message(SPAN_XENOWARNING("[src] begins slowly lifting [victim] into the air."),
	SPAN_XENOWARNING("You begin focusing your anger as you slowly lift [victim] into the air."))
	if(do_after(src, 80, INTERRUPT_ALL, BUSY_ICON_HOSTILE, victim))
		if(!victim)
			return FALSE
		if(victim.loc != cur_loc)
			return FALSE
		if(!check_plasma(200))
			return FALSE

		use_plasma(200)

		visible_message(SPAN_XENODANGER("[src] viciously smashes and wrenches [victim] apart!"),
		SPAN_XENODANGER("You suddenly unleash pure anger on [victim], instantly wrenching \him apart!"))
		emote("roar")

		attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [key_name(victim)]</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [key_name(src)]</font>")
		victim.gib(create_cause_data("Queen gutting", src)) //Splut

		stop_pulling()
		return TRUE

/mob/living/carbon/xenomorph/queen/death(cause, gibbed)
	if(src == hive?.living_xeno_queen)
		UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
		hive.xeno_queen_timer = world.time + XENO_QUEEN_DEATH_DELAY

		// Reset the banished ckey list
		if(length(hive.banished_ckeys))
			for(var/mob/living/carbon/xenomorph/target_xeno in hive.totalXenos)
				if(!target_xeno.ckey)
					continue
				for(var/mob_name in hive.banished_ckeys)
					if(target_xeno.ckey == hive.banished_ckeys[mob_name])
						target_xeno.banished = FALSE
						target_xeno.hud_update_banished()
						target_xeno.lock_evolve = FALSE
			hive.banished_ckeys = list()

	icon = queen_standing_icon
	return ..()

/mob/living/carbon/xenomorph/queen/proc/mount_ovipositor()
	if(ovipositor)
		return //sanity check
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, OVIPOSITOR_TRAIT)
	set_body_position(STANDING_UP)
	set_resting(FALSE)
	ovipositor = TRUE
	special_state = TRUE

	set_resin_build_order(GLOB.resin_build_order_ovipositor) // This needs to occur before we update the abilities so we can update the choose resin icon
	for(var/datum/action/xeno_action/action in actions)
		// Also update the choose_resin icon since it resets
		if(istype(action, /datum/action/xeno_action/onclick/choose_resin))
			var/datum/action/xeno_action/onclick/choose_resin/choose_resin_ability = action
			if(choose_resin_ability)
				choose_resin_ability.update_button_icon(selected_resin)

	add_verb(src, /mob/living/carbon/xenomorph/proc/xeno_tacmap)

	ADD_TRAIT(src, TRAIT_ABILITY_NO_PLASMA_TRANSFER, TRAIT_SOURCE_ABILITY("Ovipositor"))
	ADD_TRAIT(src, TRAIT_ABILITY_OVIPOSITOR, TRAIT_SOURCE_ABILITY("Ovipositor"))

	extra_build_dist = IGNORE_BUILD_DISTANCE
	egg_planting_range = 3
	anchored = TRUE
	update_icons()
	bubble_icon_x_offset = 32
	bubble_icon_y_offset = 32

	for(var/mob/living/carbon/xenomorph/leader in hive.xeno_leader_list)
		leader.handle_xeno_leader_pheromones()

	stamina_drain_delay = stamina_drain_delay_duration

	xeno_message(SPAN_XENOANNOUNCE("The Queen has grown an ovipositor, evolution progress resumed."), 3, hivenumber)

	START_PROCESSING(SShive_status, hive.hive_ui)

	SEND_SIGNAL(src, COMSIG_QUEEN_MOUNT_OVIPOSITOR)

/mob/living/carbon/xenomorph/queen/proc/dismount_ovipositor(instant_dismount)
	set waitfor = 0
	if(!instant_dismount)
		if(observed_xeno)
			overwatch(observed_xeno, TRUE)
		flick("ovipositor_dismount", src)
		sleep(5)
	else
		flick("ovipositor_dismount_destroyed", src)
		sleep(5)

	if(!ovipositor)
		return
	ovipositor = FALSE
	special_state = FALSE
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, OVIPOSITOR_TRAIT)
	update_icons()
	bubble_icon_x_offset = initial(bubble_icon_x_offset)
	bubble_icon_y_offset = initial(bubble_icon_y_offset)
	new /obj/ovipositor(loc)

	if(observed_xeno)
		overwatch(observed_xeno, TRUE)
	zoom_out()

	set_resin_build_order(GLOB.resin_build_order_drone) // This needs to occur before we update the abilities so we can update the choose resin icon

	remove_verb(src, /mob/living/carbon/xenomorph/proc/xeno_tacmap)

	REMOVE_TRAIT(src, TRAIT_ABILITY_NO_PLASMA_TRANSFER, TRAIT_SOURCE_ABILITY("Ovipositor"))
	REMOVE_TRAIT(src, TRAIT_ABILITY_OVIPOSITOR, TRAIT_SOURCE_ABILITY("Ovipositor"))

	recalculate_actions()

	egg_amount = 0
	extra_build_dist = initial(extra_build_dist)
	egg_planting_range = initial(egg_planting_range)
	for(var/datum/action/xeno_action/action in actions)
		if(istype(action, /datum/action/xeno_action/onclick/grow_ovipositor))
			var/datum/action/xeno_action/onclick/grow_ovipositor/ovi_ability = action
			ovi_ability.apply_cooldown()
			break
	anchored = FALSE

	for(var/mob/living/carbon/xenomorph/leader in hive.xeno_leader_list)
		leader.handle_xeno_leader_pheromones()

	stamina_drain_delay_active = TRUE

	if(stamina_tier != 0)
		switch(stamina_tier)
			if(1 to 3)
				emote("tail")
			if(4)
				emote("roar")

	if(!instant_dismount)
		xeno_message(SPAN_XENOANNOUNCE("The Queen has shed her ovipositor, evolution progress paused."), 3, hivenumber)

	SEND_SIGNAL(src, COMSIG_QUEEN_DISMOUNT_OVIPOSITOR, instant_dismount)

/mob/living/carbon/xenomorph/queen/handle_special_state()
	if(ovipositor)
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/queen/handle_special_wound_states(severity)
	. = ..()
	if(ovipositor)
		return "Queen_ovipositor_[severity]" // I don't actually have it, but maybe one day.

/mob/living/carbon/xenomorph/queen/gib(datum/cause_data/cause = create_cause_data("gibbing", src))
	death(cause, 1)

/datum/behavior_delegate/queen
	name = "Queen Behavior Delegate"

/datum/behavior_delegate/queen/on_update_icons()
	if(bound_xeno.stat == DEAD)
		return

	var/mob/living/carbon/xenomorph/queen/Queen = bound_xeno
	if(Queen.ovipositor)
		Queen.icon = Queen.queen_ovipositor_icon
		Queen.icon_state = "[Queen.get_strain_name()] Queen Ovipositor"
		return TRUE

	// Switch icon back and then let normal icon behavior happen
	Queen.icon = Queen.queen_standing_icon

/mob/living/carbon/xenomorph/queen/alter_ghost(mob/dead/observer/ghost)
	ghost.icon = queen_standing_icon
	return ..()

/mob/living/carbon/xenomorph/queen/point_to_atom(atom/target_atom, turf/target_turf)
	recently_pointed_to = world.time + 1 SECONDS

	var/obj/effect/overlay/temp/point/big/greyscale/point = new(target_turf, src, target_atom)
	point.color = "#a800a8"

	visible_message("<b>[src]</b> points to [target_atom]", null, null, 5)
