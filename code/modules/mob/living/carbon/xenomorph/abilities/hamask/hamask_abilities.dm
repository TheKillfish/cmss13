/datum/action/xeno_action/onclick/battlefrenzy
	name = "Battle Frenzy"
	action_icon_state = "rav_enrage"
	ability_name = "battle frenzy"
	macro_path = /datum/action/xeno_action/verb/verb_battle_frenzy
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 5 SECONDS
	plasma_cost = 50
	ability_primacy = XENO_PRIMARY_ACTION_1

	var/plasma_drain = 15
	var/move_boost = 0.3
	var/attack_boost = 1.5

/datum/action/xeno_action/onclick/rebound
	name = "Rebound"
	action_icon_state = "warden_heal"
	ability_name = "rebound"
	macro_path = /datum/action/xeno_action/verb/verb_rebound
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 30 SECONDS
	plasma_cost = 100
	ability_primacy = XENO_PRIMARY_ACTION_2

	var/heal_amount = 150

/datum/action/xeno_action/activable/brutalassault
	name = "Brutal Assault"
	action_icon_state = "rav_eviscerate"
	ability_name = "brutal assault"
	macro_path = /datum/action/xeno_action/verb/verb_brutalassault
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 10 SECONDS
	plasma_cost = 0
	ability_primacy = XENO_PRIMARY_ACTION_3
