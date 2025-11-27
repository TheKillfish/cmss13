/datum/disease/cold
	name = "The Cold"
	agent = "XY-rhinovirus"
	desc = "If left untreated the subject will contract the flu."
	severity = "Minor"

	max_stages = 3

	cure = "Spaceacillin, Self-resolving"
	cure_id = list("spaceacillin")

	self_curing = TRUE
	self_cure_chance = 5
	self_cure_stages = TRUE

	spread = "Airborne"
	affected_species = list("Human", "Monkey")
	permeability_mod = 0.5


/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
/*
			if(affected_mob.sleeping && prob(40))  //removed until sleeping is fixed
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
*/
			if(affected_mob.body_position == LYING_DOWN && prob(40))  //changed FROM prob(10) until sleeping is fixed
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
			if(prob(1) && prob(5))
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Your throat feels sore."))
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Mucous runs down the back of your throat."))
		if(3)
/*
			if(affected_mob.sleeping && prob(25))  //removed until sleeping is fixed
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
*/
			if(affected_mob.body_position == LYING_DOWN && prob(25))  //changed FROM prob(5) until sleeping is fixed
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
			if(prob(1) && prob(1))
				to_chat(affected_mob, SPAN_NOTICE(" You feel better."))
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Your throat feels sore."))
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Mucous runs down the back of your throat."))
			if(prob(1) && prob(50))
				if(!affected_mob.resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu(0)
					affected_mob.contract_disease(Flu,1)
					cure()
