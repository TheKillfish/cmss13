/datum/caste_datum/infiltrator
	caste_type = XENO_CASTE_INFILTRATOR
	tier = 4

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = XENO_DAMAGE_TIER_2
	max_health = XENO_HEALTH_TIER_4
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7

	evolves_to = null
	deevolves_to = null
	evolution_allowed = FALSE
	can_be_revived = FALSE
	is_intelligent = TRUE

	// Always able to heal, but heals slower
	innate_healing = TRUE
	heal_resting = 0.5
	heal_standing = 0.2
	heal_knocked_out = 0.1

	behavior_delegate_type = /datum/behavior_delegate/infiltrator_base

	minimum_evolve_time = 30 MINUTES
	minimap_icon = "lurker"

	royal_caste = TRUE

/mob/living/carbon/xenomorph/infiltrator
	caste_type = XENO_CASTE_INFILTRATOR
	name = XENO_CASTE_INFILTRATOR
	desc = "A whispy alien with unusually great intellect."
	icon_size = 48
	icon_state = "Infiltrator Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	tier = 4
	organ_value = 10000
	counts_for_slots = FALSE
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/spystab,
		/datum/action/xeno_action/onclick/vanish,
		/datum/action/xeno_action/onclick/spy_dodge,
		/datum/action/xeno_action/onclick/smokescreen,
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	universal_understand = TRUE

	tackle_min = 2
	tackle_max = 6

	icon_xeno = 'icons/mob/xenos/infiltrator.dmi'
	icon_xenonid = 'icons/mob/xenonids/lurker.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Drone_1","Drone_2","Drone_3")
	weed_food_states_flipped = list("Drone_1","Drone_2","Drone_3")

/datum/behavior_delegate/infiltrator_base
	name = "Base Infiltrator Behavior Delegate"

	var/vanished = FALSE
	var/dodging = FALSE
	var/smokeescape = FALSE

/datum/behavior_delegate/infiltrator_base/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/onclick/vanish/sneaky = get_action(bound_xeno, /datum/action/xeno_action/onclick/vanish)
	if(sneaky)
		sneaky.exit_vanish()

/datum/behavior_delegate/infiltrator_base/proc/decloak_handler(mob/source)
	SIGNAL_HANDLER
	var/datum/action/xeno_action/onclick/vanish/sneaky = get_action(bound_xeno, /datum/action/xeno_action/onclick/vanish)
	if(istype(sneaky))
		sneaky.exit_vanish() // Partial refund of remaining time

/// Implementation for enabling invisibility.
/datum/behavior_delegate/infiltrator_base/proc/on_invisibility()
	ADD_TRAIT(bound_xeno, TRAIT_CLOAKED, TRAIT_SOURCE_ABILITY("cloak"))
	RegisterSignal(bound_xeno, COMSIG_MOB_EFFECT_CLOAK_CANCEL, PROC_REF(decloak_handler))
	vanished = TRUE

/// Implementation for disabling invisibility.
/datum/behavior_delegate/infiltrator_base/proc/on_invisibility_off()
	vanished = FALSE
	REMOVE_TRAIT(bound_xeno, TRAIT_CLOAKED, TRAIT_SOURCE_ABILITY("cloak"))
	UnregisterSignal(bound_xeno, COMSIG_MOB_EFFECT_CLOAK_CANCEL)
