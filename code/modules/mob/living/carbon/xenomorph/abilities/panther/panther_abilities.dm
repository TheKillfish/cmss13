/datum/action/xeno_action/activable/pounce/panther
	name = "Pounce"
	action_icon_state = "pounce"
	macro_path = /datum/action/xeno_action/verb/verb_pounce
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 6 SECONDS
	plasma_cost = 0

	// Config
	knockdown = TRUE
	knockdown_duration = 1.5 // Inbetween Runner and Lurker kinda
	slash = FALSE
	freeze_self = TRUE
	freeze_time = 10 // Inbetween Runner and Lurker
	can_be_shield_blocked = TRUE

	var/currently_empowered = FALSE
	var/adrenaline_empowering = 250
	var/slash_speed_buff = 4 // Equal to Runner's normal attacking speed

/datum/action/xeno_action/activable/blood_maul
	name = "Blood Maul"
	action_icon_state = "headbite"
	macro_path = /datum/action/xeno_action/verb/verb_blood_maul
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 8 SECONDS

	// Config
	var/adrenaline_empowering = 150
	var/number_of_wounds = 3
	var/daze_duration = 2 // Seconds

/datum/action/xeno_action/onclick/tailspin
	name = "Tail Spin"
	action_icon_state = "screech"
	macro_path = /datum/action/xeno_action/verb/verb_tailspin
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 10 SECONDS

	// Config
	var/adrenaline_empowering = 100

/datum/action/xeno_action/onclick/adrenaline_evasion
	name = "Toggle Evasion"
	action_icon_state = "prae_dodge"
	macro_path = /datum/action/xeno_action/verb/verb_adrenaline_evasion
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4
	xeno_cooldown = 1.5 SECONDS

	// Config
	var/evasion_buff = 15 // Same as Drone
	var/threshold_buff = 6 // Same as Dancer

/datum/action/xeno_action/onclick/tailspin_chemical
	name = "Choose Toxin"
	//action_icon_state = ""
	macro_path = /datum/action/xeno_action/verb/verb_tailspin_chemical
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_5
	xeno_cooldown = 1 SECONDS
