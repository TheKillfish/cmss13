/datum/action/xeno_action/activable/lunge/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!action_cooldown_check())
		if(twitch_message_cooldown < world.time )
			xeno.visible_message(SPAN_XENOWARNING("[xeno]'s claws twitch."), SPAN_XENOWARNING("Our claws twitch as we try to lunge but lack the strength. Wait a moment to try again."))
			twitch_message_cooldown = world.time + 5 SECONDS
		return //this gives a little feedback on why your lunge didn't hit other than the lunge button going grey. Plus, it might spook marines that almost got lunged if they know why the message appeared, and extra spookiness is always good.

	if (!affected_atom)
		return

	if (!isturf(xeno.loc))
		to_chat(xeno, SPAN_XENOWARNING("We can't lunge from here!"))
		return

	if (!xeno.check_state() || xeno.agility)
		return

	if(xeno.can_not_harm(affected_atom) || !ismob(affected_atom))
		apply_cooldown_override(click_miss_cooldown)
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if (!check_and_use_plasma_owner())
		return

	apply_cooldown()
	..()

	xeno.visible_message(SPAN_XENOWARNING("[xeno] lunges towards [carbon]!"), SPAN_XENOWARNING("We lunge at [carbon]!"))

	xeno.throw_atom(get_step_towards(affected_atom, xeno), grab_range, SPEED_FAST, xeno)

	if (xeno.Adjacent(carbon))
		xeno.start_pulling(carbon,1)
		if(ishuman(carbon))
			INVOKE_ASYNC(carbon, TYPE_PROC_REF(/mob, emote), "scream")
	else
		xeno.visible_message(SPAN_XENOWARNING("[xeno]'s claws twitch."), SPAN_XENOWARNING("Our claws twitch as we lunge but are unable to grab onto our target. Wait a moment to try again."))

	return TRUE

/datum/action/xeno_action/activable/fling/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || xeno.can_not_harm(affected_atom))
		return

	if (!xeno.check_state() || xeno.agility)
		return

	if (!xeno.Adjacent(affected_atom))
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	if(carbon == xeno.pulling)
		xeno.stop_pulling()

	if(carbon.mob_size >= MOB_SIZE_BIG)
		to_chat(xeno, SPAN_XENOWARNING("[carbon] is too big for us to fling!"))
		return

	if (!check_and_use_plasma_owner())
		return

	xeno.visible_message(SPAN_XENOWARNING("[xeno] effortlessly flings [carbon] to the side!"), SPAN_XENOWARNING("We effortlessly fling [carbon] to the side!"))
	playsound(carbon,'sound/weapons/alien_claw_block.ogg', 75, 1)
	if(stun_power)
		carbon.Stun(get_xeno_stun_duration(carbon, stun_power))
	if(weaken_power)
		carbon.KnockDown(get_xeno_stun_duration(carbon, weaken_power))
	if(slowdown)
		if(carbon.slowed < slowdown)
			carbon.apply_effect(slowdown, SLOW)
	carbon.last_damage_data = create_cause_data(initial(xeno.caste_type), xeno)

	var/facing = get_dir(xeno, carbon)

	// Hmm today I will kill a marine while looking away from them
	xeno.face_atom(carbon)
	xeno.animation_attack_on(carbon)
	xeno.flick_attack_overlay(carbon, "disarm")
	xeno.throw_carbon(carbon, facing, fling_distance, SPEED_VERY_FAST, shake_camera = TRUE, immobilize = TRUE)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/warrior_punch/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!action_cooldown_check())
		return

	if (!isxeno_human(affected_atom) || xeno.can_not_harm(affected_atom))
		return

	if (!xeno.check_state() || xeno.agility)
		return

	var/distance = get_dist(xeno, affected_atom)

	if (distance > 2)
		return

	var/mob/living/carbon/carbon = affected_atom

	if (!xeno.Adjacent(carbon))
		return

	if(carbon.stat == DEAD)
		return
	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	var/obj/limb/target_limb = carbon.get_limb(check_zone(xeno.zone_selected))

	if (ishuman(carbon) && (!target_limb || (target_limb.status & LIMB_DESTROYED)))
		target_limb = carbon.get_limb("chest")

	if (!check_and_use_plasma_owner())
		return

	carbon.last_damage_data = create_cause_data(initial(xeno.caste_type), xeno)

	xeno.visible_message(SPAN_XENOWARNING("[xeno] hits [carbon] in the [target_limb ? target_limb.display_name : "chest"] with a devastatingly powerful punch!"), \
	SPAN_XENOWARNING("We hit [carbon] in the [target_limb ? target_limb.display_name : "chest"] with a devastatingly powerful punch!"))
	var/sound = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(carbon, sound, 50, 1)
	do_base_warrior_punch(carbon, target_limb)
	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/warrior_punch/proc/do_base_warrior_punch(mob/living/carbon/carbon, obj/limb/target_limb)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/damage = rand(base_damage, base_damage + damage_variance)

	if(ishuman(carbon))
		if((target_limb.status & LIMB_SPLINTED) && !(target_limb.status & LIMB_SPLINTED_INDESTRUCTIBLE)) //If they have it splinted, the splint won't hold.
			target_limb.status &= ~LIMB_SPLINTED
			playsound(get_turf(carbon), 'sound/items/splintbreaks.ogg', 20)
			to_chat(carbon, SPAN_DANGER("The splint on your [target_limb.display_name] comes apart!"))
			carbon.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)

		if(ishuman_strict(carbon))
			carbon.apply_effect(3, SLOW)

		if(isyautja(carbon))
			damage = rand(base_punch_damage_pred, base_punch_damage_pred + damage_variance)
		else if(target_limb.status & (LIMB_ROBOT|LIMB_SYNTHSKIN))
			damage = rand(base_punch_damage_synth, base_punch_damage_synth + damage_variance)


	carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE, target_limb ? target_limb.name : "chest")

	// Hmm today I will kill a marine while looking away from them
	xeno.face_atom(carbon)
	xeno.animation_attack_on(carbon)
	xeno.flick_attack_overlay(carbon, "punch")
	shake_camera(carbon, 2, 1)
	step_away(carbon, xeno, 2)

