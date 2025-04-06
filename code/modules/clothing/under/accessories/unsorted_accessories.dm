/*
This file is for accessories that I couldn't justifiably organized into certain accessory files for reasons.
RIP ties.dm, you geriatric shitfile
*/

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	icon = 'icons/obj/items/clothing/accessory/misc.dmi'
	inv_overlay_icon = 'icons/obj/items/clothing/accessory/inventory_overlays/misc.dmi'
	accessory_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi',
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi'
	)
	flags_equip_slot = SLOT_WAIST
	jumpsuit_hide_states = UNIFORM_JACKET_REMOVED

	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	flags_equip_slot = SLOT_FACE
	accessory_icons = list(
		WEAR_FACE = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi',
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi',
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi'
	)

/obj/item/clothing/accessory/holobadge/attack_self(mob/user)
	..()

	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message(SPAN_DANGER("[user] displays their Wey-Yu Internal Security Legal Authorization Badge.\nIt reads: [stored_name], Wey-Yu Security."),SPAN_DANGER("You display your Wey-Yu Internal Security Legal Authorization Badge.\nIt reads: [stored_name], Wey-Yu Security."))

/obj/item/clothing/accessory/holobadge/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/card/id))

		var/obj/item/card/id/id_card = null

		if(istype(O, /obj/item/card/id))
			id_card = O

		if(ACCESS_MARINE_BRIG in id_card.access)
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return
	..()

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(SPAN_DANGER("[user] invades [M]'s personal space, thrusting [src] into their face insistently."),SPAN_DANGER("You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law."))

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."

/obj/item/storage/box/holobadge/New()
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	..()
	return
