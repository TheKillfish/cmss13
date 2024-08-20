/datum/action/xeno_action/active_toggle/quadruped
	name = "Quadruped Movement"
	action_icon_state = "toggle_speed"
	ability_name = "quadruped_movement"
	macro_path = /datum/action/xeno_action/verb/verb_quadruped
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1

	action_start_message = "We drop to all fours, increasing our movement speed!"
	action_end_message = "We return to two-legged movement."

/datum/action/xeno_action/onclick/call_pack
	name = "Call Pack"
	action_icon_state = "screech"
	ability_name = "call_pack"
	macro_path = /datum/action/xeno_action/verb/verb_call_pack
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_
	xeno_cooldown = 30 SECONDS

/datum/action/xeno_action/activable/cannibalize
	name = "Cannibalize"
	action_icon_state = "gib"
	ability_name = "cannibalize"
	macro_path = /datum/action/xeno_action/verb/verb_cannibalize
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_
	xeno_cooldown = 5 SECONDS
