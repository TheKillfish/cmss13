// Just teleports you. Short ranged, short CD, meant to be spammed.
/datum/action/xeno_action/activable/spatial_lurch
	name = "Spatial Lurch"
	action_icon_state = "crest_defense"
	macro_path = /datum/action/xeno_action/verb/verb_spatial_lurch
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 3 SECONDS
	ability_primacy = XENO_PRIMARY_ACTION_1

	var/generated_instability = 6
	var/instability_doubling_time = 2 // Normally not an issue, becomes an issue if you use it during Time Carapace

	var/lurch_distance = 3
	var/lurch_los_limit = FALSE // For some tweakability

// Strong self-buff, think Temporal Shell system from Starsector.
/datum/action/xeno_action/onclick/time_carapace
	name = "Time Carapace"
	action_icon_state = "crest_defense"
	macro_path = /datum/action/xeno_action/verb/verb_time_carapace
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 10 SECONDS
	ability_primacy = XENO_PRIMARY_ACTION_2

	var/generated_instability = 15
	var/instability_doubling_time = 3 // Does not include base duration, that gets sorted out when the ability is used

	var/evasion_buff = 50
	var/health_regen_buff =
	var/speed_buff =
	var/slash_speed_buff =
	var/ability_cooldown_reduction =

/datum/action/xeno_action/activable/place_temporal_cocoon
	name = "Place Temporal Cocoon"
	action_icon_state = "crest_defense"
	macro_path = /datum/action/xeno_action/verb/verb_place_temporal_cocoon
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 40 SECONDS
	ability_primacy = XENO_PRIMARY_ACTION_3

/datum/action/xeno_action/onclick/temporal_return
	name = "Temporal Return"
	action_icon_state = "crest_defense"
	macro_path = /datum/action/xeno_action/verb/verb_temporal_return
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 60 SECONDS
	ability_primacy = XENO_PRIMARY_ACTION_4
