/datum/xeno_strain/torturer
	name = PRAETORIAN_TORTURER
	description = "You trade your ranged abilities, some armor and a bit of slash damage in exchange for abilities oriented around causing and worsening injuries."
	flavor_description = "Sometimes, lessons must be taught through pain. This one shall teach our enemies <B>many</B> powerful lessons."
//	icon_state_prefix = "Torturer"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/pounce/base_prae_dash,
		/datum/action/xeno_action/activable/prae_acid_ball,
		/datum/action/xeno_action/activable/spray_acid/base_prae_spray_acid,
		/datum/action/xeno_action/onclick/tacmap,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/tail_stab/traumatic_stab,
		/datum/action/xeno_action/activable/diagnosis,
		/datum/action/xeno_action/onclick/toggle_vicious_stomp,
		/datum/action/xeno_action/activable/vicious_stomp,
		/datum/action/xeno_action/onclick/sadistic_rush,
		/datum/action/xeno_action/onclick/tacmap,
	)


	behavior_delegate_type = /datum/behavior_delegate/praetorian_torturer

/datum/xeno_strain/torturer/apply_strain(mob/living/carbon/xenomorph/praetorian/prae)
	prae.armor_modifier -= XENO_ARMOR_MOD_VERY_SMALL
	prae.damage_modifier -= XENO_DAMAGE_MOD_MED
	prae.recalculate_everything()

/datum/behavior_delegate/praetorian_torturer
	name = "Praetorian Torturer Behavior Delegate"

	var/sadism_buildup = 0
	var/sadism_buildup_max = 30
	var/sadism_buildup_block = FALSE
	var/sadism_decay_pause = FALSE
	var/sadism_decay_pause_duration = 5 SECONDS
	var/sadism_decay_pause_timer_id = TIMER_ID_NULL
	var/sadism_rush_stomp_cdr = 2 SECONDS
	// Injury detail data
	var/mob/living/carbon/injury_target
	var/list/target_limb_injury_data = list()

/datum/behavior_delegate/praetorian_torturer/proc/modify_sadism_buildup(amount)
	if(sadism_buildup_block)
		return

	sadism_buildup += amount

	if(sadism_buildup < 0)
		sadism_buildup = 0

	if(sadism_buildup > sadism_buildup_max)
		sadism_buildup = sadism_buildup_max


/datum/behavior_delegate/praetorian_torturer/on_life()
	if(sadism_decay_pause != TRUE && (!sadism_buildup <= 0))
		modify_sadism_buildup(-5)

/datum/behavior_delegate/praetorian_torturer/append_to_stat()
	. = list()
	. += "Sadism: [sadism_buildup]/[sadism_buildup_max]"


/datum/behavior_delegate/praetorian_torturer/melee_attack_additional_effects_target(mob/living/carbon/target)
	modify_sadism_buildup(2)

/datum/behavior_delegate/praetorian_torturer/melee_attack_additional_effects_self()
	if(sadism_decay_pause != TRUE)
		sadism_decay_pause = TRUE
	if(sadism_decay_pause_timer_id != TIMER_ID_NULL)
		deltimer(sadism_decay_pause_timer_id)
	sadism_decay_pause_timer_id = addtimer(CALLBACK(src, PROC_REF(resume_sadism_decay)), sadism_decay_pause_duration, TIMER_STOPPABLE)

	var/datum/action/xeno_action/activable/vicious_stomp/cAction = get_action(bound_xeno, /datum/action/xeno_action/activable/vicious_stomp)
	if(sadism_buildup_block && !cAction.action_cooldown_check())
		cAction.reduce_cooldown(sadism_rush_stomp_cdr)

/datum/behavior_delegate/praetorian_torturer/on_hitby_projectile()
	if(sadism_decay_pause != TRUE)
		sadism_decay_pause = TRUE
	if(sadism_decay_pause_timer_id != TIMER_ID_NULL)
		deltimer(sadism_decay_pause_timer_id)
	sadism_decay_pause_timer_id = addtimer(CALLBACK(src, PROC_REF(resume_sadism_decay)), sadism_decay_pause_duration, TIMER_STOPPABLE)

/datum/behavior_delegate/praetorian_torturer/proc/resume_sadism_decay()
	sadism_decay_pause = FALSE

