/datum/disease/brainrot
	name = "Brainrot"
	agent = "Cryptococcus Cosmosis"
	desc = "This disease destroys the braincells, causing brain fever, brain necrosis and general intoxication."
	severity = "Major"

	max_stages = 4

	cure = "Alkysine"
	cure_id = list("alkysine")

	stage_cure_chance = 15

	spread = "On contact"
	spread_type = CONTACT_GENERAL
	affected_species = list("Human")

/datum/disease/brainrot/stage_act() //Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("Your don't feel like yourself."))
			if(prob(5))
				affected_mob.adjustBrainLoss(1)
				affected_mob.updatehealth()
		if(3)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10) && affected_mob.getBrainLoss()<=98)//shouldn't retard you to death now
				affected_mob.adjustBrainLoss(2)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, SPAN_DANGER("Your try to remember something important...but can't."))
/* if(prob(10))
				affected_mob.apply_damage(3, TOX)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, SPAN_DANGER("Your head hurts.")) */
		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
/* if(prob(15))
				affected_mob.apply_damage(4, TOX)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, SPAN_DANGER("Your head hurts.")) */
			if(prob(15) && affected_mob.getBrainLoss()<=98) //shouldn't retard you to death now
				affected_mob.adjustBrainLoss(3)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, SPAN_DANGER("Strange buzzing fills your head, removing all thoughts."))
			if(prob(3))
				to_chat(affected_mob, SPAN_DANGER("You lose consciousness..."))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message("[affected_mob] suddenly collapses", SHOW_MESSAGE_VISIBLE)
				affected_mob.apply_effect(rand(5,10), PARALYZE)
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.stuttering += 3
	return
