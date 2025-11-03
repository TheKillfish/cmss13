/datum/caste_datum/analyzer
	caste_type = XENO_CASTE_ANALYZER
	caste_desc = "."
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = XENO_DAMAGE_TIER_2
	max_health = XENO_HEALTH_TIER_6
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_10
	xeno_explosion_resistance = XENO_NO_EXPLOSIVE_ARMOR
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7
/*
	available_strains = list(
		/datum/xeno_strain/espionage,
		/datum/xeno_strain/warden,
	)
*/
	behavior_delegate_type = /datum/behavior_delegate/analyzer_base
	evolution_allowed = FALSE
	deevolves_to = list(XENO_CASTE_DRONE)
	can_hold_facehuggers = 1
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	acid_level = 1
	weed_level = WEED_LEVEL_STANDARD
	max_build_dist = 1

	tacklestrength_min = 3
	tacklestrength_max = 4

	minimum_evolve_time = 9 MINUTES

	minimap_icon = "carrier"

/datum/caste_datum/analyzer/New()
	. = ..()

	resin_build_order = GLOB.resin_build_order_analyzer

/mob/living/carbon/xenomorph/analyzer
	caste_type = XENO_CASTE_ANALYZER
	name = XENO_CASTE_ANALYZER
	desc = "."
	tier = 2

	icon = 'icons/mob/xenos/castes/tier_2/analyzer.dmi'
	icon_size = 64
	icon_state = "Analyzer Walking"
	pixel_x = -16
	old_x = -16

	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	organ_value = 2500 // More valuable organ that most T2s

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/place_construction,
		/datum/action/xeno_action/onclick/plant_weeds,
		/datum/action/xeno_action/onclick/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		//datum/action/xeno_action/onclick/
		)

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	icon_xeno = 'icons/mob/xenos/castes/tier_2/analyzer.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_2/analyzer.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Analyzer_1","Analyzer_2","Analyzer_3")
	weed_food_states_flipped = list("Analyzer_1","Analyzer_2","Analyzer_3")

	skull = /obj/item/skull/hivelord
	pelt = /obj/item/pelt/hivelord

/datum/behavior_delegate/analyzer_base
	name = "Base Analyzer Behavior Delegate"
