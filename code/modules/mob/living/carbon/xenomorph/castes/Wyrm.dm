/datum/caste_datum/wyrm
	caste_type = XENO_CASTE_WYRM
	tier = 4

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = XENO_DAMAGE_TIER_5
	max_health = XENO_HEALTH_TIER_7
	plasma_gain = XENO_PLASMA_GAIN_TIER_6
	plasma_max = XENO_PLASMA_TIER_8
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_3

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 20
	tacklestrength_min = 5
	tacklestrength_max = 5

	evolves_to = null
	deevolves_to = null
	evolution_allowed = FALSE
	can_vent_crawl = FALSE

	caste_desc = "An incendiary berserker."
	fire_immunity = FIRE_IMMUNITY_NO_DAMAGE|FIRE_IMMUNITY_XENO_FRENZY

	behavior_delegate_type = /datum/behavior_delegate/wyrm_base


	minimap_icon = "xenoqueen"

/mob/living/carbon/xenomorph/wyrm
	caste_type = XENO_CASTE_WYRM
	name = XENO_CASTE_WYRM
	desc = "An alien reeking of oil and sulfur, and periodically puffing smoke."
	icon_size = 64
	icon_state = "Wyrm Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	tier = 4
	pixel_x = -12
	old_x = -12
	claw_type = CLAW_TYPE_SHARP
	counts_for_slots = FALSE
	organ_value = 5000

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		//datum/action/xeno_action/activable/tail_stab/wyrm,
		//datum/action/xeno_action/onclick/ignition, // first macro
		//datum/action/xeno_action/activable/breath_fire, // second macro
		//datum/action/xeno_action/onclick/select_fire, // third macro
		/datum/action/xeno_action/onclick/tacmap,
	)

	icon_xeno = 'icons/mob/xenos/castes/tier_4/wyrm.dmi'
	icon_xenonid = 'icons/mob/xenonids/castes/tier_2/lurker.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Drone_1","Drone_2","Drone_3")
	weed_food_states_flipped = list("Drone_1","Drone_2","Drone_3")

	var/currently_onfire = FALSE // To ensure de/buffs don't stack
	var/onfire_speed = -0.6 // Speed gain when on fire
	var/onfire_attack = -2 // Slash speed when on fire

/mob/living/carbon/xenomorph/wyrm/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_LIVING_PREIGNITION, PROC_REF(onfire_buff_gain))

/mob/living/carbon/xenomorph/wyrm/Destroy()
	UnregisterSignal(src, COMSIG_LIVING_PREIGNITION)
	return ..()

/mob/living/carbon/xenomorph/wyrm/resist_fire()
	. = ..()
	SetKnockDown(0.1 SECONDS)

/mob/living/carbon/xenomorph/wyrm/ExtinguishMob()
	. = ..()
	onfire_buff_remove()

/mob/living/carbon/xenomorph/wyrm/proc/onfire_buff_gain()
	if(currently_onfire == FALSE)
		currently_onfire = TRUE
		speed_modifier += onfire_speed
		attack_speed_modifier += onfire_attack
		recalculate_everything()
		to_chat(src, "FIREBUFF ON")

/mob/living/carbon/xenomorph/wyrm/proc/onfire_buff_remove()
	if(currently_onfire == TRUE)
		currently_onfire = FALSE
		speed_modifier -= onfire_speed
		attack_speed_modifier -= onfire_attack
		recalculate_everything()
		to_chat(src, "FIREBUFF OFF")

/datum/behavior_delegate/wyrm_base
	name = "Base Wyrm Behavior Delegate"

