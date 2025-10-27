/datum/xeno_strain/bastion
	name = CRUSHER_BASTION
	description = "Trade your base abilities and offensive capabilities for true commitment to being a tank; more armor and more health. \
	You become Indomitable, unable to be bodyblocked by anyone except Queens, Kings and other Crushers, and flinging humans to the ground briefly. \
	Head-Crush is a simple melee attack whose damage scales off of your current armor, and can target cades; any cades next to your target get damaged as well. \
	Group Defence allows you to bolster the defences of most of your allies and further bolster your own, gaining 5 armor for every ally within range up to 20 armor. \
	Braced Recovery causes you to accumulate up to 250 damage for 5 seconds, which afterwards is doubled and turned into healing applied over the next 20 seconds. Reach the accumulation limit and Group Defence will recieve a 5 second cooldown reduction if it's on cooldown!"
	flavor_description = "This one shall become the bastion behind which we shall rally"
//	icon_state_prefix = "Bastion"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/crusher_charge,
		/datum/action/xeno_action/onclick/crusher_stomp,
		/datum/action/xeno_action/onclick/crusher_shield,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/head_crush,
		/datum/action/xeno_action/onclick/group_defence,
		/datum/action/xeno_action/onclick/braced_recovery,
	)

	behavior_delegate_type = /datum/behavior_delegate/crusher_bastion

/datum/xeno_strain/bastion/apply_strain(mob/living/carbon/xenomorph/crusher/crusher)
	crusher.damage_modifier -= XENO_DAMAGE_MOD_MED // Dumpstered slash damage
	crusher.health_modifier += XENO_HEALTH_MOD_VERY_LARGE // From 700 to 800
	crusher.armor_modifier += XENO_ARMOR_MOD_SMALL // From 30 to 40
	crusher.speed_modifier += XENO_SPEED_SLOWMOD_TIER_4 // Effectively drops down a tier in speed, since you can fling people by walking into them now
	crusher.recalculate_stats()

/datum/behavior_delegate/crusher_bastion
	name = "Charger Crusher Behavior Delegate"

/datum/behavior_delegate/crusher_bastion/add_to_xeno()
	RegisterSignal(bound_xeno, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(indomitable_movement))

