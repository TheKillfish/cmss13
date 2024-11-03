/datum/xeno_strain/bouncer
	name = SENTINEL_BOUNCER
	description = "Sacrifice most of your base abilities for improved survivability and abilities oriented around punishing ."
	flavor_description = "Educate our enemies why intoxication on the battlefield is a poor idea."
	icon_state_prefix = "Bouncer"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/corrosive_acid/weak,
		/datum/action/xeno_action/activable/slowing_spit,
		/datum/action/xeno_action/activable/scattered_spit,
		/datum/action/xeno_action/onclick/paralyzing_slash,
	)
	actions_to_add = list(


	)

	behavior_delegate_type = /datum/behavior_delegate/sentinel_bouncer

/datum/xeno_strain/bouncer/apply_strain(mob/living/carbon/xenomorph/sentinel/sent)
	sent.armor_modifier += XENO_ARMOR_MOD_SMALL
	sent.recalculate_armor()

/datum/behavior_delegate/sentinel_councer
