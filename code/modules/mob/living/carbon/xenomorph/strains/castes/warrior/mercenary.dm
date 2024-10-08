/datum/xeno_strain/mercenary
	name = WARRIOR_MERCENARY
	description = "Lose your punch, lunge, fling, tail stab, and passive healing in exchange for a new set of tail-based melee AOE abilities: Forward Slash, which deals moderate damage after a short windup and hits up to two tiles away from you; Spin Swipe, which deals moderate damage after a windup and hits everyone within 2 tiles of you; and Helmsplitter, which deals enormous damage to targets up to three tiles away with adjacent splash effects after a long windup. Your new abilities are influenced by the state your tail is in; Sharp or Blunt, starting with Sharp and degrading to Blunt as you use tail abilities. Sharp gives you the fastest cooldowns and armor penetration, while Blunt loses armor penetration and has double the cooldown time but gains knockback and dazing effects on hit. You can Sharpen your tail to refresh your tail's blunting progress."
	flavor_description = "Whether it cleaves or crushes, our foes shall fall to your tail so mighty."
	icon_state_prefix = "Mercenary"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
	)

	actions_to_add = list(
		/datum/action/xeno_action/onclick/sharpen,
		/datum/action/xeno_action/activable/forwardslash,
		/datum/action/xeno_action/onclick/spinswipe,
		/datum/action/xeno_action/activable/helmsplitter,
	)

	behavior_delegate_type = /datum/behavior_delegate/warrior_mercenary

/datum/xeno_strain/mercenary/apply_strain(mob/living/carbon/xenomorph/warrior/woyer)
	woyer.plasma_types = list(PLASMA_CHITIN)

/datum/behavior_delegate/warrior_mercenary
	name = "Warrior Mercenary Behaviour Delegate"

	var/sharp_hits = 6
	var/sharp_max = 12
	var/winding = FALSE

/datum/behavior_delegate/warrior_mercenary/proc/modify_sharpness(amount)
	sharp_hits += amount
	if(sharp_hits > sharp_max)
		sharp_hits = sharp_max
	if(sharp_hits < 0)
		sharp_hits = 0

/datum/behavior_delegate/warrior_mercenary/append_to_stat()
	. = list()
	. += "Tail sharpness: [sharp_hits]/[sharp_max]"
