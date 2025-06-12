/datum/caste_datum/centurion
	caste_type = XENO_CASTE_CENTURION
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_3
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_7
	plasma_gain = XENO_PLASMA_GAIN_TIER_5
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_ARMOR_MOD_MED
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_6

	caste_desc = "A flexible intermediate leader."
	spit_types = list(/datum/ammo/xeno/acid)
	evolves_to = list(XENO_CASTE_PRAETORIAN)
	deevolves_to = list(XENO_CASTE_SENTINEL)
	acid_level = 1

	spit_delay = 2.5 SECONDS

	tackle_min = 4
	tackle_max = 4
	tackle_chance = 50
	tacklestrength_min = 4
	tacklestrength_max = 4

	behavior_delegate_type = /datum/behavior_delegate/centurion_base
	minimap_icon = "spitter"

	minimum_evolve_time = 9 MINUTES

/mob/living/carbon/xenomorph/centurion
	caste_type = XENO_CASTE_CENTURION
	name = XENO_CASTE_CENTURION
	desc = "A durable commander-esque alien."
	icon_size = 48
	icon_state = "Centurion Walking"
	plasma_types = list(PLASMA_NEUROTOXIN)
	pixel_x = -12
	old_x = -12
	tier = 2
	organ_value = 2000
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/corrosive_acid/weak,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/onclick/neurotoxic_slash,
		/datum/action/xeno_action/activable/bounding_slash,
		/datum/action/xeno_action/onclick/rallying_roar,
		/datum/action/xeno_action/onclick/tacmap,
	)

	icon_xeno = 'icons/mob/xenos/castes/tier_2/centurion.dmi'
	//icon_xenonid = 'icons/mob/xenonids/castes/tier_2/centurion.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Warrior_1","Warrior_2","Warrior_3")
	weed_food_states_flipped = list("Warrior_1","Warrior_2","Warrior_3")

	skull = /obj/item/skull/warrior
	pelt = /obj/item/pelt/warrior

/datum/behavior_delegate/centurion_base
	name = "Base Centurion Behavior Delegate"

	var/next_slash_buffed = FALSE
	var/chem_drain = 5

	var/leadership_empowered = FALSE
	var/cooldown_per_slash = 1 SECONDS
	var/actions_affected = list(
		/datum/action/xeno_action/onclick/neurotoxic_slash,
		/datum/action/xeno_action/activable/bounding_slash,
		/datum/action/xeno_action/,
	)

/datum/behavior_delegate/centurion_base/on_life()
	if(check_for_leadership())
		leadership_empowered = TRUE
	else
		leadership_empowered = FALSE

/datum/behavior_delegate/centurion_base/proc/check_for_leadership()
	// We are a Leader, no need to check further
	if(IS_XENO_LEADER(bound_xeno))
		return TRUE

	for(var/mob/living/carbon/xenomorph/xenos in orange(4, bound_xeno))
		// We don't benefit from corpses, keep looking
		if(xenos.stat == DEAD)
			continue
		 // Not one of ours, keep looking
		if(!xenos.hivenumber == bound_xeno.hivenumber)
			continue

		// Found a Leader, no need to check further
		if(IS_XENO_LEADER(xenos))
			leadership_empowered = TRUE
			return TRUE

		// Found an important caste, no need to check further
		if(istype(xenos, /mob/living/carbon/xenomorph/praetorian) || istype(xenos, /mob/living/carbon/xenomorph/queen) || istype(xenos, /mob/living/carbon/xenomorph/king) || istype(xenos, /mob/living/carbon/xenomorph/predalien))
			leadership_empowered = TRUE
			return TRUE

	// None of the above applies, we are not empowered
	return FALSE