// Mercenary Abilities
/datum/action/xeno_action/onclick/sharpen/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner

	if(!istype(xeno))
		return

	if(!action_cooldown_check())
		return

	if(!xeno.check_state())
		return

	var/datum/behavior_delegate/warrior_mercenary/behavior_del = xeno.behavior_delegate
	if(!istype(behavior_del))
		return

	xeno.visible_message(SPAN_XENOWARNING("[xeno] swings it's tail and bites it!"), SPAN_XENONOTICE("We grab our tail in preparation to sharpen it's edge."))
	if(!do_after(xeno, 2 SECONDS, INTERRUPT_ALL | BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
		return

	xeno.visible_message(SPAN_XENOWARNING("[xeno] pulls it's tail through it's clenched jaws, sharpening it!"), SPAN_XENOHIGHDANGER("We pull our tail through our mouth and grind resin off the edge of our tail, sharpening it!"))
	behavior_del.sharp_hits += 3
	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/quickslash/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/damage = (xeno.melee_damage_lower)

	if(!action_cooldown_check())
		return

	if(!isxeno_human(target) || xeno.can_not_harm(target))
		return

	var/distance = get_dist(xeno, target)
	if(distance > 2)
		return

	var/mob/living/carbon/carbon = target
	if(!xeno.Adjacent(carbon))
		return

	if(carbon.stat == DEAD)
		return
	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	var/datum/behavior_delegate/warrior_mercenary/behavior_del = xeno.behavior_delegate
	if(!istype(behavior_del))
		return

	var/obj/limb/target_limb = carbon.get_limb(check_zone(xeno.zone_selected))
	if(ishuman(carbon) && (!target_limb || (target_limb.status & LIMB_DESTROYED)))
		target_limb = carbon.get_limb("chest")

	if(behavior_del.sharp_hits == 0)
		xeno.visible_message(SPAN_XENOWARNING("[xeno] quickly swings it's tail infront of it, bashing [carbon] in the [target_limb ? target_limb.display_name : "chest"]!"), \
		SPAN_XENOWARNING("We quickly swipe [carbon] in the [target_limb ? target_limb.display_name : "chest"] with our tail, bashing them!"))
		playsound(carbon, 'sound/weapons/baton.ogg', 50, 1)
		carbon.apply_effect(3, DAZE)
		carbon.KnockDown(1)
		carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE, target_limb ? target_limb.name : "chest")
		shake_camera(carbon, 2, 1)
		apply_cooldown(2)
		return..()
	else
		xeno.visible_message(SPAN_XENOWARNING("[xeno] quickly swings it's tail infront of it, slashing [carbon] in the [target_limb ? target_limb.display_name : "chest"]!"), \
		SPAN_XENOWARNING("We quickly swipe [carbon] in the [target_limb ? target_limb.display_name : "chest"] with our tail, cutting them!"))
		playsound(carbon, 'sound/weapons/slice.ogg', 50, 1)
		carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, damage), ARMOR_MELEE, BRUTE, target_limb ? target_limb.name : "chest", 10)
		apply_cooldown()
		behavior_del.modify_sharpness(-1)
		return..()

