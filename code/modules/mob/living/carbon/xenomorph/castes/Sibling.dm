/datum/caste_datum/lurker
	caste_type = XENO_CASTE_LURKER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_1
	melee_vehicle_damage = 0
	max_health = XENO_HEALTH_TIER_1
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_9

	evolution_allowed = FALSE
	can_be_revived = FALSE

	behavior_delegate_type = /datum/behavior_delegate/sibling_base

	caste_desc = "A simpleminded minion, part of a pack."

	minimap_icon = "lesser_drone"

/mob/living/carbon/xenomorph/sibling
	caste_type = XENO_CASTE_SIBLING
	name = XENO_CASTE_SIBLING
	desc = "An underdeveloped, malformed alien."
	icon_size = 64
	icon_state = "Runner Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -16
	old_x = -16
	base_pixel_x = 0
	base_pixel_y = -20
	tier = 0
	mob_flags = NOBIOSCAN
	life_value = 0
	default_honor_value = 0
	show_only_numbers = TRUE
	counts_for_slots = FALSE
	counts_for_roundend = FALSE
	refunds_larva_if_banished = FALSE
	crit_health = -50
	gib_chance = 100
	acid_blood_damage = 10
	organ_value = 0
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 40
	tacklestrength_min = 2
	tacklestrength_max = 2

	icon_xeno = 'icons/mob/xenos/runner.dmi'
	icon_xenonid = 'icons/mob/xenonids/runner.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Runner_1","Runner_2","Runner_3")
	weed_food_states_flipped = list("Runner_1","Runner_2","Runner_3")

	/// For determining if this is to operate on AI functions or be player controlled
	var/got_client = FALSE

/datum/behavior_delegate/sibling_base
	name = "Base Sibling Behavior Delegate"

/mob/living/carbon/xenomorph/sibling/Login()
	var/last_ckey_inhabited = persistent_ckey
	. = ..()
	if(ckey == last_ckey_inhabited)
		return
