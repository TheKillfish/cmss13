/datum/action/xeno_action/activable/radio_tap
	name = "Radio Tap"
	action_icon_state = "project_xeno"
	macro_path = /datum/action/xeno_action/verb/verb_radio_tap
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 2 MINUTES
	plasma_cost = 100
	// Config
	var/plasma_drain = 10
	var/duration = 3 MINUTES

/datum/action/xeno_action/onclick/mimicry
	name = "Mimicry"
	action_icon_state = "xenohide"
	//macro_path = /datum/action/xeno_action/verb/verb_mimicry
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 20 SECONDS
	plasma_cost = 80

/datum/action/xeno_action/onclick/white_noise
	name = "White Noise"
	action_icon_state = "xeno_deevolve"
	//macro_path = /datum/action/xeno_action/verb/verb_white_noise
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 30 SECONDS
	plasma_cost = 80

/datum/action/xeno_action/onclick/signal_spoofing
	name = "Radio Tap"
	action_icon_state = "xeno_deevolve"
	//macro_path = /datum/action/xeno_action/verb/verb_signal_spoof
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4
	xeno_cooldown = 20 SECONDS
	plasma_cost = 80
