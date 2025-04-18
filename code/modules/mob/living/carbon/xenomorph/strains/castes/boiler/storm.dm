/datum/xeno_strain/storm
	name = BOILER_STORM
	description = ""
	flavor_description = "Ride the thunder."

	actions_to_remove = list(
		/datum/action/xeno_action/activable/xeno_spit/bombard,
		/datum/action/xeno_action/onclick/shift_spits/boiler,
		/datum/action/xeno_action/activable/spray_acid/boiler,
		/datum/action/xeno_action/onclick/toggle_long_range/boiler,
		/datum/action/xeno_action/onclick/acid_shroud,
	)
	actions_to_add = list(

	)

	behavior_delegate_type = /datum/behavior_delegate/boiler_storm

/datum/xeno_strain/storm/apply_strain(mob/living/carbon/xenomorph/boiler/boiler)
	if(!istype(boiler))
		return FALSE

	if(boiler.is_zoomed)
		boiler.zoom_out()

	boiler.tileoffset = 0
	boiler.viewsize = TRAPPER_VIEWRANGE
	boiler.plasma_types -= PLASMA_NEUROTOXIN
	boiler.ammo = GLOB.ammo_list[boiler.caste.spit_types[1]]
	ADD_TRAIT(boiler, TRAIT_SHOCKPROOF, TRAIT_SOURCE_STRAIN)

	boiler.recalculate_everything()

/datum/behavior_delegate/boiler_storm
	name = "Boiler Storm Behavior Delegate"
