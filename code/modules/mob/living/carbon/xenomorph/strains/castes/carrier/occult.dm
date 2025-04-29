/datum/xeno_strain/occult
	name = CARRIER_OCCULT
	description = "In exchange for your ability to store huggers and place traps, you gain larger plasma stores, strong pheromones, and the ability to lay eggs by using your plasma stores. In addition, you can now carry twelve eggs at once and can place eggs one pace further than normal. \n\nYou can also place a small number of fragile eggs on normal weeds. These eggs have a lifetime of five minutes while you remain within 14 tiles. Or one minute if you leave this range."
	flavor_description = "An egg is always an adventure; the next one may be different."
	icon_state_prefix = "Eggsac"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/onclick/place_trap,
		/datum/action/xeno_action/activable/retrieve_egg,
		/datum/action/xeno_action/onclick/set_hugger_reserve,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/retrieve_egg/not_primary,
		/datum/action/xeno_action/onclick/bloodletting,
		/datum/action/xeno_action/onclick/select_ritual,
		/datum/action/xeno_action/onclick/initiate_ritual,
	)

	behavior_delegate_type = /datum/behavior_delegate/carrier_occult

/datum/xeno_strain/occult/apply_strain(mob/living/carbon/xenomorph/carrier/carrier)
	carrier.health_modifier -= XENO_HEALTH_MOD_LARGE
	carrier.tackle_chance_modifier -= 10

	if(carrier.huggers_cur)
		playsound(carrier.loc, 'sound/voice/alien_facehugger_dies.ogg', 25, TRUE)
	carrier.huggers_cur = 0
	carrier.huggers_max = 0
	carrier.update_hugger_overlays()
	carrier.update_eggsac_overlays()
	carrier.eggs_max = 4

/datum/behavior_delegate/carrier_occult
	name = "Occult Carrier Behavior Delegate"

	var/bloodletting_timer_id = TIMER_ID_NULL
	var/bloodletting_bonus_active = FALSE
	var/bloodletting_bonus_damage = 5
	var/current_ritual = "syncope"
	var/eggs_needed = 1
	var/plasma_cost_multiplier = 1
	var/performing_ritual = FALSE
	var/ritual_windup = 3.5 SECONDS

/datum/behavior_delegate/carrier_occult/melee_attack_modify_damage(original_damage, mob/living/carbon/carbon)
	if(bloodletting_bonus_active)
		return original_damage + bloodletting_bonus_damage

	return original_damage

/datum/behavior_delegate/carrier_occult/append_to_stat()
	. = list()
	switch(current_ritual)
		if("syncope")
			. += "Current Ritual: Ritual of Syncope"
		if("snaring")
			. += "Current Ritual: Ritual of Snaring"
		if("asceticism")
			. += "Current Ritual: Ritual of Asceticism"
	if(bloodletting_timer_id != TIMER_ID_NULL)
		. += "Bloodletting Buff Duration: [timeleft(bloodletting_timer_id)] remaining"

/datum/behavior_delegate/carrier_occult/proc/check_and_use_valid_eggs(use_eggs = TRUE, required_number = 1)
	var/mob/living/carbon/xenomorph/carrier/occult = bound_xeno

	// Check portion
	var/avaliable_eggs = 0
	var/eggs_needed_4_use = required_number

	var/obj/item/xeno_egg/eggie_active_hand = occult.get_active_hand()
	if(eggie_active_hand)
		if(eggie_active_hand.hivenumber == occult.hivenumber)
			avaliable_eggs += 1

	var/obj/item/xeno_egg/eggie_inactive_hand = occult.get_inactive_hand()
	if(eggie_inactive_hand)
		if(eggie_inactive_hand.hivenumber == occult.hivenumber)
			avaliable_eggs += 1

	if(occult.eggs_cur > 0)
		avaliable_eggs += occult.eggs_cur

	if(!(avaliable_eggs >= eggs_needed_4_use))
		avaliable_eggs = 0
		return FALSE

	// Use portion
	var/avaliable_eggs_4_use = required_number

	if(use_eggs == TRUE)
		if(eggie_active_hand)
			avaliable_eggs_4_use -= 1
			qdel(eggie_active_hand)
			if(avaliable_eggs_4_use == 0)
				return TRUE

		if(eggie_inactive_hand)
			avaliable_eggs_4_use -= 1
			qdel(eggie_inactive_hand)
			if(avaliable_eggs_4_use == 0)
				return TRUE

		if(occult.eggs_cur > 0)
			occult.eggs_cur -= avaliable_eggs_4_use

	return TRUE

