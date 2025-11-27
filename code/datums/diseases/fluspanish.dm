/datum/disease/fluspanish
	name = "Spanish inquisition Flu"
	agent = "1nqu1s1t10n flu virion"
	desc = "If left untreated the subject will burn to death for being a heretic."
	severity = "Serious"

	max_stages = 3

	cure = "Spaceacillin & Anti-bodies to the common flu"
	cure_id = list("spaceacillin")

	stage_cure_chance = 10

	self_curing = TRUE

	spread = "Airborne"
	affected_species = list("Human")
	permeability_mod = 0.75

/datum/disease/inquisition/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature += 10
			affected_mob.recalculate_move_delay = TRUE
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("You're burning in your own skin!"))
				affected_mob.take_limb_damage(0,5)

		if(3)
			affected_mob.bodytemperature += 20
			affected_mob.recalculate_move_delay = TRUE
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You're burning in your own skin!"))
				affected_mob.take_limb_damage(0,5)
	return