/datum/action/xeno_action/activable/forwardslash/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/damage = (xeno.melee_damage_lower)

	if(!action_cooldown_check())
		return

	var/datum/behavior_delegate/warrior_mercenary/behavior_del = xeno.behavior_delegate
	if(!istype(behavior_del))
		return

	var/list/turf/target_turfs = list()
	var/facing = Get_Compass_Dir(xeno, target)
	var/turf/turf = xeno.loc
	var/turf/temp = xeno.loc
	var/list/telegraph_atom_list = list()

	if(!do_after(xeno, 0.5, INTERRUPT_ALL | BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
		return

	for (var/step in 0 to 1)
		temp = get_step(turf, facing)
		if(facing in GLOB.diagonals)
			var/reverse_face = GLOB.reverse_dir[facing]

			var/turf/back_left = get_step(temp, turn(reverse_face, 45))
			var/turf/back_right = get_step(temp, turn(reverse_face, -45))
			if((!back_left || back_left.density) && (!back_right || back_right.density))
				break
		if(!temp || temp.density || temp.opacity)
			break

		var/blocked = FALSE
		for(var/obj/structure/structure_blocker in temp)
			if(istype(structure_blocker, /obj/structure/window/framed))
				var/obj/structure/window/framed/framed_window = structure_blocker
				if(!framed_window.unslashable)
					framed_window.deconstruct(disassembled = FALSE)

			if(structure_blocker.opacity)
				blocked = TRUE
				break
		if(blocked)
			break

		turf = temp
		target_turfs += turf
		telegraph_atom_list += new /obj/effect/xenomorph/xeno_telegraph/red(turf, 0.25 SECONDS)

	for (var/turf/target_turf in target_turfs)
		for (var/mob/living/carbon/c_target in target_turf)
			if(!isxeno_human(c_target) || xeno.can_not_harm(c_target))
				continue
			if(c_target.stat == DEAD)
				continue
			if(HAS_TRAIT(c_target, TRAIT_NESTED))
				continue



			if(behavior_del.sharp_hits == 0)
				xeno.visible_message(SPAN_XENOWARNING("[xeno] quickly swings it's tail in a wide arc, slamming it into the ground infront of it!"), \
				SPAN_XENOWARNING("We quickly swing our tail and slam the ground infront of us!"))
				playsound(c_target, 'sound/weapons/baton.ogg', 50, 1)
				c_target.apply_effect(3, DAZE)
				c_target.KnockDown(0.5)
				step_away(c_target, xeno)
				c_target.apply_armoured_damage(get_xeno_damage_slash(c_target, damage), ARMOR_MELEE, BRUTE)
				shake_camera(c_target, 2, 1)
				apply_cooldown(2)
				return..()
			else
				xeno.visible_message(SPAN_XENOWARNING("[xeno] quickly swings it's tail in a wide arc, slashing the ground infront of it!"), \
				SPAN_XENOWARNING("We quickly swing our tail and slash the ground infront of us!"))
				playsound(c_target, 'sound/weapons/slice.ogg', 50, 1)
				c_target.apply_armoured_damage(get_xeno_damage_slash(c_target, damage), ARMOR_MELEE, BRUTE, 10)
				apply_cooldown()
				behavior_del.modify_sharpness(-1)
				return..()

/datum/action/xeno_action/activable/spinslash/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/damage = (xeno.melee_damage_lower + xeno.frenzy_aura * FRENZY_DAMAGE_MULTIPLIER)

/datum/action/xeno_action/activable/helmsplitter/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/damage = (xeno.melee_damage_upper + xeno.frenzy_aura * FRENZY_DAMAGE_MULTIPLIER)
