//Disease Datum
#define ZOMBIE_INFECTION_STAGE_ONE 1
#define ZOMBIE_INFECTION_STAGE_TWO 2
#define ZOMBIE_INFECTION_STAGE_THREE 3
#define ZOMBIE_INFECTION_STAGE_FOUR 4
#define SLOW_INFECTION_RATE 1
#define FAST_INFECTION_RATE 7
#define STAGE_LEVEL_THRESHOLD 360
#define MESSAGE_COOLDOWN_TIME 1 MINUTES

/datum/disease/reaper_disease
	name = "Reaper Disease"
	form = "Bacterial infection"
	agent = "Clostridium xenothanati"

	hidden = list(1,0)

	max_stages = 4
	cure = "Hadepenem"
	cure_id = list("hadepenem")
	spread = "Bites"
	spread_type = SPECIAL
	affected_species = list("Human")
	cure_chance = 100 //meaning the cure will kill the virus asap
	severity = "Medium"
	permeability_mod = 2
	survive_mob_death = TRUE
	longevity = 500
	stage_prob = 0

	/// boolean value to determine if the mob is currently transforming into a zombie.
	var/zombie_is_transforming = FALSE

	/// variable to keep track of the stage level, used to prevent the stage message from being displayed more than once for any given stage.
	var/stage_counter = 0

//new variables to handle infection progression inside a stage.

	/// variable that contains accumulated virus progression for a host. Iterates to a value above 360 and is then reset.
	var/stage_level = 0

	/// variable that handles passive increase of the virus of a host.
	var/infection_rate = SLOW_INFECTION_RATE

	/// cooldown for the living mob's symptom messages
	COOLDOWN_DECLARE(goo_message_cooldown)

/datum/disease/reaper_disease/stage_act()
	..()
	if(!ishuman_strict(affected_mob))
		return
	var/mob/living/carbon/human/infected_mob = affected_mob

	if(iszombie(infected_mob))
		return

	// infection rate is faster for dead mobs
	if(infected_mob.stat == DEAD)
		infection_rate = FAST_INFECTION_RATE

	// standard infection rate for living mobs
	if(infected_mob.stat != DEAD)
		infection_rate = SLOW_INFECTION_RATE

	stage_level += infection_rate

	// resets the stage_level once it passes the threshold.
	if(stage_level >= STAGE_LEVEL_THRESHOLD)
		stage++
		stage_level = stage_level % STAGE_LEVEL_THRESHOLD

	switch(stage)
		if(ZOMBIE_INFECTION_STAGE_ONE)
			if(infected_mob.stat == DEAD && stage_counter != stage)
				to_chat(infected_mob, SPAN_CENTERBOLD("Your zombie infection is now at stage one! Zombie transformation begins at stage three."))
				stage_counter = stage

			// dead mobs should not have symptoms, because... they are dead.
			if(infected_mob.stat != DEAD)
				if (!COOLDOWN_FINISHED(src, goo_message_cooldown))
					return
				COOLDOWN_START(src, goo_message_cooldown, MESSAGE_COOLDOWN_TIME)

				switch(rand(0, 100))
					if(0 to 25)
						return
					if(25 to 75)
						to_chat(infected_mob, SPAN_DANGER("You feel warm..."))
						stage_level += 9
					if(75 to 95)
						to_chat(infected_mob, SPAN_DANGER("Your throat is really dry..."))
						stage_level += 18
					if(95 to 100)
						to_chat(infected_mob, SPAN_DANGER("You can't trust them..."))
						stage_level += 36

		if(ZOMBIE_INFECTION_STAGE_TWO)
			if(infected_mob.stat == DEAD && stage_counter != stage)
				to_chat(infected_mob, SPAN_CENTERBOLD("Your zombie infection is now at stage two! Zombie transformation begins at stage three."))
				stage_counter = stage

			if(infected_mob.stat != DEAD)
				if (!COOLDOWN_FINISHED(src, goo_message_cooldown))
					return
				COOLDOWN_START(src, goo_message_cooldown, MESSAGE_COOLDOWN_TIME)

				switch(rand(0, 100))
					if(0 to 25)
						return
					if(25 to 50)
						to_chat(infected_mob, SPAN_DANGER("You can't trust them..."))
						stage_level += 5
					if(50 to 75)
						to_chat(infected_mob, SPAN_DANGER("You feel really warm..."))
						stage_level += 9
					if(75 to 85)
						to_chat(infected_mob, SPAN_DANGER("Your throat is really dry..."))
						stage_level += 18
					if(85 to 95)
						infected_mob.vomit_on_floor()
						stage_level += 36
					if(95 to 100)
						to_chat(infected_mob, SPAN_DANGER("You cough up some black fluid..."))
						stage_level += 42

		if(ZOMBIE_INFECTION_STAGE_THREE)
			// if zombie or transforming we upgrade it to stage four.
			if(iszombie(infected_mob))
				stage++
				return
			// if not a zombie(above check) and isn't transforming then we transform you into a zombie.
			if(!zombie_is_transforming)
				// if your dead we inform you that you're going to turn into a zombie.
				if(infected_mob.stat == DEAD && stage_counter != stage)
					to_chat(infected_mob, SPAN_CENTERBOLD("Your zombie infection is now at stage three! Zombie transformation begin!"))
					stage_counter = stage
				hidden = list(0,0)
				infected_mob.next_move_slowdown = max(infected_mob.next_move_slowdown, 2)

		if(ZOMBIE_INFECTION_STAGE_FOUR)
			return
			// final stage of infection it's to avoid running the above test once you're a zombie for now. maybe more later.

#undef ZOMBIE_INFECTION_STAGE_ONE
#undef ZOMBIE_INFECTION_STAGE_TWO
#undef ZOMBIE_INFECTION_STAGE_THREE
#undef ZOMBIE_INFECTION_STAGE_FOUR
#undef STAGE_LEVEL_THRESHOLD
#undef SLOW_INFECTION_RATE
#undef FAST_INFECTION_RATE
#undef MESSAGE_COOLDOWN_TIME
