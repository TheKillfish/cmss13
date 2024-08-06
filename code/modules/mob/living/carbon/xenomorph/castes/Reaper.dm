/datum/caste_datum/reaper
	caste_type = XENO_CASTE_REAPER
	caste_desc = "A flexible frontline supporter."
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_9
	plasma_gain = XENO_PLASMA_GAIN_TIER_6
	plasma_max = XENO_PLASMA_TIER_5
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_3

	evolution_allowed = FALSE
	deevolves_to = list(XENO_CASTE_CARRIER)
	throwspeed = SPEED_AVERAGE
	can_hold_eggs = CAN_HOLD_ONE_HAND
	weed_level = WEED_LEVEL_STANDARD

	behavior_delegate_type = /datum/behavior_delegate/base_reaper

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 35
	tacklestrength_min = 4
	tacklestrength_max = 5

	aura_strength = 3

	minimum_evolve_time = 15 MINUTES

/mob/living/carbon/xenomorph/reaper
	caste_type = XENO_CASTE_REAPER
	name = XENO_CASTE_REAPER
	desc = "A horrifying alien, like a false angel. A sickening stench follows it wherever it goes."
	icon_size = 64
	icon_xeno = 'icons/mob/xenos/reaper.dmi'
	icon_state = "Reaper Walking"
	plasma_types = list(PLASMA_PURPLE, PLASMA_PHEROMONE)

	drag_delay = 6

	mob_size = MOB_SIZE_BIG
	tier = 3
	pixel_x = -16
	old_x = -16

	organ_value = 3000
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/place_construction/not_primary,
		/datum/action/xeno_action/onclick/plant_weeds/not_primary,
		/datum/action/xeno_action/activable/flesh_harvest, //first macro
		/datum/action/xeno_action/activable/claw_strike, //second macro
		/datum/action/xeno_action/activable/raise_servant, //third macro
		/datum/action/xeno_action/onclick/tacmap,
	)

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	icon_xenonid = 'icons/mob/xenonids/reaper.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Reaper_1","Reaper_2","Reaper_3")
	weed_food_states_flipped = list("Reaper_1","Reaper_2","Reaper_3")

/datum/behavior_delegate/base_reaper
	name = "Base Reaper Behavior Delegate"

	var/flesh_resin = 0
	var/flesh_resin_max = 1000
	var/pause_drain = FALSE
	var/unpause_coming = FALSE
	var/pause_dur = 20 SECONDS
	var/harvesting = FALSE // So you can't harvest multiple corpses at once
	var/making_servant = FALSE // So we can't make multiple at once
	var/list/mob/living/simple_animal/hostile/alien/rotdrone/servants = list() // List of active rotdrones
	var/servant_max = 1 // How many rotdrones one Reaper can have at once

/datum/behavior_delegate/base_reaper/proc/unpause_drain()
	to_chat(bound_xeno, SPAN_XENONOTICE("Our body resumes absorbation of flesh resin."))
	pause_drain = FALSE
	unpause_coming = FALSE
	pause_dur = 20 SECONDS

/datum/behavior_delegate/base_reaper/proc/drain_resin()
	flesh_resin -= 1
	if(flesh_resin > 200)
		flesh_resin -= 1

/datum/behavior_delegate/base_reaper/append_to_stat()
	. = ..()
	. += "Flesh Resin: [flesh_resin]"

/datum/behavior_delegate/base_reaper/melee_attack_additional_effects_target(mob/living/carbon/target_mob)
	flesh_resin += 5

/datum/behavior_delegate/base_reaper/on_life()
	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()
	var/percentage_flesh = round((flesh_resin / flesh_resin_max) * 100, 10)
	if(percentage_flesh)
		holder.overlays += image('icons/mob/hud/hud.dmi', "xenoenergy[percentage_flesh]")

	if(flesh_resin > flesh_resin_max)
		flesh_resin = flesh_resin_max
	if(flesh_resin < 0)
		flesh_resin = 0

	if(pause_drain == TRUE && unpause_coming == FALSE)
		unpause_coming = TRUE
		addtimer(CALLBACK(src, PROC_REF(unpause_drain)), pause_dur)

	if(flesh_resin > 0 && pause_drain == FALSE)
		drain_resin()
	else
		return ..()

