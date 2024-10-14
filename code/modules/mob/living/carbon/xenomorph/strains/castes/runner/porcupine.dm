/datum/xeno_strain/porcupine
	name = RUNNER_PORCUPINE
	description = "Lose all your base abilities in exchange for a smidgen of extra health, a bit of armor and ranged attacks. You gain bonus armor that scales off your shard count, however it also slows you down further. You gain shards over time and when taking damage. "
	flavor_description = ""
	//icon_state_prefix = "Porcupine"

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
		/datum/action/xeno_action/onclick/toggle_long_range/runner,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/porcupine_shot,
	)

	behavior_delegate_type = /datum/behavior_delegate/runner_porcupine

/datum/xeno_strain/porcupine/apply_strain(mob/living/carbon/xenomorph/runner/runner)
	runner.armor_modifier += XENO_ARMOR_MOD_SMALL
	runner.health_modifier += XENO_HEALTH_MOD_VERY_SMALL

	runner.recalculate_everything()

/datum/behavior_delegate/runner_porcupine
	name = "Porcupine Runner Behavior Delegate"

	var/max_shards = 300
	var/shard_gain_onlife = 5
	var/shards_per_projectile = 10
	var/armor_per_fifty_shards = 2.50
	var/speed_per_fifty_shards = 0.25

	// Shard state
	var/shards = 0
	var/shards_locked = FALSE
	var/shard_lock_duration = 100

	// Armor buff state
	var/times_armor_buffed = 0
	// Speed debuff state
	var/times_speed_debuffed = 0

/datum/behavior_delegate/runner_porcupine/append_to_stat()
	. = list()
	. += "Bone Shards: [shards]/[max_shards]"
	. += "Shards Armor Bonus: [times_armor_buffed*armor_per_fifty_shards]"

/datum/behavior_delegate/runner_porcupine/proc/lock_shards()

	if(!bound_xeno)
		return

	to_chat(bound_xeno, SPAN_XENODANGER("You have shed your spikes and cannot gain any more for [shard_lock_duration/10] seconds!"))

	shards = 0
	shards_locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(unlock_shards)), shard_lock_duration)

/datum/behavior_delegate/runner_porcupine/proc/unlock_shards()

	if(!bound_xeno)
		return

	to_chat(bound_xeno, SPAN_XENODANGER("You feel your ability to gather shards return!"))

	shards_locked = FALSE

/datum/behavior_delegate/runner_porcupine/proc/check_shards(amount)
	if(!amount)
		return FALSE
	else
		return (shards >= amount)

/datum/behavior_delegate/runner_porcupine/proc/use_shards(amount)
	if(!amount)
		return
	shards = max(0, shards - amount)

/datum/behavior_delegate/runner_porcupine/on_life()

	if(!shards_locked)
		shards = min(max_shards, shards + shard_gain_onlife)

	var/stat_count = shards/50
	// Armor
	bound_xeno.armor_modifier -= times_armor_buffed * armor_per_fifty_shards
	bound_xeno.armor_modifier += stat_count * armor_per_fifty_shards
	bound_xeno.recalculate_armor()
	times_armor_buffed = stat_count
	// Speed
	bound_xeno.speed_modifier -= times_speed_debuffed * speed_per_fifty_shards
	bound_xeno.speed_modifier += stat_count * speed_per_fifty_shards
	bound_xeno.recalculate_speed()
	times_speed_debuffed = stat_count

	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()
	var/percentage_shards = round((shards / max_shards) * 100, 10)
	if(percentage_shards)
		holder.overlays += image('icons/mob/hud/hud.dmi', "xenoenergy[percentage_shards]")

	return


/datum/behavior_delegate/runner_porcupine/handle_death(mob/M)
	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()

/datum/behavior_delegate/runner_porcupine/on_hitby_projectile()
	if(!shards_locked)
		shards = min(max_shards, shards + shards_per_projectile)
	return
