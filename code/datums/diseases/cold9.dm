/datum/disease/cold9
	name = "The Cold"
	agent = "ICE9-rhinovirus"
	desc = "If left untreated the subject will slow, as if partly frozen."
	severity = "Moderate"

	max_stages = 3

	cure = "Spaceacillin, Self-resolving"
	cure_id = list("spaceacillin")

	self_curing = TRUE
	self_cure_chance = 5
	self_cure_stages = TRUE

	spread = "On contact"
	spread_type = CONTACT_GENERAL
	affected_species = list("Human")

/datum/disease/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature -= 10
			affected_mob.recalculate_move_delay = TRUE
			if(prob(1) && prob(10))
				to_chat(affected_mob, SPAN_NOTICE("You feel better."))
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Your throat feels sore."))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You feel stiff."))
		if(3)
			affected_mob.bodytemperature -= 20
			affected_mob.recalculate_move_delay = TRUE
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Your throat feels sore."))
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You feel stiff."))
