/datum/action/xeno_action/activable/brutalassault/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if(!action_cooldown_check())
		return

	if(!xeno.check_state())
		return

	if(!isxeno_human(affected_atom) || xeno.can_not_harm(affected_atom))
		return

	if(!xeno.Adjacent(affected_atom))
		return

	var/mob/living/carbon/carbon = affected_atom
	if(carbon.stat == DEAD)
		return

	if(HAS_TRAIT(carbon, TRAIT_NESTED))
		return

	apply_cooldown()

	// Overcomplicated ability switches effects based on target species (human, xeno or pred?) and state (are they prone or not?)
	// Ability effect differs between species and
	// Target species adds a number depending on type; preds are 1, humans are 3, xenos are 5
	// Target state adds another number depending on if they are standing or not; standing is 1, prone is 2
	// This means Preds are 2-3, humans are 4-5, and xenos are 6-7
	var/target_type_state = 0

	// Damage is shared between all variants, tweaked with multiplier if more or less is needed
	var/base_damage = 40
	var/big_damage = 60
	var/small_damage = 20

	if(isyautja(carbon))
		target_type_state += 1

	if(ishumansynth_strict(carbon))
		target_type_state += 3

	if(isxeno(carbon))
		target_type_state += 5

	if(carbon.body_position == STANDING_UP)
		target_type_state += 1

	if(carbon.body_position == LYING_DOWN)
		target_type_state += 2

	xeno.face_atom(carbon)

	switch(target_type_state)
		if(2) // Target is Pred and Standing; big threat, shoulderbash them to knock them over then a kick.
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "disarm")
			playsound(carbon, 'sound/effects/bang.ogg', 15, 0)
			playsound(carbon, 'sound/weapons/alien_knockdown.ogg', 25, 0)
			carbon.KnockDown(4)
			carbon.Stun(2)
			sleep(4)
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "punch")
			playsound(carbon, 'sound/weapons/alien_claw_block.ogg', 50, 1)
			carbon.apply_armoured_damage(small_damage, ARMOR_MELEE, BRUTE, "chest")
			xeno.visible_message(SPAN_XENOWARNING("[xeno] shoulderbashes [carbon] to the ground, then kicks them in the chest!"), \
			SPAN_XENOWARNING("We shoulderbash [carbon] to the ground, then we kick them while they're down!"))

		if(3) // Target is Pred and Prone; vulnerable big threat, play safe and stab with tail in CoM.
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "tail")
			playsound(carbon, 'sound/weapons/alien_tail_attack.ogg', 50, TRUE)
			carbon.apply_armoured_damage(base_damage, ARMOR_MELEE, BRUTE, "chest", 10)
			carbon.Stun(1)
			carbon.apply_effect(3, SLOW)
			xeno.visible_message(SPAN_XENOWARNING("[xeno] swiftly stabs [carbon] in the chest with their tail!"), \
			SPAN_XENOWARNING("We stab [carbon] in the chest with our tail!"))

		if(4) // Target is Human/Synth and Standing; weak threat, hit so hard they are flung.
			var/facing = get_dir(xeno, carbon)
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "disarm")
			playsound(carbon, 'sound/weapons/alien_claw_block.ogg', 75, 1)
			carbon.apply_armoured_damage(base_damage, ARMOR_MELEE, BRUTE, "chest")
			xeno.throw_carbon(carbon, facing, 1, SPEED_FAST, shake_camera = TRUE, immobilize = TRUE)
			carbon.KnockDown(2)
			carbon.apply_effect(3, SLOW)
			xeno.visible_message(SPAN_XENOWARNING("[xeno] knee-bashes [carbon] in the chest so hard, flinging them away!"), \
			SPAN_XENOWARNING("We bash into [carbon] flinging them!"))

		if(5) // Target is Human/Synth and Prone; vulnerable weak threat, lift and smash into ground.
			animate(carbon, pixel_y = carbon.pixel_y + 16, time = 2, easing = SINE_EASING)
			sleep(2)
			playsound(carbon, 'sound/effects/bang.ogg', 25, 0)
			playsound(carbon, "slam", 50, 1)
			animate(carbon, pixel_y = 0, time = 2, easing = BOUNCE_EASING)
			carbon.apply_armoured_damage(big_damage, ARMOR_MELEE, BRUTE, "chest", 10)
			carbon.Stun(2)
			carbon.apply_effect(4, SLOW)
			xeno.visible_message(SPAN_XENOWARNING("[xeno] swiftly lifts [carbon] before smashing them into the ground!"), \
			SPAN_XENOWARNING("We lift [carbon] and smash them into the ground!"))

		if(6) // Target is Xeno and Standing; rival threat, headbutt to disorient.
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "punch")
			playsound(carbon, 'sound/effects/bang.ogg', 15, 0)
			playsound(carbon, 'sound/weapons/alien_claw_block.ogg', 75, 1)
			carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, base_damage), ARMOR_MELEE, BRUTE)
			if(carbon.mob_size < MOB_SIZE_BIG)
				carbon.Stun(2)
			carbon.apply_effect(4, SLOW)
			xeno.emote("roar")

		if(7) // Target is Xeno and Prone; vulnerable rival threat, headbite to ensure crippling damage.
			xeno.animation_attack_on(carbon)
			xeno.flick_attack_overlay(carbon, "headbite")
			playsound(carbon,'sound/weapons/alien_bite2.ogg', 50, TRUE)
			carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, big_damage), ARMOR_MELEE, BRUTE, penetration = 20)
			xeno.emote("roar")

		else // In case a target is somehow literally none of these, just punch them as a failsafe.

	return ..()
