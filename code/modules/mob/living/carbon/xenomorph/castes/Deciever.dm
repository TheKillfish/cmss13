/* NOTES FOR THINGS TO REMEMBER
	out of laziness, plonk these somewhere to handle tacmap shit
		main_hive.see_humans_on_tacmap = TRUE
		main_hive.tacmap_requires_queen_ovi = FALSE
		SEND_SIGNAL(main_hive, COMSIG_XENO_REVEAL_TACMAP)
*/

/datum/caste_datum/deciever
	caste_type = XENO_CASTE_DECIEVER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_3
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_8
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_6
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_9

	// available_strains = list(/datum/xeno_strain/)
	behavior_delegate_type = /datum/behavior_delegate/deciever_base

	evolution_allowed = FALSE
	deevolves_to = list(XENO_CASTE_LURKER)
	caste_desc = "A subterfuge and Counter Intelligence specialist."

	heal_resting = 1.5

	minimum_evolve_time = 15 MINUTES

	minimap_icon = "lurker"

/mob/living/carbon/xenomorph/deciever
	caste_type = XENO_CASTE_DECIEVER
	name = XENO_CASTE_DECIEVER
	desc = "A fast, tricky alien. Something about it looks odd."
	icon_size = 48
	icon_state = "Deciever Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	tier = 3
	organ_value = 5000 // Trickier than other Xenos
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/radio_tap, // first macro
		//datum/action/xeno_action/onclick/mimicry, // second macro
		//datum/action/xeno_action/onclick/white_noise, // third macro
		//datum/action/xeno_action/onclick/signal_spoofing, // fourth macro
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	claw_type = CLAW_TYPE_SHARP
	always_has_tacmap = TRUE
	understand_no_speak = TRUE

	tackle_min = 3
	tackle_max = 5
	tackle_chance = 35
	tacklestrength_min = 4
	tacklestrength_max = 4

	icon_xeno = 'icons/mob/xenos/castes/tier_3/deciever.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_2/lurker.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Drone_1","Drone_2","Drone_3")
	weed_food_states_flipped = list("Drone_1","Drone_2","Drone_3")

	skull = /obj/item/skull/lurker
	pelt = /obj/item/pelt/lurker

/mob/living/carbon/xenomorph/deciever/Initialize(mapload, mob/living/carbon/xenomorph/oldxeno, h_number)
	. = ..()
	if(behavior_delegate)
		var/datum/behavior_delegate/deciever_base/deciever = behavior_delegate
		deciever.connection = new /obj/item/device/radio/deciever(src)
		deciever.connection.tapping_xeno = src
		deciever.connection.forceMove(src)

/mob/living/carbon/xenomorph/deciever/death(cause, gibbed)
	if(behavior_delegate)
		var/datum/behavior_delegate/deciever_base/deciever = behavior_delegate
		if(deciever.connection != null)
			deciever.connection.frequency = 0
	. = ..()

/mob/living/carbon/xenomorph/deciever/Destroy()
	if(behavior_delegate)
		var/datum/behavior_delegate/deciever_base/deciever = behavior_delegate
		if(deciever.connection != null)
			qdel(deciever.connection)
			deciever.connection = null
	. = ..()

/mob/living/carbon/xenomorph/deciever/resist_fire()
	..()
	SetKnockDown(0.5 SECONDS) // The Deciever is a clever enough bean-o to know slightly better how to extinguish itself

/datum/behavior_delegate/deciever_base
	name = "Base Deciever Behavior Delegate"

	// Tactical Nexus vars
	var/provides_proximity_tacmap = TRUE // If true, the Deciever provides Tacmap to other Xenomorphs nearby. This may be disabled depending on Hive Faction.
	var/proximity_range = 7 // The definition of 'nearby' for provides_proximity_tacmap.
	// Preparation vars
	var/prepared = TRUE // If prepared, the Deciever will recover from stuns much faster.
	var/preparation_time = 30 SECONDS
	var/preparation_timer_id = TIMER_ID_NULL
	// Radio Tap vars
	var/tap_active = FALSE
	var/obj/item/device/radio/deciever/connection = null
	var/mob/living/carbon/human/human_used_for_tapping = null
	var/list/datum/language/stolen_languages = list()
	var/obj/item/device/radio/currently_tapped_radio = null
	var/radio_tap_timer_id = TIMER_ID_NULL
	// Mimicry vars
	var/atom/mimicry_target
	// White Noise vars
	var/white_noise_active = FALSE
	var/white_noise_timer_id = TIMER_ID_NULL
	// Signal Spoof vars
	var/spoofed_iff = null

/datum/action/xeno_action/activable/radio_tap/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	var/datum/behavior_delegate/deciever_base/deciever = xeno.behavior_delegate
	// First use activates the ability, second use de-activates it and initiates cooldown
	if(!deciever.tap_active)
		if(!check_and_use_plasma_owner())
			return

		if((!istype(target, /mob/living/carbon/human)) || (ismonkey(target))) // If they ain't a human or are a monkey, don't search for radios on them
			return

		var/mob/living/carbon/human/target_humanoid = target

		var/radios_found = FALSE
		var/list/found_channels = list()

		for(var/obj/item/device/radio/headset/headset in target_humanoid.contents_recursive())
			var/tapping_channels = headset.channels
			radios_found = TRUE
			if(!(tapping_channels in found_channels))
				found_channels += tapping_channels
				continue

		// If they don't have headsets, broaden search requirements
		if(!radios_found)
			for(var/obj/item/device/radio/radio in target_humanoid.contents_recursive())
				var/tapping_channels = radio.channels
				radios_found = TRUE
				if(!(tapping_channels in found_channels))
					found_channels += tapping_channels
					continue

		// If they have absolutely no radios on them, give some channels as a default dependant on their species
		if(!radios_found)
			if(isyautja(target_humanoid))
				found_channels += YAUT_FREQ // If Preds fuck up and one gets capped and tapped, they deserve to have an intruder listening in
			if(issynth(target_humanoid))
				found_channels += list(COMM_FREQ, PUB_FREQ, COLONY_FREQ) // Command is probably the most valuable of these
			if(ishuman_strict(target_humanoid))
				found_channels += list(PUB_FREQ, COLONY_FREQ) // Not great, better than nothing

		if(length(target_humanoid.languages) != 0)
			deciever.stolen_languages += target_humanoid.languages
		else // In case the target lacks any languages for some reason
			deciever.stolen_languages += LANGUAGE_ENGLISH

		if(length(found_channels) != 0)
			deciever.connection.channels += found_channels
			deciever.connection.listening = TRUE
			xeno.understood_languages += deciever.stolen_languages
			to_chat(xeno, SPAN_XENOBOLDNOTICE("We have tapped into some channels!"))

	return ..()