/datum/behavior_delegate/praetorian_torturer/proc/get_injury_details(mob/living/carbon/target, obj/limb/limb_target)
	if(isxeno(target) || issynth(target))
		return

	injury_target = target

	var/robotic_limb = FALSE
	var/internal_bleeding = FALSE
	var/external_bleeding = FALSE
	var/broken = FALSE
	var/splinted = FALSE

	if(limb_target.status & (LIMB_DESTROYED | LIMB_ROBOT | LIMB_SYNTHSKIN))
		robotic_limb = TRUE

	else
		for(var/datum/effects/bleeding/internal/ib in limb_target.bleeding_effects_list)
			internal_bleeding = TRUE

		for(var/datum/effects/bleeding/external/eb in limb_target.bleeding_effects_list)
			external_bleeding = TRUE

		if(limb_target.status & LIMB_BROKEN)
			broken = TRUE

		if(limb_target.status & (LIMB_SPLINTED | LIMB_SPLINTED_INDESTRUCTIBLE))
			splinted = TRUE

	var/list/injury_data = list(
		"robotic" = robotic_limb,
		"brute_damage" = round(limb_target.brute_dam, 0.01),
		"burn_damage" = round(limb_target.burn_dam, 0.01),
		"overall_damage" = round(limb_target.brute_dam, 0.01) + round(limb_target.burn_dam, 0.01),
		"broken_bone" = broken,
		"splinted" = splinted,
		"internal_bleed" = internal_bleeding,
		"external_bleed" = external_bleeding,
	)

	target_limb_injury_data = injury_data

/datum/action/xeno_action/activable/tail_stab/traumatic_stab/use_ability(atom/targetted_atom)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/praetorian_torturer/torturer = xeno.behavior_delegate
	var/target = ..()
	var/final_pain = pain_induced + torturer.sadism_buildup

	if(isxeno(target))
		var/mob/living/carbon/xenomorph/xeno_target = target
		if(xeno_target.plasma_max)
			xeno_target.plasma_stored -= round(final_pain * 1.5, 10)

	else if(ishuman(target) && !issynth(target))
		var/mob/living/carbon/human/human_target = target
		if(isyautja(human_target))
			final_pain = floor(pain_induced / 2) // Preds are tough and can shrug off more pain
		human_target.pain.apply_pain(final_pain)

