/datum/caste_datum/hamask
	caste_type = XENO_CASTE_HAMASK

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_4
	melee_vehicle_damage = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_8
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_PLASMA_TIER_2
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_1
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7

	evolves_to = null
	deevolves_to = null
	evolution_allowed = FALSE
	can_vent_crawl = FALSE

	tackle_min = 3
	tackle_max = 6
	tacklestrength_min = 6
	tacklestrength_max = 10

	is_intelligent = TRUE
	tier = 4
	can_be_queen_healed = FALSE

	behavior_delegate_type = /datum/behavior_delegate/hamask_base

	minimap_icon = "predalien"

/mob/living/carbon/xenomorph/hamask
	caste_type = XENO_CASTE_HAMASK
	desc = "A strong-looking alien with strange protusions on its head."
	icon = 'icons/mob/xenos/predalien.dmi'
	icon_xeno = 'icons/mob/xenos/predalien.dmi'
	icon_xenonid = 'icons/mob/xenos/predalien.dmi'
	icon_state = "Predalien Walking"
	speaking_noise = 'sound/voice/predalien_click.ogg'
	plasma_types = list(PLASMA_CATECHOLAMINE)
	claw_type = CLAW_TYPE_VERY_SHARP
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = 4
	counts_for_slots = FALSE
	organ_value = 20000
	age = XENO_NO_AGE
	show_age_prefix = FALSE

	var/kill_tally = 0

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/onclick/battlefrenzy,
		/datum/action/xeno_action/onclick/rebound,
		/datum/action/xeno_action/activable/brutalassault,
		/datum/action/xeno_action/onclick/tacmap,
	)

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Predalien_1","Predalien_2","Predalien_3")
	weed_food_states_flipped = list("Predalien_1","Predalien_2","Predalien_3")

/mob/living/carbon/xenomorph/hamask/Initialize(mapload, mob/living/carbon/xenomorph/oldxeno, h_number)
	. = ..()
	AddComponent(/datum/component/footstep, 4, 25, 11, 2, "alien_footstep_medium")

/mob/living/carbon/xenomorph/hamask/gib(datum/cause_data/cause = create_cause_data("gibbing", src))
	death(cause, gibbed = TRUE)

/mob/living/carbon/xenomorph/hamask/get_organ_icon()
	return "heart_t3"

/mob/living/carbon/xenomorph/hamask/resist_fire()
	..()
	SetKnockDown(0.1 SECONDS)

/mob/living/carbon/xenomorph/hamask/get_examine_text(mob/user)
	. = ..()
	. += "It has [kill_tally] kills to its name!"

/datum/behavior_delegate/hamask_base
	name = "Base Predalien Behavior Delegate"

	var/plasma_on_slash = 5
	var/plasma_on_kills = 50

/datum/behavior_delegate/hamask_base/append_to_stat()
	. = list()
	var/mob/living/carbon/xenomorph/hamask/tally = bound_xeno
	. += "Kills: [tally.kill_tally]"

/datum/behavior_delegate/hamask_base/on_kill_mob(mob/M)
	. = ..()
	var/mob/living/carbon/xenomorph/hamask/tally = bound_xeno
	tally.gain_plasma(plasma_on_kills)
	tally.kill_tally += 1

/datum/behavior_delegate/hamask_base/melee_attack_additional_effects_self(mob/M)
	. = ..()
	var/mob/living/carbon/xenomorph/hamask/tally = bound_xeno
	tally.gain_plasma(plasma_on_kills)
