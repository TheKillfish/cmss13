/datum/xeno_strain/demolisher
	name = WARRIOR_DEMOLISHER
	description = ""
	flavor_description = ""
	//icon_state_prefix = "Demolisher"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/wrecking_tail,
		/datum/action/xeno_action/activable/corrosive_slime,
		/datum/action/xeno_action/activable/demolisher_hook_punch,
		/datum/action/xeno_action/activable/demolisher_lunge_punch,
	)

	behavior_delegate_type = /datum/behavior_delegate/warrior_demolisher

/datum/xeno_strain/demolisher/apply_strain(mob/living/carbon/xenomorph/warrior/warrior)
	warrior.speed_modifier += XENO_SPEED_SLOWMOD_TIER_3
	warrior.damage_modifier -= XENO_DAMAGE_MOD_SMALL
	warrior.claw_type = CLAW_TYPE_NORMAL

	warrior.recalculate_everything()

/datum/behavior_delegate/warrior_demolisher
	name = "Warrior Demolisher Behavior Delegate"

	// Acid Charges vars
	/// How many charges of acid do you have?
	var/acid_charges = 0
	/// What is the maximum number of charges you can have?
	var/acid_charges_max = 6

	// Acid Buildup vars
	/// Current timer for charge generation
	var/acid_building_up = 0 // Given ticks, this will take approx. 10 seconds to fill
	/// How long does it take for one charge to generate?
	var/acid_building_up_time = 10
	/// How much time is shaved off from buildup time when it gets reduced?
	var/acid_building_up_boost = 2

	// Drenched vars
	/// How many hits do you have when your fists are drenched in acid?
	var/drenched_hits = 0
	/// What is the maximum number of drenched hits you can have?
	var/drenched_hits_max = 10
	/// How long do your fists remain drenched?
	var/drenched_hits_duration = 2 MINUTES
	/// Timer for how long your fists remain drenched
	var/drenched_hits_timer_id = TIMER_ID_NULL

/datum/behavior_delegate/warrior_demolisher/proc/modify_charges(amount = 1)
	acid_charges += amount
	if(acid_charges > acid_charges_max)
		acid_charges = acid_charges_max
	if(acid_charges < 0)
		acid_charges = 0

/datum/behavior_delegate/warrior_demolisher/proc/modify_drenched_hits(amount = 1)
	drenched_hits += amount
	if(drenched_hits > drenched_hits_max)
		drenched_hits = drenched_hits_max
	if(drenched_hits < 0)
		drenched_hits = 0

	if(drenched_hits == 0)
		drenched_fists_expire()

/datum/behavior_delegate/warrior_demolisher/proc/fists_drenched(time = drenched_hits_duration)
	bound_xeno.visible_message(SPAN_XENOWARNING("[bound_xeno] belches a caustic slime onto its fists, coating them!"), SPAN_XENOWARNING("We coat our fists in acidic slime!"))
	modify_drenched_hits(drenched_hits_max)
	drenched_hits_timer_id = addtimer(CALLBACK(src, PROC_REF(drenched_fists_expire)), time, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/behavior_delegate/warrior_demolisher/proc/drenched_fists_expire()
	if(drenched_hits_timer_id != TIMER_ID_NULL)
		deltimer(drenched_hits_timer_id)
		drenched_hits_timer_id = TIMER_ID_NULL

	bound_xeno.visible_message(SPAN_XENOWARNING("The caustic slime on [bound_xeno]'s fists dries and quickly flakes off!"), SPAN_XENOWARNING("The acidic slime on our fists has dried up!"))
	drenched_hits = 0

/datum/behavior_delegate/warrior_demolisher/on_life()
	if(acid_building_up >= acid_building_up_time)
		modify_charges()
		acid_building_up = 0
	else
		acid_building_up += 2

	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()
	var/percentage_charges = round((acid_charges / acid_charges_max) * 100, 10)
	if(percentage_charges)
		holder.overlays += image('icons/mob/hud/hud.dmi', "xenoenergy[percentage_charges]")

/datum/behavior_delegate/warrior_demolisher/append_to_stat()
	. = list()
	. += "TEST [acid_building_up]"
	. += "Acid Charges: [acid_charges]/[acid_charges_max]"
	if(drenched_hits != 0)
		. += "Drenched Hits: [drenched_hits]"
		. += "Time Left: [time2text(timeleft(drenched_hits_timer_id), "mm:ss")] remaining"

/datum/behavior_delegate/warrior_demolisher/melee_attack_additional_effects_target(atom/target)
	if(isxeno_human(target))
		if(ishuman(target))
			var/mob/living/carbon/human/target_human = target
			if(target_human.buckled && istype(target_human.buckled, /obj/structure/bed/nest))
				return
			if(target_human.stat == DEAD)
				return
		acid_building_up += 1

	if(drenched_hits != 0)
		for(var/datum/effects/acid/acid_effect in target.effects_list)
			qdel(acid_effect)
			break
		new /datum/effects/acid(target, bound_xeno, initial(bound_xeno.caste_type))
