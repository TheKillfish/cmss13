/datum/caste_datum/bulldozer
	caste_type = XENO_CASTE_BULLDOZER
	caste_desc = "The hive's living siege weapon."
	tier = 4

	melee_damage_lower = XENO_DAMAGE_TIER_6
	melee_damage_upper = XENO_DAMAGE_TIER_6
	melee_vehicle_damage = XENO_DAMAGE_TIER_9
	max_health = XENO_HEALTH_QUEEN
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_1

	evolves_to = null
	deevolves_to = null
	evolution_allowed = FALSE
	can_be_revived = FALSE
	attack_delay = 2

	behavior_delegate_type = /datum/behavior_delegate/bulldozer_base

	tackle_min = 6
	tackle_max = 10
	tackle_chance = 30
	tacklestrength_min = 4
	tacklestrength_max = 5

	minimum_evolve_time = 30 MINUTES
	minimap_icon = "warrior"

	royal_caste = TRUE

/mob/living/carbon/xenomorph/bulldozer
	caste_type = XENO_CASTE_BULLDOZER
	name = XENO_CASTE_WARRIOR
	desc = "A tower of chitin and raw strength. A living siege weapon."
	icon = 'icons/mob/xenos/bulldozer.dmi'
	icon_size = 64
	icon_state = "Bulldozer Walking"
	plasma_types = list(PLASMA_CHITIN)
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_IMMOBILE
	drag_delay = 6
	pull_speed = 3
	tier = 4
	small_explosives_stun = FALSE
	organ_value = 10000
	counts_for_slots = FALSE
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/bulldozer,
		/datum/action/xeno_action/onclick/tacmap,
	)

	claw_type = CLAW_TYPE_BULLDOZER

	icon_xeno = 'icons/mob/xenos/bulldozer.dmi'
	icon_xenonid = 'icons/mob/xenonids/queen.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Warrior_1","Warrior_2","Warrior_3")
	weed_food_states_flipped = list("Warrior_1","Warrior_2","Warrior_3")

/mob/living/carbon/xenomorph/bulldozer/get_organ_icon()
	return "heart_t3"

/mob/living/carbon/xenomorph/bulldozer/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	return ..()

/mob/living/carbon/xenomorph/bulldozer/Initialize()
	. = ..()
	AddComponent(/datum/component/footstep, 2 , 35, 11, 4, "alien_footstep_large")
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_block))

/mob/living/carbon/xenomorph/bulldozer/proc/check_block(mob/bulldozer, turf/new_loc)
	SIGNAL_HANDLER
	for(var/mob/living/carbon/carbon in new_loc.contents)
		if((carbon.stat != DEAD) && (carbon.mob_size < MOB_SIZE_IMMOBILE))
			if(isxeno(carbon))
				var/mob/living/carbon/xenomorph/xeno = carbon
				if(xeno.hivenumber == hivenumber)
					xeno.KnockDown((5 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
				else
					xeno.KnockDown((20 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
			else
				carbon.KnockDown((20 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
		playsound(src, 'sound/weapons/alien_knockdown.ogg', 25, 1)

/datum/behavior_delegate/bulldozer_base
	name = "Base Bulldozer Behavior Delegate"