/datum/behavior_delegate/centurion_base/melee_attack_modify_damage(original_damage, mob/living/carbon/carbon_target)
	if(!next_slash_buffed)
		return original_damage

	if(!isxeno_human(carbon_target))
		return original_damage

	var/is_stunning = FALSE

	if(carbon_target.slowed)
		is_stunning = TRUE // If target is slowed, stun them

	if(skillcheck(carbon_target, SKILL_ENDURANCE, SKILL_ENDURANCE_MAX) || carbon_target.mob_size >= MOB_SIZE_BIG)
		if(is_stunning) // They can endure stunning, but not slowing
			is_stunning = FALSE
	if(ishuman(carbon_target))
		var/mob/living/carbon/human/human = carbon_target
		if(human.chem_effect_flags & CHEM_EFFECT_RESIST_NEURO || human.species.flags & NO_NEURO)
			human.visible_message(SPAN_DANGER("[human] shrugs off the neurotoxin!"))
			next_slash_buffed = FALSE
			return original_damage // Much like Sent, these guys are just immune

		if(!issynth(carbon_target)) // Drain med chems and stims
			for(var/datum/reagent/generated/stim in human.reagents.reagent_list)
				human.reagents.remove_reagent(stim.id, chem_drain, TRUE)
			for(var/datum/reagent/medical/med in human.reagents.reagent_list)
				human.reagents.remove_reagent(med.id, chem_drain, TRUE)

	if(next_slash_buffed)
		carbon_target.apply_effect(4, DAZE)
		carbon_target.sway_jitter(times = 4, steps = 2)
		next_slash_buffed = FALSE
		if(is_stunning)
			to_chat(bound_xeno, SPAN_XENOHIGHDANGER("We add neurotoxin into our attack, immediately paralyzing the already-slowed [carbon_target]!"))
			to_chat(carbon_target, SPAN_XENOHIGHDANGER("As [bound_xeno] strikes you, your muscles spasm and you collapse!"))
			carbon_target.KnockDown(1.5)
			carbon_target.Stun(1.5)
		else
			to_chat(bound_xeno, SPAN_XENOHIGHDANGER("We add neurotoxin into our attack, slowing [carbon_target]!"))
			to_chat(carbon_target, SPAN_XENOHIGHDANGER("As [bound_xeno] strikes you, you feel sluggish and jittery!"))
			new /datum/effects/xeno_slow(carbon_target, bound_xeno, ttl = get_xeno_stun_duration(carbon_target, 3 SECONDS))

	if(!next_slash_buffed)
		var/datum/action/xeno_action/onclick/neurotoxic_slash/ability = get_action(bound_xeno, /datum/action/xeno_action/onclick/neurotoxic_slash)
		if(ability && istype(ability))
			ability.button.icon_state = "template"
	return original_damage

/datum/behavior_delegate/centurion_base/melee_attack_additional_effects_self()
	if(!leadership_empowered)
		return

	for(var/action_type in actions_affected)
		var/datum/action/xeno_action/xeno_action = get_action(bound_xeno, action_type)
		if(!istype(xeno_action))
			continue
		if(!xeno_action.action_cooldown_check())
			xeno_action.reduce_cooldown(cooldown_per_slash)

/datum/behavior_delegate/centurion_base/override_intent(mob/living/carbon/target_carbon)
	. = ..()

	if(!isxeno_human(target_carbon))
		return

	if(next_slash_buffed)
		return INTENT_HARM

// ABILITIES

/datum/action/xeno_action/onclick/neurotoxic_slash/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/centurion = owner

	if(!action_cooldown_check() || !centurion.check_state())
		return

	if(!check_and_use_plasma_owner())
		return

	var/datum/behavior_delegate/centurion_base/behavior = centurion.behavior_delegate
	if(istype(behavior))
		behavior.next_slash_buffed = TRUE

	to_chat(centurion, SPAN_XENOHIGHDANGER("Our next slash will apply neurotoxin!"))
	button.icon_state = "template_active"

	addtimer(CALLBACK(src, PROC_REF(unbuff_slash)), buff_duration)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/neurotoxic_slash/proc/unbuff_slash()
	var/mob/living/carbon/xenomorph/centurion = owner

	var/datum/behavior_delegate/centurion_base/behavior = centurion.behavior_delegate
	if(istype(behavior))
		if(!behavior.next_slash_buffed)
			return
		behavior.next_slash_buffed = FALSE

	to_chat(centurion, SPAN_XENODANGER("We have waited too long, our slash will no longer apply neurotoxin!"))
	button.icon_state = "template"

