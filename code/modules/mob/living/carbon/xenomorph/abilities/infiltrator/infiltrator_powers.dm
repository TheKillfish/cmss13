/datum/action/xeno_action/activable/spystab/spy/use_ability(atom/target)
	. = ..()

/datum/action/xeno_action/onclick/vanish/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate
	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	spy.vanished = !spy.vanished

	if(spy.vanished)
		to_chat(xeno, SPAN_XENOWARNING("We turn invisible."))
		enter_vanish()
		button.icon_state = "template_active"
	else
		to_chat(xeno, SPAN_XENOWARNING("We become visible again."))
		exit_vanish()
		button.icon_state = "template"

	return ..()

/datum/action/xeno_action/onclick/vanish/proc/enter_vanish()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	button.icon_state = "template_active"
	xeno.update_icons()

	animate(xeno, alpha = alpha_amount, time = 0.5 SECONDS, easing = QUAD_EASING)

	spy.on_invisibility()
	apply_cooldown()

/datum/action/xeno_action/onclick/vanish/proc/exit_vanish()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(owner.alpha == initial(owner.alpha) && !spy.vanished)
		return

	button.icon_state = "template"
	xeno.update_icons()

	animate(xeno, alpha = initial(xeno.alpha), time = 0.5 SECONDS, easing = QUAD_EASING)

	spy.on_invisibility_off()
	apply_cooldown()

/datum/action/xeno_action/onclick/spy_dodge/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	spy.dodging = TRUE
	button.icon_state = "template_active"
	to_chat(xeno, SPAN_XENOHIGHDANGER("We can now dodge through mobs!"))
	xeno.evasion_modifier += XENO_EVASION_MOD_ULTRA * 2
	xeno.add_temp_pass_flags(PASS_MOB_THRU)
	xeno.recalculate_evasion()

	addtimer(CALLBACK(src, PROC_REF(remove_effects)), duration)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/spy_dodge/proc/remove_effects()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(spy.dodging)
		spy.dodging = FALSE
		button.icon_state = "template"
		xeno.evasion_modifier -= XENO_EVASION_MOD_ULTRA * 2
		xeno.remove_temp_pass_flags(PASS_MOB_THRU)
		xeno.recalculate_evasion()
		to_chat(xeno, SPAN_XENOHIGHDANGER("We can no longer dodge through mobs!"))

/datum/action/xeno_action/onclick/smokescreen/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate
	var/datum/effect_system/smoke_spread/xeno_smokescreen/smokescreen
	smokescreen = new /datum/effect_system/smoke_spread/xeno_smokescreen

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	playsound(xeno.loc, 'sound/effects/smoke.ogg', 20, 1, 4)

	smokescreen.set_up(3, 0, get_turf(xeno))
	smokescreen.start()
	xeno.visible_message(SPAN_XENODANGER("Smoke billows from [xeno]!"))

	spy.smokeescape = TRUE
	button.icon_state = "template_active"
	to_chat(xeno, SPAN_XENODANGER("After emitting our smokescreen, we gain a burst of speed to escape!"))
	xeno.speed_modifier -= speed_buff
	xeno.recalculate_speed()

	addtimer(CALLBACK(src, PROC_REF(remove_smoke_speed)), duration)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/smokescreen/proc/remove_smoke_speed()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/datum/behavior_delegate/infiltrator_base/spy = xeno.behavior_delegate

	if(!istype(xeno))
		return

	if(!istype(spy))
		return

	if(spy.smokeescape)
		spy.smokeescape = FALSE
		button.icon_state = "template"
		xeno.speed_modifier += speed_buff
		xeno.recalculate_speed()
		to_chat(xeno, SPAN_XENODANGER("We feel our burst of speed wear off!"))
