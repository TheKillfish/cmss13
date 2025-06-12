/datum/effects/xeno_slash
	effect_name = "slash"
	flags = DEL_ON_DEATH | INF_DURATION
	var/added_effect = FALSE
	var/effect_slash_modifier = 0
	var/effect_modifier_source = null
	var/effect_end_message = null

/datum/effects/xeno_slash/New(atom/affected, mob/from = null, last_dmg_source = null, zone = "chest", ttl = 3.5 SECONDS, set_slash_modifier = 0, set_modifier_source = null, set_end_message = SPAN_XENONOTICE("You feel your claws return to normal."))
	. = ..(affected, from, last_dmg_source, zone)
	if(QDELETED(src))
		return
	QDEL_IN(src, ttl)
	var/mob/living/carbon/xenomorph/xeno = affected
	xeno.damage_modifier += set_slash_modifier
	xeno.recalculate_damage()
	if(set_modifier_source)
		LAZYADD(xeno.modifier_sources, set_modifier_source)
	effect_slash_modifier = set_slash_modifier
	effect_modifier_source = set_modifier_source
	effect_end_message = set_end_message
	added_effect = TRUE

/datum/effects/xeno_slash/validate_atom(atom/affected)
	if(!isxeno(affected))
		return FALSE
	return ..()

/datum/effects/xeno_slash/Destroy()
	if(added_effect)
		var/mob/living/carbon/xenomorph/xeno = affected_atom
		xeno.damage_modifier -= effect_slash_modifier
		xeno.recalculate_damage()
		if(effect_modifier_source)
			LAZYREMOVE(xeno.modifier_sources, effect_modifier_source)
		if(effect_end_message)
			to_chat(xeno, effect_end_message)
	return ..()
