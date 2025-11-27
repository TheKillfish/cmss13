/datum/disease/reaper_disease

	name = "Reaper Disease"
	form = "Bacterial infection"
	agent = "Clostridium xenothanati"
	severity = "Medium"

	hidden = list(1,0)

	max_stages = 5
	stage_prob = 20 // Not guaranteed to go up in stage immediately, but pretty likely
	stage_minimum_age = 45
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