/datum/behavior_delegate/carrier_occult/proc/choose_ritual(ritual)
	if(bound_xeno.client.prefs && bound_xeno.client.prefs.no_radials_preference)
		ritual = tgui_input_list(bound_xeno, "Choose a Ritual", "Ritual Menu", "syncope" + "snaring" + "asceticism" + "help" + "cancel", theme="hive_status")
		if(ritual == "help")
			to_chat(bound_xeno, SPAN_NOTICE("<br>You can choose between three Rituals to perform at the cost of plasma or eggs, with varying effects:<br><B>Ritual of Syncope</B> - Blurs the vision of hostiles and reduces their accuracy where applicable. Infected hosts will momentarily collapse.<br><B>Ritual of Snaring</B> - Greatly slows down hostiles, and roots them if they stand on weeds.<br><B>Ritual of Asceticism</B> - Purges chemicals or plasma from hostiles where applicable.<br>Do note that these Rituals each have a wind-up to perform and share a 30 second cooldown. <B>Choose carefully.</B>"))
			return
		if(!ritual || ritual == "cancel" || !bound_xeno.check_state(1)) //If they are stacking windows, disable all input
			return
	else
		var/static/list/ritual_selections = list("Help" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_help"), "syncope" = image(icon = 'icons/mob/radial.dmi', icon_state = "phero_frenzy"), "snaring" = image(icon = 'icons/mob/radial.dmi', icon_state = "phero_warding"), "asceticism" = image(icon = 'icons/mob/radial.dmi', icon_state = "phero_recov"))
		ritual = lowertext(show_radial_menu(bound_xeno, bound_xeno.client?.eye, ritual_selections))
		if(ritual == "help")
			to_chat(bound_xeno, SPAN_NOTICE("<br>You can choose between three Rituals to perform at the cost of plasma or eggs, with varying effects:<br><B>Ritual of Syncope</B> - Blurs the vision of hostiles and reduces their accuracy where applicable. Infected hosts will momentarily collapse.<br><B>Ritual of Snaring</B> - Greatly slows down hostiles, and roots them if they stand on weeds.<br><B>Ritual of Asceticism</B> - Purges chemicals or plasma from hostiles where applicable.<br>Do note that these Rituals each have a wind-up to perform and share a 30 second cooldown. <B>Choose carefully.</B>"))
			return
		if(!ritual || ritual == "cancel" || !bound_xeno.check_state(1)) //If they are stacking windows, disable all input
			return
	if(ritual)
		if(ritual == "syncope")
			eggs_needed = 1
			plasma_cost_multiplier = 0.25
			ritual_windup = 3.5 SECONDS
			to_chat(bound_xeno, SPAN_XENOWARNING("We prepare ourself mentally to perform Ritual of Syncope! To perform this Ritual, we require either 1 egg or 125 plasma!<br>After a somewhat quick performance, our enemies will be dazed and confused, unable to shoot properly! Additionally, any infected hosts will briefly collapse!"))
		if(ritual == "snaring")
			eggs_needed = 2
			plasma_cost_multiplier = 0.5
			ritual_windup = 2 SECONDS
			to_chat(bound_xeno, SPAN_XENOWARNING("We prepare ourself mentally to perform Ritual of Snaring! To perform this Ritual, we require either 2 eggs or 250 plasma!<br>After a quick performance, our enemies will find it hard to move properly! Additionally, any who stand upon weeds belonging to our hive or allied hives will be momentarily rooted in place!"))
		if(ritual == "asceticism")
			eggs_needed = 4
			plasma_cost_multiplier = 1
			ritual_windup = 5 SECONDS
			to_chat(bound_xeno, SPAN_XENOWARNING("We prepare ourself mentally to perform Ritual of Asceticism! To perform this Ritual, we require either 4 eggs or 500 plasma!<br>After a slow performance, our enemies will find themselves drained of any chemicals in their body if they are hosts, or of plasma if they are a hostile hive!"))
		current_ritual = ritual
		return

/datum/action/xeno_action/onclick/bloodletting/use_ability()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/carrier_occult/occult = xeno.behavior_delegate

	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	if(occult.performing_ritual)
		to_chat(xeno, SPAN_XENOWARNING("We must commit to performing our Ritual!"))
		return

	if(xeno.health <= 100)
		to_chat(xeno, SPAN_XENOWARNING("We are too weak to bloodlet further!"))
		return

	if(SEND_SIGNAL(xeno, COMSIG_XENO_PRE_HEAL) & COMPONENT_CANCEL_XENO_HEAL)
		to_chat(xeno, SPAN_XENOWARNING("We are not in a state where we should bloodlet!"))
		return

	xeno.visible_message(SPAN_XENONOTICE("[xeno] stabs itself with its tail!"),	SPAN_XENONOTICE("We stab ourself with our tail and feel a rush of strength!"), null, 5)
	playsound(xeno.loc, 'sound/weapons/alien_tail_attack.ogg', 25, TRUE)
	xeno.adjustBruteLoss(health_cost)
	xeno.gain_plasma(plasma_recovery)

	occult.bloodletting_bonus_active = TRUE
	if(occult.bloodletting_timer_id != TIMER_ID_NULL)
		deltimer(occult.bloodletting_timer_id)
		occult.bloodletting_timer_id = TIMER_ID_NULL
	occult.bloodletting_timer_id = addtimer(CALLBACK(src, PROC_REF(reset_timer_id)), 5 SECONDS, TIMER_STOPPABLE)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/bloodletting/proc/reset_timer_id()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/carrier_occult/occult = xeno.behavior_delegate

	occult.bloodletting_bonus_active = FALSE
	if(occult.bloodletting_timer_id != TIMER_ID_NULL)
		deltimer(occult.bloodletting_timer_id)
		occult.bloodletting_timer_id = TIMER_ID_NULL

/datum/action/xeno_action/onclick/select_ritual/use_ability()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/carrier_occult/occult = xeno.behavior_delegate

	if(!xeno.check_state())
		return

	if(occult.performing_ritual)
		to_chat(xeno, SPAN_XENOWARNING("We must commit to performing our Ritual!"))
		return

	occult.choose_ritual()
	return ..()

/datum/action/xeno_action/onclick/initiate_ritual/use_ability()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/carrier_occult/occult = xeno.behavior_delegate

	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	if(!occult.check_and_use_valid_eggs(FALSE, required_number = occult.eggs_needed) && !check_plasma_owner(plasma_cost * occult.plasma_cost_multiplier))
		to_chat(xeno, SPAN_XENOWARNING("We don't have enough eggs or plasma to perform our Ritual! We need [occult.eggs_needed] eggs or [plasma_cost * occult.plasma_cost_multiplier] plasma!"))
		return

	if(occult.performing_ritual)
		to_chat(xeno, SPAN_XENOWARNING("We are already performing a Ritual!"))
		return

	if(occult.check_and_use_valid_eggs(required_number = occult.eggs_needed))
		if(occult.eggs_needed > 1)
			xeno.visible_message(SPAN_XENOBOLDNOTICE("[xeno] lifts some eggs with its tail, slowly constricting and crushing them!"), SPAN_XENOBOLDNOTICE("We raise some eggs in prepartion for our Ritual!"))

		else
			xeno.visible_message(SPAN_XENOBOLDNOTICE("[xeno] lifts an egg with its tail, slowly constricting and crushing it!"), SPAN_XENOBOLDNOTICE("We raise an egg, preparing to sacrifice it!"))

	else if(check_and_use_plasma_owner())
		xeno.visible_message(SPAN_XENOBOLDNOTICE("[xeno] raises its tail, slowly constricting the air!"), SPAN_XENOBOLDNOTICE("We consolidate plasma in preparation for our Ritual!"))

	occult.performing_ritual = TRUE
	if(!do_after(xeno, occult.ritual_windup, INTERRUPT_ALL, ACTION_PURPLE_POWER_UP))
		to_chat(xeno, SPAN_XENOWARNING("Our Ritual was interrupted, our resources wasted!"))
		occult.performing_ritual = FALSE
		return

	xeno.emote("roar")
	xeno.visible_message(SPAN_XENOBOLDNOTICE("A powerful wave of indescribable pheremones flows out from [xeno]!"), \
	SPAN_XENOBOLDNOTICE("We complete our Ritual of Syncope and release a burst of pheremones that affects the sight of hostiles!"))

	for(var/mob/living/carbon/victim in oviewers(5, xeno.loc))
		if(victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_NESTED))
			continue

		if(xeno.can_not_harm(victim))
			continue

		if(isyautja(victim) && prob(75))
			continue

		switch(occult.current_ritual)
			if("syncope")
				shake_camera(victim, 2, 1)
				victim.EyeBlur(3)
				victim.Daze(2)
				if(ishuman(victim))
					ADD_TRAIT(victim, TRAIT_INACCURATE, TRAIT_SOURCE_ABILITY("Ritual of Syncope"))
					addtimer(CALLBACK(src, PROC_REF(syncope_innacuracy_end), victim), 5 SECONDS)
					if(victim.status_flags & XENO_HOST)
						to_chat(victim, SPAN_DANGER("You collapse as your eyes throb badly in pain, your vision blurring and fading!"))
						victim.apply_effect(1.5 SECONDS, WEAKEN)
					else if(issynth(victim))
						to_chat(victim, SPAN_DANGER("Something is negatively affecting our ability to process visuals!"))
					else
						to_chat(victim, SPAN_DANGER("Your eyesight suddenly fades and goes blurry, and something is making it very hard to aim properly!"))
				else if(isxeno(victim))
					to_chat(victim, SPAN_DANGER("The world suddenly goes blurry and dark as something inhibits our ability to see!"))

			if("snaring")
				victim.Superslow(4 SECONDS)
				var/obj/effect/alien/weeds/turf_weeds = locate() in victim.loc
				if(turf_weeds && HIVE_ALLIED_TO_HIVE(turf_weeds.linked_hive.hivenumber, xeno.hivenumber))
					if(isxeno(victim))
						to_chat(victim, SPAN_DANGER("The weeds beneath us have grabbed onto our legs, preventing us from moving!"))
					else
						to_chat(victim, SPAN_DANGER("The weeds beneath you suddenly wrap around your legs, preventing you from moving!"))
					ADD_TRAIT(victim, TRAIT_IMMOBILIZED, TRAIT_SOURCE_ABILITY("Ritual of Snaring"))
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(unroot_human), victim, TRAIT_SOURCE_ABILITY("Ritual of Snaring")), 2 SECONDS)

			if("asceticism")
				if(ishuman(victim) && !issynth(victim))
					var/mob/living/carbon/human/humanoid_victim = victim
					for(var/datum/reagent/generated/stim in humanoid_victim.reagents.reagent_list)
						humanoid_victim.reagents.remove_reagent(stim.id, 15, TRUE)
					for(var/datum/reagent/medical/med in humanoid_victim.reagents.reagent_list)
						humanoid_victim.reagents.remove_reagent(med.id, 15, TRUE)
					to_chat(victim, SPAN_DANGER("A feeling of draining washes over you!"))
				else if(isxeno(victim))
					var/mob/living/carbon/xenomorph/xeno_victim = victim
					if(xeno_victim.plasma_max > 0)
						xeno_victim.plasma_stored = max(xeno_victim.plasma_stored - (xeno_victim.plasma_max / 3), 0)
						to_chat(xeno_victim, SPAN_DANGER("We feel our plasma reserves being drained!"))

	occult.performing_ritual = FALSE
	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/initiate_ritual/proc/syncope_innacuracy_end(mob/living/carbon/victim)
	REMOVE_TRAIT(victim, TRAIT_INACCURATE, TRAIT_SOURCE_ABILITY("Ritual of Syncope"))
	to_chat(victim, SPAN_NOTICE("We feel our ability to aim properly return."))
