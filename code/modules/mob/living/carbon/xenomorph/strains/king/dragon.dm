/datum/xeno_strain/dragon
	name = KING_DRAGON
	description = "."
	flavor_description = "Here be there dragons."

	actions_to_remove = list(

	)
	actions_to_add = list(

	)

	behavior_delegate_type = /datum/behavior_delegate/king_dragon

/datum/xeno_strain/king_dragon/apply_strain(mob/living/carbon/xenomorph/king/king)
	if(!istype(king))
		return FALSE

	king.recalculate_everything()

/datum/behavior_delegate/king_dragon
	name = "King Dragon Behavior Delegate"
