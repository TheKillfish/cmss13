/datum/caste_datum/hunter
	caste_type = XENO_CASTE_HUNTER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_1
	max_health = XENO_HEALTH_TIER_3
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7


	//available_strains = list()
	behavior_delegate_type = /datum/behavior_delegate/hunter_base

	deevolves_to = list(XENO_CASTE_RUNNER)
	caste_desc = "A fast backliner leading a pack of simpleminded minions."
	evolution_allowed = FALSE

	minimum_evolve_time = 9 MINUTES

	minimap_icon = "runner"

/mob/living/carbon/xenomorph/hunter
	caste_type = XENO_CASTE_HUNTER
	name = XENO_CASTE_HUNTER
	desc = "An agile-looking alien that looks like the leader of a pack."
	icon_size = 48
	icon_state = "Lurker Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	tier = 2
	organ_value = 2000
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/active_toggle/quadruped,
		/datum/action/xeno_action/onclick/call_pack,
		/datum/action/xeno_action/activable/cannibalize,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 40
	tacklestrength_min = 4
	tacklestrength_max = 4

	icon_xeno = 'icons/mob/xenos/lurker.dmi'
	icon_xenonid = 'icons/mob/xenonids/lurker.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Drone_1","Drone_2","Drone_3")
	weed_food_states_flipped = list("Drone_1","Drone_2","Drone_3")

	var/total_pack = 3

/mob/living/carbon/xenomorph/hunter/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_XENO_ALIEN_ATTACK, PROC_REF(postattack))

/mob/living/carbon/xenomorph/hunter/proc/postattack(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	SEND_SIGNAL(src, COMSIG_XENOMINION_GLOBALORDER, /*attack*/, target)

/datum/behavior_delegate/hunter_base
	name = "Base Hunter Behavior Delegate"