/datum/behavior_delegate/crusher_bastion/proc/indomitable_movement(mob/move_mob, turf/new_loc)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/crusher/crusher = move_mob

	if(crusher.stat == DEAD)
		return

	var/turf/old_loc = get_turf(crusher)
	var/movement_dir = get_dir(old_loc, new_loc)

	for(var/mob/living/carbon/carbon in new_loc.contents)
		if(carbon == crusher)
			continue
		if(carbon.stat == DEAD || carbon.body_position == LYING_DOWN)
			continue
		if(isxeno(carbon))
			if(isqueen(carbon) || isking(carbon) || iscrusher(carbon)) // Cannot shove these guys out the way
				continue
			var/mob/living/carbon/xenomorph/xeno = carbon
			if(HIVE_ALLIED_TO_HIVE(xeno.hivenumber, crusher.hivenumber) && !(crusher.client?.prefs?.toggle_prefs & TOGGLE_AUTO_SHOVE_OFF))
				xeno.KnockDown((5 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
				playsound(crusher, 'sound/weapons/alien_knockdown.ogg', 25, 1)
		else
			INVOKE_ASYNC(carbon, TYPE_PROC_REF(/atom/movable, throw_atom), get_ranged_target_turf(carbon, movement_dir, 1), 1, SPEED_FAST, crusher)
			carbon.KnockDown((5 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
			playsound(crusher, 'sound/weapons/alien_knockdown.ogg', 25, 1)
			carbon.visible_message(SPAN_XENOWARNING("[crusher] harshly shoves [carbon] to the ground as it moves!"), \
			SPAN_XENOWARNING("We harshly shove [carbon] to the ground as we move!"))
			to_chat(carbon, SPAN_XENOHIGHDANGER("[crusher] harshly shoves you to the ground!"))

/datum/action/xeno_action/activable/head_crush/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/head_crusher = owner
	var/mob/living/carbon/carbon = affected_atom

	if(!action_cooldown_check() || !head_crusher.check_state())
		return

	if(!head_crusher.Adjacent(affected_atom))
		return

	if(!check_and_use_plasma_owner())
		return

	head_crusher.face_atom(affected_atom)
	var/armor_scaling_damage = head_crusher.armor_deflection + head_crusher.armor_modifier + head_crusher.armor_deflection_buff - head_crusher.armor_deflection_debuff

	playsound(head_crusher, "slam", 25, 1)
	head_crusher.visible_message(SPAN_XENOWARNING("[head_crusher] rears up and crushes [affected_atom] with a devestating headbutt!"),
	SPAN_XENOWARNING("We rear up and crush [affected_atom] with a devastating headbutt!"))

	if(isxeno_human(carbon))
		if(head_crusher.can_not_harm(carbon) || carbon.stat == DEAD || (HAS_TRAIT(carbon, TRAIT_NESTED)))
			return
		carbon.apply_armoured_damage(get_xeno_damage_slash(carbon, armor_scaling_damage), ARMOR_MELEE, BRUTE)

	else if(istype(affected_atom, /obj/structure/barricade))
		var/obj/structure/barricade/cade = affected_atom
		for(var/obj/structure/barricade/nearby_cades in orange(1, cade))
			nearby_cades.take_damage(armor_scaling_damage * (cade_damage_multiplier / 2))
			nearby_cades.visible_message(SPAN_XENOWARNING("[nearby_cades] buckles under the shock from the headbutt!"))
		cade.take_damage(armor_scaling_damage * cade_damage_multiplier)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/group_defence/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/bastion = owner

	if(!action_cooldown_check() || !bastion.check_state())
		return

	if(!check_and_use_plasma_owner())
		return

	var/list/tracked_xenos = list()

	for(var/mob/living/carbon/xenomorph/xeno_in_aoe in view(aoe_range, bastion))
		if(xeno_in_aoe == bastion)
			continue
		if(xeno_in_aoe.stat == DEAD)
			continue
		if(xeno_in_aoe.hivenumber != bastion.hivenumber)
			continue
		if(xeno_in_aoe in tracked_xenos)
			continue

		tracked_xenos.Add(xeno_in_aoe)
		apply_group_defence_others_buffs(xeno_in_aoe)
		xeno_in_aoe.xeno_jitter(1 SECONDS)

	var/armor_gained = length(tracked_xenos) * armor_recieved_per_ally
	if(armor_gained > max_armor_recieved)
		armor_gained = max_armor_recieved

	var/explosivearmor_gained = length(tracked_xenos) * explosivearmor_recieved_per_ally
	if(explosivearmor_gained > max_explosivearmor_recieved)
		explosivearmor_gained = max_explosivearmor_recieved

	if(length(tracked_xenos) == 0)
		armor_gained = 5
		explosivearmor_gained = 10

	apply_group_defence_self_buffs(bastion, armor_gained, explosivearmor_gained)
	bastion.xeno_jitter(1 SECONDS)
	playsound(bastion, "alien_drool", 25)

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/group_defence/proc/apply_group_defence_self_buffs(mob/living/carbon/xenomorph/bastion, armor_gained, explosivearmor_gained)
	bastion.armor_modifier += armor_gained
	bastion.explosivearmor_modifier += explosivearmor_gained
	bastion.recalculate_stats()
	bastion.visible_message(SPAN_XENOWARNING("[bastion] emits a burst of strange-smelling pheremones as its carapace visibly hardens!"), \
	SPAN_XENOWARNING("We release a burst special pheremones, hardening our own carapace and those of our sisters!"))

	addtimer(CALLBACK(src, PROC_REF(remove_self_buffs), bastion, armor_gained, explosivearmor_gained), buff_duration)

/datum/action/xeno_action/onclick/group_defence/proc/remove_self_buffs(mob/living/carbon/xenomorph/bastion, armor_gained, explosivearmor_gained)
	bastion.armor_modifier -= armor_gained
	bastion.explosivearmor_modifier -= explosivearmor_gained
	bastion.recalculate_stats()
	to_chat(bastion, SPAN_XENOWARNING("We feel our pheremone-hardened carapace return to normal!"))

/datum/action/xeno_action/onclick/group_defence/proc/apply_group_defence_others_buffs(mob/living/carbon/xenomorph/allied_xeno)
	var/armor_to_give = 0
	var/explosivearmor_to_give = 0

	switch(allied_xeno.caste_type)
		// T0 - Not intended for combat or intended to be disposable, just return
		if(XENO_CASTE_LARVA)
			return
		if(XENO_CASTE_PREDALIEN_LARVA)
			return
		if(XENO_CASTE_FACEHUGGER)
			return
		if(XENO_CASTE_LESSER_DRONE)
			return

		// T1 - Overall no armor, so they actually get stuff
		if(XENO_CASTE_DRONE)
			armor_to_give = 15
			explosivearmor_to_give = 20
		if(XENO_CASTE_RUNNER)
			armor_to_give = 10
			explosivearmor_to_give = 20
		if(XENO_CASTE_SENTINEL)
			armor_to_give = 15
			explosivearmor_to_give = 20
		if(XENO_CASTE_DEFENDER)
			armor_to_give = 0
			explosivearmor_to_give = 10

		// T2 - Starting to see armor or ones oppressive enough in combat
		if(XENO_CASTE_BURROWER)
			armor_to_give = 5
			explosivearmor_to_give = 20
		if(XENO_CASTE_CARRIER)
			armor_to_give = 15
			explosivearmor_to_give = 20
		if(XENO_CASTE_HIVELORD)
			armor_to_give = 15
			explosivearmor_to_give = 20
		if(XENO_CASTE_LURKER)
			armor_to_give = 5
			explosivearmor_to_give = 10
		if(XENO_CASTE_WARRIOR)
			armor_to_give = 5
			explosivearmor_to_give = 10
		if(XENO_CASTE_SPITTER)
			armor_to_give = 10
			explosivearmor_to_give = 20

		// T3 - High armor and combat castes, they either get nothing or get little
		if(XENO_CASTE_BOILER)
			armor_to_give = 5
			explosivearmor_to_give = 20
		if(XENO_CASTE_PRAETORIAN)
			armor_to_give = 5
			explosivearmor_to_give = 0
		if(XENO_CASTE_CRUSHER)
			armor_to_give = 0
			explosivearmor_to_give = 0
		if(XENO_CASTE_RAVAGER)
			armor_to_give = 0
			explosivearmor_to_give = 0

		// T4 - Looping back to just returning as they're strong enough
		if(XENO_CASTE_PREDALIEN)
			return
		if(XENO_CASTE_QUEEN)
			return
		if(XENO_CASTE_KING)
			return

	allied_xeno.armor_modifier += armor_to_give
	allied_xeno.explosivearmor_modifier += explosivearmor_to_give
	allied_xeno.recalculate_stats()
	to_chat(allied_xeno, SPAN_XENOWARNING("We feel our carapace harden from special pheremones!"))

	addtimer(CALLBACK(src, PROC_REF(remove_others_buffs), allied_xeno, armor_to_give, explosivearmor_to_give), buff_duration)

/datum/action/xeno_action/onclick/group_defence/proc/remove_others_buffs(mob/living/carbon/xenomorph/allied_xeno, armor_to_give, explosivearmor_to_give)
	allied_xeno.armor_modifier -= armor_to_give
	allied_xeno.explosivearmor_modifier -= explosivearmor_to_give
	allied_xeno.recalculate_stats()
	to_chat(allied_xeno, SPAN_XENOWARNING("We feel our pheremone-hardened carapace return to normal!"))

/datum/action/xeno_action/onclick/braced_recovery/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/braced_user = owner

	if(!action_cooldown_check() || !braced_user.check_state())
		return

	if(!check_and_use_plasma_owner())
		return

	RegisterSignal(braced_user, COMSIG_XENO_TAKE_DAMAGE, PROC_REF(start_bracing))
	addtimer(CALLBACK(src, PROC_REF(bracing_aftereffects), braced_user), 6 SECONDS)

	to_chat(braced_user, SPAN_XENONOTICE("We brace ourselves for incoming damage!"))

	braced_user.add_filter("bastion_braced", 1, list("type" = "outline", "color" = "#02755c", "size" = 1))

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/braced_recovery/proc/start_bracing(owner, damage_data, damage_type)
	SIGNAL_HANDLER

	damage_accumulated += damage_data["damage"]
	if(damage_accumulated > max_damage_accumulated)
		damage_accumulated = max_damage_accumulated

/datum/action/xeno_action/onclick/braced_recovery/proc/bracing_aftereffects(mob/living/carbon/xenomorph/braced_user)
	UnregisterSignal(braced_user, COMSIG_XENO_TAKE_DAMAGE)

	var/brace_message = "We finish bracing ourself, the damage endured stimulating our natural recovery!"
	var/datum/action/xeno_action/onclick/group_defence/group_def_action = locate() in braced_user.actions
	if(damage_accumulated == max_damage_accumulated && group_def_action && !group_def_action.action_cooldown_check())
		brace_message += " We feel our body hasten it's creation of special carapace-hardening pheremones!"
		group_def_action.reduce_cooldown(group_def_cooldown_reduction)

	braced_user.remove_filter("bastion_braced")
	new /datum/effects/heal_over_time(braced_user, round(damage_accumulated * 2, 1), heal_duration) // Slow healing (over 20 seconds) but capacity to heal a lot (500 health)
	braced_user.xeno_jitter(1 SECONDS)
	braced_user.flick_heal_overlay(heal_duration, "#02755c")
	to_chat(braced_user, SPAN_XENONOTICE("[brace_message]"))
