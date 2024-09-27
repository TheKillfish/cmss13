/datum/action/xeno_action/onclick/vanish
	name = "Vanish"
	action_icon_state = "lurker_invisibility"
	ability_name = "vanish"
	macro_path = /datum/action/xeno_action/verb/verb_vanish
	ability_primacy = XENO_PRIMARY_ACTION_1
	action_type = XENO_ACTION_CLICK
	cooldown = 1 SECONDS

	var/alpha_amount = 20

/datum/action/xeno_action/onclick/spy_dodge
	name = "Dodge"
	action_icon_state = "prae_dodge"
	ability_name = "dodge"
	macro_path = /datum/action/xeno_action/verb/verb_spy_dodge
	ability_primacy = XENO_PRIMARY_ACTION_2
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 10 SECONDS

	var/duration = 5 SECONDS

/datum/action/xeno_action/onclick/smokescreen
	name = "Smokescreen"
	action_icon_state = "acid_shroud"
	ability_name = "smokescreen"
	macro_path = /datum/action/xeno_action/verb/verb_smokescreen
	ability_primacy = XENO_PRIMARY_ACTION_3
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 15 SECONDS

	var/speed_buff = 0.3
	var/duration = 5 SECONDS
