/datum/caste_datum/bulldozer
	caste_type = XENO_CASTE_BULLDOZER
	caste_desc = "The hive's living siege weapon."
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_6
	melee_damage_upper = XENO_DAMAGE_TIER_6
	melee_vehicle_damage = XENO_DAMAGE_TIER_9
	max_health = XENO_HEALTH_QUEEN
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_QUEEN

	evolution_allowed = FALSE
	can_be_revived = FALSE
	can_vent_crawl = 0
	attack_delay = 2

	behavior_delegate_type = /datum/behavior_delegate/bulldozer_base

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 35
	tacklestrength_min = 4
	tacklestrength_max = 5

	minimum_evolve_time = 30 MINUTES
	minimap_icon = "warrior"

	royal_caste = TRUE

/mob/living/carbon/xenomorph/warrior
	caste_type = XENO_CASTE_BULLDOZER
	name = XENO_CASTE_WARRIOR
	desc = "A tower of chitin and raw strength. A living siege weapon."
	icon = 'icons/mob/xenos/warrior.dmi'
	icon_size = 64
	icon_state = "Warrior Walking"
	plasma_types = list(PLASMA_CHITIN)
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_IMMOBILE
	tier = 3
	pull_speed = 3
	small_explosives_stun = FALSE
	organ_value = 10000
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/bulldozer,
		/datum/action/xeno_action/active_toggle/allfours,
		/datum/action/xeno_action/onclick/tacmap,
	)

	claw_type = CLAW_TYPE_VERY_SHARP

	icon_xeno = 'icons/mob/xenos/warrior.dmi'
	icon_xenonid = 'icons/mob/xenonids/warrior.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Warrior_1","Warrior_2","Warrior_3")
	weed_food_states_flipped = list("Warrior_1","Warrior_2","Warrior_3")

/datum/behavior_delegate/bulldozer_base
	name = "Base Bulldozer Behavior Delegate"

	var/allfours = FALSE
