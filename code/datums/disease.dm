/*

IMPORTANT NOTE: Please delete the diseases by using cure() proc or del() instruction.
Diseases are referenced in a global list, so simply setting mob or obj vars
to null does not delete the object itself. Thank you.

*/

GLOBAL_LIST_INIT(diseases, typesof(/datum/disease) - /datum/disease)


/datum/disease
	var/name = "No disease"
	var/form = "Virus" // During medscans, what the disease is referred to as
	var/agent = "some microbes"// Name of the disease agent
	var/desc = null // Description. Leave it null and this disease won't show in med records.
	var/severity = null // Severity description

	// If hidden[1] is true, then virus is hidden from medical scanners. If hidden[2] is true, then virus is hidden from PANDEMIC machine.
	var/list/hidden = list(0, 0)

	var/stage = 1 // All diseases start at stage 1
	var/max_stages = 0
	var/stage_prob = 4 // Probability of advancing to next stage, default 4% per check
	var/age = 0 // Age of the disease in the current mob
	var/stage_minimum_age = 0 // How old the disease must be to advance stage
	var/stage_maximum_age = 240 // Ensures the disease goes up in stage once it reaches this point, to curb some of the randomness
	var/aging_variance = STEADY_AGING // How will the disease age? Will it be steady (1 per process) or wild (more than 1 per process)?
	var/duplicates_age_original = FALSE // If infected with a disease you are already infected by, will the existing disease have their age increased
	var/duplicate_age_amount = 1 // Amount the disease ages if aged via duplicate instance of itself

	var/cure = null
	var/cure_id = null // List of reagent.ids that can cure the disease
	var/resistable = TRUE // Do cured mobs gain resistance to this disease?
	var/antibiotic_cure = FALSE // If TRUE, we check chems for PROPERTY_ANTIBIOTIC
	var/antibiotic_strength_needed = 0 // Chems with PROPERTY_ANTIBIOTIC are considered a valid cure if their property strength is equal or greather than this value

	var/stage_curing = TRUE // If TRUE, disease is cured once it reaches a certain stage
	var/stage_cure_stage_threshold = 1 // If the disease stage is equal or less than this value, the disease can be cured
	var/stage_cure_chance = 8 // Chance for the cure to do its job
	var/stage_cure_instadrop = TRUE // If TRUE, immediately drops the stage to 1 rather than go stage-by-stage like diseases of yore did

	var/self_curing = FALSE // If TRUE, disease can cure itself independant of having the cure. This is seperate from stage_curing, but can be made to cure stages too
	var/self_cure_threshold = 1 // If the disease stage is equal or less than this value, the disease can cure itself
	var/self_cure_chance = 1 // Chance for disease to cure itself
	var/self_cure_stages = FALSE // If TRUE, also cures stages

	var/progressional_curing = FALSE // If TRUE, disease is cured over time seperately from stage curing
	var/current_curing_progress = 0
	var/curing_threshold = null // The amount current_curing_progress needs to reach for the disease to be cured
	var/progression_increase = 0 // The amount of cure progression gained over time
	var/prog_gain_rand_min = 0 // Minimum amount of variance in curing progress
	var/prog_gain_rand_max = 0 // Maximum amount of variance in curing progress
	var/lose_progression = FALSE // If TRUE, cure progress is lost when the cure is not present in the body
	var/progression_decrease = 0 // The amount of cure progression lost over time. If you want it to be immediate, just make it more than curing goal
	var/prog_loss_rand_min = 0 // Minimum amount of variance in curing loss
	var/prog_loss_rand_max = 0 // Maximum amount of variance in curing loss

	var/spread = null // Spread type description
	var/initial_spread = null
	var/spread_type = AIRBORNE
	var/contagious_period = 0 // The disease stage when it can be spread
	var/list/affected_species = list()
	var/mob/living/carbon/affected_mob = null // The mob which is affected by disease.
	var/holder = null // The atom containing the disease (mob or obj)
	var/can_carry = TRUE // If the disease allows "carriers"
	var/carrier = 0 // Chance that the person will be a carrier
	var/list/strain_data = list() // This is passed on to infectees
	var/permeability_mod = 1// Permeability modifier coefficient.
	var/survive_mob_death = FALSE // Whether the virus continues processing as normal when the affected mob is dead.
	var/longevity = 150 // Time in "ticks" the virus stays in inanimate object (blood stains, corpses, etc). In syringes, bottles and beakers it stays infinitely.

/datum/disease/New(process = TRUE) // Process = TRUE - Adding the object to global list. List is processed by master controller.
	if(process)  // Diseases in list are considered active.
		SSdisease.all_diseases += src
	initial_spread = spread

/datum/disease/proc/IsSame(datum/disease/disease)
	if(istype(src, disease.type))
		return TRUE
	return FALSE

/datum/disease/proc/Copy(process = TRUE)
	return new type(process)

/datum/disease/Destroy()
	affected_mob = null
	holder = null
	SSdisease.all_diseases -= src
	. = ..()