/datum/action/xeno_action/activable/diagnosis/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/praetorian_torturer/torturer = xeno.behavior_delegate

	if(!action_cooldown_check())
		return

	if(!ismob(target))
		return

	if(get_dist(xeno, target) > 4)
		to_chat(xeno, SPAN_XENOWARNING("We cannot properly diagnose from that far away!"))
		return

	if(!iscarbon(target))
		to_chat(xeno, SPAN_XENOWARNING("We cannot diagnose [target]!"))
		return

	if(isxeno(target))
		to_chat(xeno, SPAN_XENOWARNING("We don't need to diagnose [target] to know how hurt they are!"))
		return

	if(issynth(target))
		to_chat(xeno, SPAN_XENOWARNING("It is a fake, we cannot diagnose them!"))
		return

	var/mob/living/carbon/human/human_target = target
	if(human_target.stat == DEAD)
		to_chat(xeno, SPAN_NOTICE("We don't need to diagnose them to tell that they're dead!"))
		return

	var/obj/limb/target_limb = human_target.get_limb(check_zone(xeno.zone_selected))
	if(target_limb.status & LIMB_DESTROYED)
		to_chat(xeno, SPAN_XENONOTICE("Our target has no [target_limb]!"))
		return

	torturer.get_injury_details(human_target, target_limb)

	var/fake_limb = torturer.target_limb_injury_data["robotic"]
	var/bruising = torturer.target_limb_injury_data["brute_damage"]
	var/burns = torturer.target_limb_injury_data["burn_damage"]
	var/general_damage = torturer.target_limb_injury_data["overall_damage"]
	var/fractures = torturer.target_limb_injury_data["broken_bone"]
	var/splinting = torturer.target_limb_injury_data["splinted"]
	var/internal_bleeds = torturer.target_limb_injury_data["internal_bleed"]
	var/external_bleeds = torturer.target_limb_injury_data["external_bleed"]

	var/percentage_general = (general_damage / target_limb.max_damage) * 100
	var/vague_general = null
	switch(percentage_general)
		if(0)
			vague_general = "it is healthy"
		if(1 to 33)
			vague_general = "it is somewhat damaged"
		if(34 to 66)
			vague_general = "it is quite damaged"
		if(67 to 99)
			vague_general = "it is severely damaged"
		if(100)
			vague_general = "it is as damaged as can be"

	var/prognosis = null

	if(fake_limb)
		prognosis = "that it is fake!"
	else
		if(general_damage)
			prognosis = vague_general
		if(bruising)
			prognosis += " with bruises"
		if(burns)
			if(bruising)
				prognosis += " and burns."
			else
				prognosis += " with burns."
		else if(general_damage == 0)
			prognosis += vague_general
			prognosis += "."
		else
			prognosis += "."

		if(fractures && !splinting)
			prognosis += " It has unsecured fracturing!"
		else if(splinting)
			prognosis += " It has secured fracturing!"

		if(internal_bleeds)
			prognosis += " It has internal bleeding!"

		if(external_bleeds)
			prognosis += " It has some open and bleeding wounds!"

	to_chat(xeno, SPAN_XENOBOLDNOTICE("We diagnose [target_limb] of [human_target]... We can tell [prognosis]"))

	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/vicious_stomp/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/praetorian_torturer/torturer = xeno.behavior_delegate

	if(!action_cooldown_check())
		return

	if(!xeno.check_state())
		return

	if(!isturf(xeno.loc))
		to_chat(xeno, SPAN_XENOWARNING("We can't leap from here!"))
		return

	if(get_dist(xeno, target) > max_range)
		return

	if(xeno.can_not_harm(target) || !iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	if(carbon_target.stat == DEAD)
		return

	if(!check_and_use_plasma_owner())
		return

	var/obj/limb/target_limb = carbon_target.get_limb(check_zone(xeno.zone_selected))
	if(ishuman(target) && target_limb.status & LIMB_DESTROYED)
		target_limb = target_limb = carbon_target.get_limb("chest")

	xeno.throw_atom(get_step_towards(carbon_target, xeno), max_range, SPEED_FAST, xeno, tracking=TRUE)
	if(xeno.Adjacent(carbon_target))
		xeno.face_atom(carbon_target)
		if(carbon_target.mob_size < MOB_SIZE_IMMOBILE && !isravager(carbon_target))
			carbon_target.KnockDown(1.5)
		carbon_target.Stun(1.5)
		sleep(3)
		xeno.animation_attack_on(carbon_target)
		carbon_target.apply_armoured_damage(get_xeno_damage_slash(carbon_target, xeno.melee_damage_upper), ARMOR_MELEE, BRUTE, xeno.zone_selected, 10)
		if(ishuman(carbon_target))
			if(bleed_toggle)
				playsound(carbon_target.loc, 'sound/weapons/alien_tail_attack.ogg', 30)
				xeno.flick_attack_overlay(carbon_target, "slash")
				xeno.visible_message(SPAN_XENOWARNING("[xeno] bodyslams [carbon_target] before brutally ramming their claws into their [target_limb.display_name]!"),
				SPAN_XENOWARNING("We bodyslam [carbon_target] and ram our claws into their [target_limb.display_name]!"))
				if(!(target_limb.status & LIMB_ROBOT|LIMB_SYNTHSKIN))
					var/is_bleeding = FALSE
					for(var/datum/effects/bleeding/external/eb in target_limb.bleeding_effects_list)
						carbon_target.apply_armoured_damage(get_xeno_damage_slash(carbon_target, xeno.melee_damage_upper), ARMOR_MELEE, BRUTE, xeno.zone_selected, 10)
						is_bleeding = TRUE
					if(is_bleeding)
						target_limb.add_bleeding(damage_amount = xeno.melee_damage_upper)
						is_bleeding = FALSE
			else
				playsound(carbon_target.loc, "punch", 30)
				playsound(carbon_target.loc, 'sound/weapons/alien_tail_attack.ogg', 20)
				xeno.flick_attack_overlay(carbon_target, "punch")
				xeno.visible_message(SPAN_XENOWARNING("[xeno] bodyslams [carbon_target] before violently stomping on their [target_limb.display_name]!"),
				SPAN_XENOWARNING("We bodyslam [carbon_target] and stomp on their [target_limb.display_name]!"))
				if((target_limb.status & LIMB_SPLINTED) && !(target_limb.status & LIMB_SPLINTED_INDESTRUCTIBLE))
					target_limb.status &= ~LIMB_SPLINTED
					playsound(get_turf(carbon_target), 'sound/items/splintbreaks.ogg', 20)
					to_chat(carbon_target, SPAN_DANGER("The splint on your [target_limb.display_name] comes apart!"))
					carbon_target.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)
				else if(target_limb.status & LIMB_BROKEN)
					carbon_target.apply_armoured_damage(get_xeno_damage_slash(carbon_target, xeno.melee_damage_upper), ARMOR_MELEE, BRUTE, xeno.zone_selected)
				else if(!(target_limb.status & LIMB_SPLINTED_INDESTRUCTIBLE))
					target_limb.fracture(100)

		if(isxeno(carbon_target))
			playsound(carbon_target.loc, 'sound/weapons/alien_claw_block.ogg', 30)
			xeno.flick_attack_overlay(carbon_target, "disarm")
			xeno.visible_message(SPAN_XENOWARNING("[xeno] bodyslams [carbon_target] before kicking them!"),
			SPAN_XENOWARNING("We bodyslam and kick [carbon_target] away!"))
			if(carbon_target.mob_size < MOB_SIZE_BIG)
				var/facing = get_dir(xeno, carbon_target)
				xeno.throw_carbon(carbon_target, facing, 2, SPEED_VERY_FAST, shake_camera = TRUE, immobilize = TRUE)
			else
				shake_camera(carbon_target, 2, 1)
				step_away(carbon_target, xeno, 1)

	if(ishuman(target) && !issynth(target))
		carbon_target.pain.apply_pain(round(torturer.sadism_buildup * 1.5))
	torturer.modify_sadism_buildup(8)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/sadistic_rush/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/praetorian_torturer/torturer = xeno.behavior_delegate

	if(!action_cooldown_check())
		return

	if(!xeno.check_state())
		return

	if(torturer.sadism_buildup <= 0 && torturer.sadism_buildup >= 5)
		to_chat(xeno, SPAN_XENOWARNING("We do not feel excited enough! We must inflict more pain!"))
		return

	if(!check_and_use_plasma_owner())
		return

	var/sadismrush_duration = round(torturer.sadism_buildup * 0.25, 1) + 2
	var/sadismrush_movement = 0
	var/sadismrush_atkspd = 0

	switch(torturer.sadism_buildup)
		if(0 to 10)
			sadismrush_movement = -0.15
			sadismrush_atkspd = 1
		if(11 to 20)
			sadismrush_movement = -0.30
			sadismrush_atkspd= 1.5
		if(21 to 30)
			sadismrush_movement = -0.45
			sadismrush_atkspd = 2

	xeno.speed_modifier += sadismrush_movement
	xeno.attack_speed_modifier -= sadismrush_atkspd
	xeno.recalculate_everything()
	torturer.sadism_buildup = 0
	torturer.sadism_buildup_block = TRUE
	addtimer(CALLBACK(src, PROC_REF(sadismrush_end), xeno, sadismrush_movement, sadismrush_atkspd), sadismrush_duration SECONDS, TIMER_STOPPABLE)

	xeno.emote("roar")
	xeno.xeno_jitter(sadismrush_atkspd SECONDS) // Some slight dynamicism
	xeno.visible_message(SPAN_XENOWARNING("[xeno] twitches and roars in palpably malicious glee!"),
	SPAN_XENOBOLDNOTICE("We experience a rush as we release built-up adrenaline from our sadistic spree!"))

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/sadistic_rush/proc/sadismrush_end(mob/living/carbon/xenomorph/xeno, movement, atkspd)
	var/datum/behavior_delegate/praetorian_torturer/torturer = xeno.behavior_delegate

	to_chat(xeno, SPAN_XENONOTICE("We feel our sadistic rush subside, followed by disappointment."))
	xeno.speed_modifier -= movement
	xeno.attack_speed_modifier += atkspd
	xeno.recalculate_everything()
	torturer.sadism_buildup_block = FALSE
