/obj/item/device/radio/deciever
	name = "Hertzian Sensor Organ"
	desc = "A strange organ from a Xenomorph used to listen to radios. You shouldn't be seeing this, so please file an issue!"
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "heart_t1"
	item_state = "heart_t1"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items/organs_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items/organs_righthand.dmi',
	)

	frequency = COLONY_FREQ
	subspace_transmission = TRUE
	canhear_range = 0
	broadcasting = FALSE
	listening = FALSE

	emp_proof = TRUE
	flags_equip_slot = null

	var/mob/living/carbon/xenomorph/tapping_xeno
