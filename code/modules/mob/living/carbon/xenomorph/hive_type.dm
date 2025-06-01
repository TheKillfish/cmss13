// Hive type is basically everything to do with what kinds of Xenomorph a hive has/is. For instance:
// Our standard ol' Xenomorphs would belong to the "Classic Xenomorphs" Hive Type (classic in the sense it's the Xenos everyone are familiar with)
// This datum contains the data on how they propagate (if they can), what castes are avaliable, and defines any important/vital castes (aka Queen)
// This is not the same as the details of Hive Status, although some things will be moved from there to here (such as always free slots)

/datum/hive_type
	var/name = ""

	var/avaliable_castes = list()
	var/reliant_on_special_caste = TRUE

/datum/hive_type/classic
	name = "Classic Xenomorphs"

	reproduces = TRUE
	hiveleader_dependant = TRUE
	hiveleader_type = /mob/living/carbon/xenomorph/queen
	hiveleader_max = 1

	avaliable_castes = list(
		// Tier 0
		/mob/living/carbon/xenomorph/lesser_drone,
		/mob/living/carbon/xenomorph/facehugger,
		/mob/living/carbon/xenomorph/larva,
		// Tier 1
		/mob/living/carbon/xenomorph/drone,
		/mob/living/carbon/xenomorph/runner,
		/mob/living/carbon/xenomorph/defender,
		/mob/living/carbon/xenomorph/sentinel,
		// Tier 2
		/mob/living/carbon/xenomorph/hivelord,
		/mob/living/carbon/xenomorph/carrier,
		/mob/living/carbon/xenomorph/burrower,
		/mob/living/carbon/xenomorph/lurker,
		/mob/living/carbon/xenomorph/warrior,
		/mob/living/carbon/xenomorph/spitter,
		// Tier 3
		/mob/living/carbon/xenomorph/ravager,
		/mob/living/carbon/xenomorph/crusher,
		/mob/living/carbon/xenomorph/boiler,
		/mob/living/carbon/xenomorph/praetorian,
		// Tier 4
		/mob/living/carbon/xenomorph/predalien,
		/mob/living/carbon/xenomorph/queen,
		/mob/living/carbon/xenomorph/king,
	)

	free_slots = list(
		/datum/caste_datum/burrower = 1,
		/datum/caste_datum/hivelord = 1,
		/datum/caste_datum/carrier = 1
	)
