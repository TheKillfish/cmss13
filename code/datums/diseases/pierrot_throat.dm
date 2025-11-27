/datum/disease/pierrot_throat
	name = "Pierrot's Throat"
	agent = "H0NI<42 Virus"
	desc = "If left untreated the subject will probably drive others to insanity."
	severity = "Medium"

	max_stages = 4
	stage_minimum_age = 100

	cure = "A whole banana."
	cure_id = list("banana")

	stage_cure_chance = 75

	spread = "Airborne"
	affected_species = list("Human")
	permeability_mod = 0.75
	longevity = 400

/datum/disease/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You feel a little silly."))
		if(2)
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You start seeing rainbows."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("Your thoughts are interrupted by a loud <b>HONK!</b>"))
		if(4)
			if(prob(5))
				affected_mob.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ) )
