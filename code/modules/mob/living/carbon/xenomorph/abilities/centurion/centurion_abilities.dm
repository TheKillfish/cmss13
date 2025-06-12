/datum/action/xeno_action/onclick/neurotoxic_slash
	name = "Neurotoxic Slash"
	action_icon_state = "lurker_inject_neuro"
	macro_path = /datum/action/xeno_action/verb/verb_neurotoxic_slash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 8 SECONDS
	plasma_cost = 50

	var/buff_duration = 5 SECONDS

/datum/action/xeno_action/activable/bounding_slash
	name = "Bounding Slash"
	action_icon_state = "prae_dash"
	macro_path = /datum/action/xeno_action/verb/verb_bounding_slash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 10 SECONDS
	plasma_cost = 50

	var/max_range = 4
	var/shield_on_slash = 20
	var/shield_cap = 60

/datum/action/xeno_action/onclick/rallying_roar
	name = "Rallying Roar"
	action_icon_state = "screech"
	macro_path = /datum/action/xeno_action/verb/verb_rallying_roar
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4
	xeno_cooldown = 25 SECONDS
	plasma_cost = 200

	var/buff_range = 2
	var/buff_durations = 7.5 SECONDS
	var/speed_buff = 0.4
	var/slash_buff = 5
