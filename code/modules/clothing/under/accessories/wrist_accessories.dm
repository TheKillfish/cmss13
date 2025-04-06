/obj/item/clothing/accessory/wrist
	name = "bracelet"
	desc = "A simple bracelet made from a strip of fabric."
	icon = 'icons/obj/items/clothing/accessory/wrist_accessories.dmi'
	icon_state = "bracelet"
	inv_overlay_icon = null
	slot = ACCESSORY_SLOT_WRIST_L
	var/which_wrist = "left wrist"

/obj/item/clothing/accessory/wrist/get_examine_text(mob/user)
	. = ..()

	switch(slot)
		if(ACCESSORY_SLOT_WRIST_L)
			which_wrist = "left wrist"
		if(ACCESSORY_SLOT_WRIST_R)
			which_wrist = "right wrist"
	. += "It will be worn on the [which_wrist]."

/obj/item/clothing/accessory/wrist/additional_examine_text()
	return "on the [which_wrist]."

/obj/item/clothing/accessory/wrist/attack_self(mob/user)
	..()

	switch(slot)
		if(ACCESSORY_SLOT_WRIST_L)
			slot = ACCESSORY_SLOT_WRIST_R
			to_chat(user, SPAN_NOTICE("[src] will be worn on the right wrist."))
		if(ACCESSORY_SLOT_WRIST_R)
			slot = ACCESSORY_SLOT_WRIST_L
			to_chat(user, SPAN_NOTICE("[src] will be worn on the left wrist."))

/obj/item/clothing/accessory/wrist/watch
	name = "digital wrist watch"
	desc = "A cheap 24-hour only digital wrist watch. It has a crappy red display, great for looking at in the dark!"
	icon = 'icons/obj/items/clothing/accessory/watches.dmi'
	icon_state = "cheap_watch"

/obj/item/clothing/accessory/wrist/watch/get_examine_text(mob/user)
	. = ..()

	. += "It reads: [SPAN_NOTICE("[worldtime2text()]")]"

/obj/item/clothing/accessory/wrist/watch/additional_examine_text()
	. = ..()

	. += " It reads: [SPAN_NOTICE("[worldtime2text()]")]"
