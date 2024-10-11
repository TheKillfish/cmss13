/datum/xeno_strain/crone
	name = QUEEN_CRONE
	description = ""
	flavor_description = "With this gift, the Queen Mother inducts me into her Coven. May I not disappoint her."
	icon_state_prefix = "Crone"

	actions_to_remove = list(

	)
	actions_to_add = list(

	)

	behavior_delegate_type = /datum/behavior_delegate/queen_crone

/datum/xeno_strain/dancer/apply_strain(mob/living/carbon/xenomorph/queen/queen)


/datum/behavior_delegate/queen_crone
	name = "Queen Crone Behavior Delegate"
