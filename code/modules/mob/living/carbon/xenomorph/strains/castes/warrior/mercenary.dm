/datum/xeno_strain/mercenary
	name = WARRIOR_MERCENARY
	description = "Lose your punch, lunge, fling, tail stab, passive healing and some health in exchange for a new set of strong tail-based abilities: Quick Slash which deals lower damage and can only hit adjacent targets but has no windup; Forward Slash, which deals moderate damage after a short windup and hits up to two tiles away from you; Spin Swipe, which deals moderate damage after a windup and hits everyone adjacent to you; and Helmsplitter, which deals enormous damage to targets up to three tiles away after a long windup. Your new abilities are influenced by the state your tail is in; Sharp or Blunt, starting with Sharp and degrading to Blunt as you use tail abilities. Sharp gives you the fastest cooldowns and armor penetration, while Blunt increases cooldowns and loses armor penetration but instead gains knockback/knockdown and dazing effects on hit. You can Sharpen your tail to refresh your tail's blunting progress."
	flavor_description = "Whether by cleaving or crushing, our foes shall fall to your tail so mighty."
	icon_state_prefix = "Mercenary"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
	)

	actions_to_add = list(
		/datum/action/xeno_action/onclick/sharpen,
		/datum/action/xeno_action/activable/quickslash,
		/datum/action/xeno_action/activable/forwardslash,
		/datum/action/xeno_action/activable/spinswipe,
		/datum/action/xeno_action/activable/helmsplitter,
	)

	behavior_delegate_type = /datum/behavior_delegate/warrior_mercenary

/datum/xeno_strain/mercenary/apply_strain(mob/living/carbon/xenomorph/warrior/woyer)
	woyer.health_modifier -= XENO_HEALTH_MOD_SMALL
	woyer.plasma_types = list(PLASMA_CHITIN)

	woyer.recalculate_everything()

/datum/behavior_delegate/warrior_mercenary
	name = "Warrior Mercenary Behaviour Delegate"

	var/sharp_hits = 5
	var/sharp_max = 10

/datum/behavior_delegate/warrior_mercenary/proc/modify_sharpness(amount)
	sharp_hits += amount
	if(sharp_hits > sharp_max)
		sharp_hits = sharp_max
	if(sharp_hits < 0)
		sharp_hits = 0

/datum/behavior_delegate/warrior_mercenary/append_to_stat()
	. = list()
	. += "Tail sharpness: [sharp_hits]/[sharp_max]"