/datum/disease/proc/stage_act()
	var/cure_present = has_cure()

	// First big-ish thing, increase the age of the disease
	switch(aging_variance)
		if(STEADY_AGING)
			age += 1
		if(LOW_VARIANCE)
			age += rand(1, 3)
		if(MEDIUM_VARIANCE)
			age += rand(1, 5)
		if(HIGH_VARIANCE)
			age += rand(1, 7)
		if(WILD_VARIANCE)
			age += rand(1, 10)

	// If the patient is a carrier and doesn't have the cure in them, don't process further
	if(carrier && !cure_present)
		return

	// Change spread name if the cure is present
	spread = (cure_present ? "Remissive" : initial_spread)

	// Next big-ish thing, check to see if the disease can increase stage. Requires the following:
	// - They don't have a/the cure in them
	// - If applicable, a random chance for success
	// - If applicable, the disease's age to be above a minimum
	if(!cure_present && ((prob(stage_prob) && age > stage_minimum_age) || (age >= stage_maximum_age)))
		stage = min(stage + 1, max_stages)
		age = 0

	// Final big-ish thing, curing methods
	if(cure_present && stage_curing)
		if(stage_cure_instadrop) // For replicating that legacy behavior
			stage = 1
		else
			stage -= 1
		if(stage <= stage_cure_stage_threshold && prob(stage_cure_chance))
			cure(resistable)

	// Progressional curing is a bit more complex than stage_curing, hence why it and stage_curing aren't under the same if statement
	if(progressional_curing)
		// Prevent there being an underflow
		if(current_curing_progress < 0)
			current_curing_progress = 0
		// Check for cure and increase progress
		if(cure_present)
			current_curing_progress += progression_increase + rand(prog_gain_rand_min, prog_gain_rand_max)
		// If the cure isn't present, check if progression can be lost and then decrease
		else if(lose_progression && current_curing_progress > 0)
			current_curing_progress -= progression_decrease + rand(prog_loss_rand_min, prog_loss_rand_max)
		// If we are at or are over the threshold, cure
		if(current_curing_progress >= curing_threshold)
			cure(resistable)

	if(self_curing)
		if(self_cure_stages)
			stage -= 1
		if(stage <= self_cure_threshold && prob(self_cure_chance))
			cure(resistable)

/datum/disease/proc/has_cure()
	if(!cure_id && !antibiotic_cure)
		return FALSE

	var/result = FALSE
	if(antibiotic_cure)
		for(var/datum/reagent/potential_antibiotic in affected_mob.reagents.reagent_list)
			for(var/datum/chem_property/positive/antibiotic/antibio in potential_antibiotic.properties)
				if(antibio.level >= antibiotic_strength_needed)
					result = TRUE
					break

	for(var/C_id in cure_id)
		if(affected_mob.reagents.has_reagent(C_id))
			result = TRUE
			break

	return result

/datum/disease/proc/spread_by_touch()
	switch(spread_type)
		if(CONTACT_FEET, CONTACT_HANDS, CONTACT_GENERAL)
			return TRUE
	return FALSE

/datum/disease/proc/spread(atom/source = null, airborne_range = 2, force_spread)

	// If we're overriding how we spread, say so here
	var/how_spread = spread_type
	if(force_spread)
		how_spread = force_spread

	if(how_spread == SPECIAL || how_spread == NON_CONTAGIOUS || how_spread == BLOOD) // Does not spread
		return FALSE

	if(stage < contagious_period) // The disease is not contagious at this stage
		return FALSE

	if(!source) // No holder specified
		if(affected_mob) // No mob affected holder
			source = affected_mob
		else // No source and no mob affected. Rogue disease. Break
			return FALSE

	var/mob/source_mob = source
	if(istype(source_mob) && !source_mob.can_pass_disease())
		return FALSE

	var/check_range = airborne_range//defaults to airborne - range 2

	if(how_spread != AIRBORNE && how_spread != SPECIAL)
		check_range = 1 // Everything else, like infect-on-contact things, only infect things on top of it

	if(isturf(source.loc))
		FOR_DOVIEW(var/mob/living/carbon/victim, check_range, source, HIDE_INVISIBLE_OBSERVER)
			if(isturf(victim.loc) && victim.can_pass_disease())
				if(AStar(source.loc, victim.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, check_range))
					victim.contract_disease(src, 0, 1, force_spread)
		FOR_DOVIEW_END

	return

/datum/disease/process()
	if(!holder)
		SSdisease.all_diseases -= src
		return

	if(prob(65))
		spread(holder)

	if(affected_mob)
		for(var/datum/disease/disease in affected_mob.viruses)
			if(disease != src)
				if(IsSame(disease))
					if(duplicates_age_original)
						age += duplicate_age_amount
					disease.cure(FALSE) // If there are somehow two viruses of the same kind in the system, delete the other one

	if(holder == affected_mob)
		if((affected_mob.stat != DEAD) || survive_mob_death) // He's alive or disease transcends death
			stage_act()

		else
			if(spread_type != SPECIAL)
				spread_type = CONTACT_GENERAL

	if(!affected_mob || affected_mob.stat == DEAD) // The disease is in inanimate obj or a corpse
		if(prob(70))
			if(--longevity <= 0)
				cure(FALSE)
	return

/datum/disease/proc/cure(resistance = TRUE) // If resistance = FALSE, the mob won't develop resistance to disease
	if(affected_mob)
		if(resistable && resistance && !(type in affected_mob.resistances))
			var/saved_type = "[type]"
			affected_mob.resistances += text2path(saved_type)
		remove_virus()
	qdel(src) // Delete the datum to stop it processing
	return

//unsafe proc, call cure() instead
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		H.med_hud_set_status()
