/datum/disease/fake_gbs
	name = "GBS"
	agent = "Gravitokinetic Bipotential SADS-"
	desc = "If left untreated death will occur."
	severity = "Major"

	max_stages = 5

	cure = "Sulfur"
	cure_id = list("sulfur")

	spread = "On contact"
	spread_type = CONTACT_GENERAL
	affected_species = list("Human", "Monkey")

/datum/disease/fake_gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You're starting to feel very weak..."))
		if(4)
			if(prob(10))
				affected_mob.emote("cough")

		if(5)
			if(prob(10))
				affected_mob.emote("cough")
