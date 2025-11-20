/datum/xeno_strain/conscript
	name = DRONE_CONSCRIPT
	description = "Lose your ability to emit pheremones, build normal structures, half your plasma and a bit of speed to gain a bit of armor and slash damage. \
	"
	flavor_description = "In war, all must serve their time. To fight, unrelenting."
	icon_state_prefix = "Conscript"

	actions_to_remove = list(
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/onclick/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
	)
	actions_to_add = list(

	)

	behavior_delegate_type = /datum/behavior_delegate/drone_conscript

/datum/xeno_strain/conscript/apply_strain(mob/living/carbon/xenomorph/drone/drone)
	drone.plasmapool_modifier = 0.5 // 50% hit to your plasma
	drone.damage_modifier += XENO_DAMAGE_MOD_VERY_SMALL
	drone.armor_modifier += XENO_ARMOR_MOD_MED
	drone.speed_modifier += XENO_SPEED_SLOWMOD_TIER_4

	drone.recalculate_everything()

/datum/behavior_delegate/drone_conscript
	name = "Drone Conscript Behavior Delegate"
