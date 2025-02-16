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

// Powers

/datum/action/xeno_action/activable/wrecking_tail/use_ability(atom/targetted_atom)
	var/mob/living/carbon/xenomorph/demolisher = owner
	if(!demolisher.check_state())
		return

	if(!action_cooldown_check())
		return

	if(!demolisher.Adjacent(targetted_atom))
		return

	var/turf/closed/wall/target_wall = targetted_atom
	if(istype(targetted_atom, /turf/closed/wall) && !(target_wall.turf_flags & TURF_HULL))
		if(target_wall.claws_minimum == CLAW_TYPE_SHARP)
			if(!do_after(demolisher, wrecking_delay, INTERRUPT_ALL | BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
				return
			playsound(target_wall, 'sound/effects/metalhit.ogg', 50, TRUE)
			target_wall.take_damage(wrecking_wall_damage)
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] violently smashes \the [targetted_atom] with their tail!"), SPAN_XENOWARNING("We smash \the [targetted_atom] with our tail!"))

		if(target_wall.acided_hole)
			target_wall.acided_hole.expand_hole(demolisher)
			return
		var/obj/effect/acid_hole/target_acid_hole = targetted_atom
		if(istype(targetted_atom, /obj/effect/acid_hole))
			target_acid_hole.expand_hole(demolisher)
			return
		apply_cooldown()

	var/mob/living/target_carbon = targetted_atom
	if(isxeno_human(targetted_atom))
		if(demolisher.can_not_harm(target_carbon))
			return
		// Smack the target to the ground. Larger targets just get stunned
		if(target_carbon.mob_size < MOB_SIZE_BIG)
			target_carbon.KnockDown(2)
		else
			target_carbon.Slow(3)
		playsound(target, "punch", 50, TRUE)
		shake_camera(target_carbon)
		demolisher.visible_message(SPAN_XENOWARNING("[demolisher] violently clobbers [targetted_atom] with their tail!"), SPAN_XENOWARNING("We clobber [targetted_atom] with our tail!"))
		apply_cooldown()

	var/obj/structure/target_structure = targetted_atom
	if(istype(targetted_atom, /obj/structure) && !target_structure.unslashable)
		// Tables don't stand a chance against the weighty tail of Demolisher
		var/obj/structure/surface/table/target_table
		if(istype(target_structure, /obj/structure/surface/table))
			playsound(get_turf(target_table), 'sound/effects/metalhit.ogg', 30, TRUE)
			target_table.deconstruct()
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] smashes \the [targetted_atom] apart with their tail!"), SPAN_XENOWARNING("We smash \the [targetted_atom] apart with our tail!"))
			apply_cooldown(0.3)

		// Demolisher shatters breakable windows with ease
		var/obj/structure/window/framed/target_window = target_structure
		if(istype(target_structure, /obj/structure/window/framed))
			playsound(get_turf(target_window), "windowshatter", 30, TRUE)
			target_window.shatter_window(TRUE)
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] effortlessly shatters \the [targetted_atom] with their tail!"), SPAN_XENOWARNING("We shatter \the [targetted_atom] with our tail!"))
			apply_cooldown(0.3)

		// Window frames similarly cannot endure the smashing of Demolisher's tail
		var/obj/structure/window_frame/target_frame = target_structure
		if(istype(target_structure, /obj/structure/window_frame))
			playsound(get_turf(target_window), 'sound/effects/metalhit.ogg', 30, TRUE)
			target_frame.deconstruct()
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] crushes \the [targetted_atom] with their tail!"), SPAN_XENOWARNING("We crush \the [targetted_atom] with our tail!"))
			apply_cooldown(0.3)

		// Doors will take a bit more to break but will go faster than from slashing
		var/obj/structure/machinery/door/airlock/target_airlock = target_structure
		if(istype(target_structure, /obj/structure/machinery/door/airlock))
			if(target_airlock.isElectrified() && target_airlock.arePowerSystemsOn())
				var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
				sparks.set_up(5, 1, target_airlock)
				sparks.start()
				to_chat(demolisher, SPAN_WARNING("We feel a sting from our tail!"))
				demolisher.apply_damage(5, BURN)

			playsound(target_airlock, 'sound/effects/metalhit.ogg', 50, TRUE)
			target_airlock.take_damage(target_airlock.damage_cap / 4, demolisher)
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] violently bashes \the [targetted_atom] with their tail!"), SPAN_XENOWARNING("We bash \the [targetted_atom] with our tail!"))
			apply_cooldown(0.6)

		// Normal cades will still take a bit of a beating to break, but wood or snow ones will be instantly broken
		var/obj/structure/barricade/target_cade = target_structure
		if(istype(target_structure, /obj/structure/barricade))
			if(target_cade.is_wired)
				to_chat(demolisher, SPAN_WARNING("We feel something cut into our rail"))
				demolisher.apply_damage(5, BRUTE)

			playsound(target_cade, target_cade.barricade_hitsound, 50, TRUE)
			if(istype(target_cade, /obj/structure/barricade/wooden || /obj/structure/barricade/snow))
				target_cade.update_health(target_cade.maxhealth + 10) // Extra 10 damage is for posterity in ensuring the cade is destroyed
			else
				target_cade.take_damage(target_cade.maxhealth / 6)
			demolisher.visible_message(SPAN_XENOWARNING("[demolisher] violently strikes \the [targetted_atom] with their tail!"), SPAN_XENOWARNING("We strike \the [targetted_atom] with our tail!"))
			apply_cooldown(0.8)

	var/last_dir = demolisher.dir
	var/swing_direction

	// Animation code taken from tail stab pretty much verbatim
	swing_direction = turn(demolisher.dir, pick(90, -90))
	demolisher.animation_attack_on(target)
	demolisher.flick_attack_overlay(target, "slam")

	if(last_dir != swing_direction)
		demolisher.setDir(swing_direction)
		demolisher.emote("tail")
		var/new_dir = demolisher.dir
		addtimer(CALLBACK(src, PROC_REF(reset_direction), demolisher, last_dir, new_dir), 0.5 SECONDS)
	return ..()

/datum/action/xeno_action/activable/wrecking_tail/proc/reset_direction(mob/living/carbon/xenomorph/demolisher, last_dir, new_dir)
	if(new_dir == demolisher.dir)
		demolisher.setDir(last_dir)
