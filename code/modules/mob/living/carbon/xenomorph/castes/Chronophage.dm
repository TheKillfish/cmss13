/datum/caste_datum/chronophage
	caste_type = XENO_CASTE_CHRONOPHAGE
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_4
	melee_vehicle_damage = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_8

	behavior_delegate_type = /datum/behavior_delegate/chronophage_base

	deevolves_to = list(XENO_CASTE_LURKER)
	caste_desc = "A fast, powerful backline combatant."
	evolution_allowed = FALSE

	heal_resting = 1.5

	minimum_evolve_time = 40 MINUTES

	minimap_icon = "lurker"

/mob/living/carbon/xenomorph/chronophage
	caste_type = XENO_CASTE_CHRONOPHAGE
	name = XENO_CASTE_CHRONOPHAGE
	desc = "A beefy, fast alien with sharp claws."
	icon_size = 48
	icon_state = "Lurker Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	xenonid_pixel_x = -9
	tier = 2
	organ_value = 2000
	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough,
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/spatial_lurch,
		/datum/action/xeno_action/onclick/time_carapace,
		/datum/action/xeno_action/activable/place_temporal_cocoon,
		/datum/action/xeno_action/onclick/temporal_return,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	tackle_min = 2
	tackle_max = 6

	icon_xeno = 'icons/mob/xenos/castes/tier_2/lurker.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_2/lurker.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Drone_1","Drone_2","Drone_3")
	weed_food_states_flipped = list("Drone_1","Drone_2","Drone_3")

	skull = /obj/item/skull/lurker
	pelt = /obj/item/pelt/lurker

/datum/behavior_delegate/chronophage_base
	name = "Base Chronophage Behavior Delegate"

	// Instability vars
	var/time_instability = 0
	var/maximum_instability = 100
	var/current_doubling_duration = 0
	var/timewarping_disabled = FALSE

/datum/behavior_delegate/chronophage_base/proc/instability_buildup_and_effects(instability_added = 0)
	var/mob/living/carbon/xenomorph/chronophage/time_xeno = bound_xeno

	// First we handle damage from instability buildup
	if(time_instability > 0)
		time_xeno.apply_damage(time_instability/2, BRUTE)
		var/instability_message = ""
		switch(time_instability)
			if(20 to 40)
				instability_message = "We feel our carapace twist and shudder uncomfortably as we warp time!"
			if(41 to 60)
				instability_message = "We feel our carapace warp and wither as we warp time!"
			if(61 to 80)
				instability_message = "We feel our carapace split and crumble as we warp time!"
			if(81 to 100)
				instability_message = "We feel our carapace tear and chunks slough off as we warp time!"

		to_chat(time_xeno, SPAN_XENOHIGHDANGER(instability_message))

	// Next we add instability buildup
	var/instability_sum = time_instability + instability_added
	if(instability_sum > maximum_instability)
		instability_sum = 100
	time_instability = instability_sum

	// Finally we see if we should have timewarping abilities disabled
	if(time_instability == maximum_instability)
		timewarping_disabled = TRUE

/datum/behavior_delegate/chronophage_base/on_life()
	var/mob/living/carbon/xenomorph/chronophage/time_xeno = bound_xeno

	if(time_instability > 0)


/datum/action/xeno_action/activable/spatial_lurch/use_ability(atom/target)

/datum/action/xeno_action/onclick/time_carapace/use_ability(atom/target)

/datum/action/xeno_action/activable/place_temporal_cocoon/use_ability(atom/target)

/datum/action/xeno_action/onclick/temporal_return/use_ability(atom/target)
