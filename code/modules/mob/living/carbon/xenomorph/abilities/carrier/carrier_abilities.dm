/datum/action/xeno_action/activable/throw_hugger
	name = "Use/Throw Facehugger"
	action_icon_state = "throw_hugger"
	macro_path = /datum/action/xeno_action/verb/verb_throw_facehugger
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3

/datum/action/xeno_action/activable/throw_hugger/action_cooldown_check()
	if(owner)
		var/mob/living/carbon/xenomorph/carrier/X = owner
		return !X.threw_a_hugger
	return TRUE //When we first add the ability we still do this check, but owner is null, so a workaround

/datum/action/xeno_action/activable/retrieve_egg
	name = "Retrieve Egg"
	action_icon_state = "retrieve_egg"
	macro_path = /datum/action/xeno_action/verb/verb_retrieve_egg
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4

/datum/action/xeno_action/activable/retrieve_egg/not_primary
	ability_primacy = XENO_NOT_PRIMARY_ACTION

/datum/action/xeno_action/onclick/set_hugger_reserve
	name = "Set Hugger Reserve"
	action_icon_state = "xeno_banish"

// Occult Strain

/datum/action/xeno_action/onclick/bloodletting
	name = "Bloodletting"
	action_icon_state = "rav_eviscerate"
	// macro_path = /datum/action/xeno_action/verb/verb_bloodletting
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 1.5 SECONDS // To prevent spam

	var/health_cost = 50
	var/plasma_recovery = 75

/datum/action/xeno_action/onclick/select_ritual
	name = "Select Ritual"
	action_icon_state = "queen_order"
	// macro_path = /datum/action/xeno_action/verb/verb_select_ritual
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3

/datum/action/xeno_action/onclick/initiate_ritual
	name = "Initiate Ritual"
	action_icon_state = "regurgitate"
	// macro_path = /datum/action/xeno_action/verb/verb_initiate_ritual
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4
	plasma_cost = 500
	xeno_cooldown = 30 SECONDS
