// Warrior Fling
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	ability_name = "Fling"
	macro_path = /datum/action/xeno_action/verb/verb_fling
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 6 SECONDS

	// Configurables
	var/fling_distance = 4
	var/stun_power = 0.5
	var/weaken_power = 0.5
	var/slowdown = 2

// Warrior Lunge
/datum/action/xeno_action/activable/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	ability_name = "lunge"
	macro_path = /datum/action/xeno_action/verb/verb_lunge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 10 SECONDS

	// Configurables
	var/grab_range = 4
	var/click_miss_cooldown = 15
	var/twitch_message_cooldown = 0 //apparently this is necessary for a tiny code that makes the lunge message on cooldown not be spammable, doesn't need to be big so 5 will do.

/datum/action/xeno_action/activable/warrior_punch
	name = "Punch"
	action_icon_state = "punch"
	ability_name = "punch"
	macro_path = /datum/action/xeno_action/verb/verb_punch
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 4.5 SECONDS

	// Configurables
	var/base_damage = 25
	var/base_punch_damage_synth = 30
	var/base_punch_damage_pred = 25
	var/damage_variance = 5

// Mercenary Abilities
/datum/action/xeno_action/onclick/sharpen
	name = "Sharpen"
	action_icon_state = "punch"
	ability_name = "sharpen"
	macro_path = /datum/action/xeno_action/verb/verb_sharpen
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	cooldown = 4

	var/sharpen_amount = 5

/datum/action/xeno_action/activable/quickslash
	name = "Quick Slash"
	action_icon_state = "punch"
	ability_name = "quick slash"
	macro_path = /datum/action/xeno_action/verb/verb_quickslash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2

	var/qs_sharp_cooldown = 60		// Cooldown when the Merc has a sharp tail
	var/qs_blunt_cooldown = 120	// Cooldown when the Merc has a blunt tail

/datum/action/xeno_action/activable/forwardslash
	name = "Forward Slash"
	action_icon_state = "punch"
	ability_name = "forward slash"
	macro_path = /datum/action/xeno_action/verb/verb_forwardslash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3

	var/fs_sharp_cooldown = 6
	var/fs_blunt_cooldown = 12

/datum/action/xeno_action/activable/spinswipe
	name = "Spin Swipe"
	action_icon_state = "punch"
	ability_name = "spin swipe"
	macro_path = /datum/action/xeno_action/verb/verb_spinswipe
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4

	var/spsw_sharp_cooldown = 10
	var/spsw_blunt_cooldown = 20

/datum/action/xeno_action/activable/helmsplitter
	name = "Helmsplitter"
	action_icon_state = "punch"
	ability_name = "helmsplitter"
	macro_path = /datum/action/xeno_action/verb/verb_helmsplitter
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_5

	var/hs_sharp_cooldown = 20
	var/hs_blunt_cooldown = 30