/datum/action/xeno_action/activable/bounding_slash/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/centurion = owner

	if(!action_cooldown_check() || !centurion.check_state())
		return

	if(!isturf(centurion.loc))
		to_chat(centurion, SPAN_XENOWARNING("We can't leap from here!"))
		return

	if(get_dist(centurion, target) > max_range)
		return

	if(centurion.legcuffed)
		to_chat(centurion, SPAN_XENODANGER("We can't leap with that thing on our leg!"))
		return

	if(!check_and_use_plasma_owner())
		return

	centurion.throw_atom(get_step_towards(target, centurion), max_range, SPEED_FAST, centurion, pass_flags = PASS_MOB_THRU|PASS_OVER_THROW_MOB, tracking=TRUE)
	var/mob/living/carbon/carbon_target = target
	if(iscarbon(target))
		if(centurion.can_not_harm(carbon_target))
			return

		if(carbon_target.stat == DEAD)
			return

		if(HAS_TRAIT(carbon_target, TRAIT_NESTED) && (carbon_target.status_flags & XENO_HOST))
			return

		if(centurion.Adjacent(carbon_target))
			centurion.animation_attack_on(carbon_target)
			centurion.flick_attack_overlay(carbon_target, "slash")
			playsound(get_turf(carbon_target), "alien_claw_flesh", 30, TRUE)
			carbon_target.apply_armoured_damage(get_xeno_damage_slash(carbon_target, centurion.melee_damage_upper), ARMOR_MELEE, BRUTE)
			centurion.visible_message(SPAN_XENODANGER("[centurion] makes a large bounding leap at [carbon_target], and slashes them!"),\
			SPAN_XENODANGER("We leap at [carbon_target] and slash them!"))

			centurion.add_xeno_shield(shield_on_slash, XENO_SHIELD_SOURCE_CENTURION, add_shield_on = TRUE, max_shield = shield_cap)
			to_chat(centurion, SPAN_XENONOTICE("Our exoskeleton briefly shimmers and strengthens as we slash [carbon_target]!"))
	else
		centurion.visible_message(SPAN_XENODANGER("[centurion] makes a large bounding leap towards [get_turf(target)]!"),\
		SPAN_XENODANGER("We leap towards [get_turf(target)]!"))

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/rallying_roar/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/centurion = owner
	var/datum/behavior_delegate/centurion_base/bedel = centurion.behavior_delegate

	if(!action_cooldown_check() || !centurion.check_state())
		return

	if(!check_and_use_plasma_owner())
		return

	playsound(centurion, 'sound/voice/alien_death_unused.ogg', 100)
	centurion.create_shriekwave(3)
	if(bedel.leadership_empowered)
		centurion.visible_message(SPAN_XENOWARNING("[centurion] lets out a bellowing, commanding roar!"),\
		SPAN_XENOWARNING("Empowered by leadership, we let out a bellowing roar to rally our hive!"))
	else
		centurion.visible_message(SPAN_XENOWARNING("[centurion] lets out a commanding roar!"),\
		SPAN_XENOWARNING("We let out a roar to rally our hive!"))

	for(var/mob/living/carbon/xenomorph/xeno in range(buff_range, centurion))
		if(xeno.stat == DEAD)
			continue

		if(!xeno.hivenumber == centurion.hivenumber)
			continue

		new /datum/effects/xeno_speed(xeno, ttl = buff_durations, set_speed_modifier = speed_buff, set_modifier_source = XENO_CASTE_CENTURION, set_end_message = SPAN_XENONOTICE("We feel our rallying rush wear off..."))
		if(bedel.leadership_empowered)
			new /datum/effects/xeno_slash(xeno, ttl = buff_durations, set_slash_modifier = slash_buff, set_modifier_source = XENO_CASTE_CENTURION, set_end_message = null)

		if(xeno != owner)
			to_chat(xeno, SPAN_XENOWARNING("We hear a rallying cry spurring us to fight harder!"))
		xeno.xeno_jitter(1 SECONDS)

	apply_cooldown()
	return ..()
