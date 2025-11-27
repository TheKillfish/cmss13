/datum/disease/reaper_disease

	name = "Reaper Disease"
	form = "Bacterial infection"
	agent = "Clostridium xenothanati"
	severity = "Medium"

	hidden = list(1,0)

	max_stages = 5
	stage_prob = 10 // Decent chance to go up in stage
	stage_minimum_age = 90
	aging_variance = MEDIUM_VARIANCE
	duplicates_age_original = TRUE // Fighting Reaper means lots of infections, lots of infections means more rapid aging disease
	duplicate_age_amount = 10 // Substantially more rapid aging

	resistable = FALSE // No immunity once you've been cured, especially since it cures itself at stage 5 (after dumping a shitload of toxins in you)
	antibiotic_cure = TRUE // It is a bacterium, so antibiotics work
	antibiotic_strength_needed = 1 // This will be increased around stage 4, so you need to use Hadepenem to cure

	stage_curing = FALSE

	progressional_curing = TRUE
	curing_threshold = 240
	progression_increase = 2 // By default, 2 minute cure time
	prog_gain_rand_min = 2 // At absolute best when RNGesus smiles upon you, 1 minute cure time
	prog_gain_rand_max = -1 // At absolute worst when RNGsus decides he hates you, 4 minute cure time
	lose_progression = TRUE // A little bit of extra encouragement to not just run off before you know you are cured
	progression_decrease = 1 // Pretty slow loss of cure progression though

	spread_type = BLOOD // Might not be the best idea to give blood transfusions if infected, unlikely as they are to ever happen
	affected_species = list("Human") // Mayhaps I will be funny and let Xenos be afflicted later too, we'll see
	longevity = 500 // 500 ticks, so death is no get-out-of-jail-free card unless CPR'd

	var/sepsicine_amount = 5
	COOLDOWN_DECLARE(reaper_disease_message_cooldown)

/datum/disease/reaper_disease/stage_act()
	..()

	if(!ishuman_strict(affected_mob))
		return

	switch(stage)
		if(1) // First stage does no toxin damage, adds extra cure progression when being treated to represent it being rather easy to cure
			if(affected_mob.stat != DEAD)
				if(COOLDOWN_FINISHED(src, reaper_disease_message_cooldown))
					switch(rand(0, 100))
						if(0 to 33)
							to_chat(affected_mob, SPAN_DANGER("You feel a little bit sick..."))
						if(34 to 66)
							to_chat(affected_mob, SPAN_DANGER("You don't feel quite right..."))
						if(67 to 100)
							to_chat(affected_mob, SPAN_DANGER("You feel a strange tingling sensation..."))
					COOLDOWN_START(src, reaper_disease_message_cooldown, 25 SECONDS)

				// Antibiotics can cure this pretty easily
				if(has_cure())
					var/antibio_mult
					for(var/datum/reagent/potential_antibiotic in affected_mob.reagents.reagent_list)
						for(var/datum/chem_property/positive/antibiotic/antibio in potential_antibiotic.properties)
							antibio_mult = antibio.level
					current_curing_progress += progression_increase * antibio_mult

		if(2) // Second stage does minor toxin damage, no other effects
			if(affected_mob.stat != DEAD)
				if(COOLDOWN_FINISHED(src, reaper_disease_message_cooldown))
					switch(rand(0, 100))
						if(0 to 33)
							to_chat(affected_mob, SPAN_DANGER("You feel a little bit tired..."))
						if(34 to 66)
							affected_mob.emote("cough")
						if(67 to 100)
							to_chat(affected_mob, SPAN_DANGER("You aren't feeling your best..."))
					COOLDOWN_START(src, reaper_disease_message_cooldown, 25 SECONDS)

				affected_mob.apply_damage(0.1, TOX)

		if(3) // Third stage does ever so slightly higher toxin damage, removes cure progression when being treated with Strength 1 Antibiotics to represent it being harder to cure
			if(affected_mob.stat != DEAD)
				if(COOLDOWN_FINISHED(src, reaper_disease_message_cooldown))
					switch(rand(0, 100))
						if(0 to 33)
							to_chat(affected_mob, SPAN_DANGER("You feel pretty sick."))
						if(34 to 66)
							affected_mob.emote("cough")
						if(67 to 100)
							to_chat(affected_mob, SPAN_DANGER("Your body tingles unpleasantly."))
					COOLDOWN_START(src, reaper_disease_message_cooldown, 25 SECONDS)

				affected_mob.apply_damage(0.2, TOX)

				if(has_cure())
					for(var/datum/reagent/potential_antibiotic in affected_mob.reagents.reagent_list)
						for(var/datum/chem_property/positive/antibiotic/antibio in potential_antibiotic.properties)
							if(antibio.level < 3) // Stuff other than Hadepenem is rather ineffective at this stage
								current_curing_progress -= (progression_increase * 2) / antibio.level
							else // But Hadepenem still has an easier time
								current_curing_progress += progression_increase

		if(4) // Fourth stage suddenly stops doing damage, ups antibiotic_strength_needed to 3; you are close to the rubicon and need Hadepenem
			antibiotic_strength_needed = 3

			if(affected_mob.stat != DEAD)
				if(COOLDOWN_FINISHED(src, reaper_disease_message_cooldown))
					switch(rand(0, 100))
						if(0 to 50)
							to_chat(affected_mob, SPAN_DANGER("You suddenly don't feel as sick..."))
						if(50 to 100)
							to_chat(affected_mob, SPAN_DANGER("You feel a bit better, but something feels wrong..."))
					COOLDOWN_START(src, reaper_disease_message_cooldown, 30 SECONDS)

		if(5) // Fifth stage dumps hefty chunks of toxin and brute damage, some Sepsicine, then cures itself; Death will surely follow soon unless you have godly healing meds in you
			affected_mob.apply_damage(30, TOX)
			affected_mob.apply_damage(45, BRUTE)
			affected_mob.reagents.add_reagent("sepsicine", sepsicine_amount)
			affected_mob.reagents.set_source_mob(src, /datum/reagent/toxin/sepsicine)
			to_chat(affected_mob, SPAN_HIGHDANGER("You feel pain erupt throughout your body!"))
			cure()
