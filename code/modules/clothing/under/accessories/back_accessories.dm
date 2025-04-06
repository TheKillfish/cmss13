/obj/item/clothing/accessory/poncho
	name = "USCM Poncho"
	desc = "The standard USCM poncho has variations for every climate. Custom fitted to be attached to standard USCM armor variants it is comfortable, warming or cooling as needed, and well-fit. A marine couldn't ask for more. Affectionately referred to as a \"woobie\"."
	icon_state = "poncho"
	icon = 'icons/obj/items/clothing/accessory/ponchos.dmi'
	inv_overlay_icon = 'icons/obj/items/clothing/accessory/inventory_overlays/ponchos.dmi'
	accessory_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/accessory/ponchos.dmi',
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/accessory/ponchos.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_righthand.dmi'
	)
	slot = ACCESSORY_SLOT_PONCHO
	flags_atom = MAP_COLOR_INDEX

/obj/item/clothing/accessory/poncho/Initialize()
	. = ..()
	// Only do this for the base type '/obj/item/clothing/accessory/poncho'.
	select_gamemode_skin(/obj/item/clothing/accessory/poncho)
	inv_overlay = image("icon" = inv_overlay_icon, "icon_state" = "[icon_state]")
	update_icon()

/obj/item/clothing/accessory/poncho/green
	icon_state = "poncho"

/obj/item/clothing/accessory/poncho/brown
	icon_state = "d_poncho"

/obj/item/clothing/accessory/poncho/black
	icon_state = "u_poncho"

/obj/item/clothing/accessory/poncho/blue
	icon_state = "c_poncho"

/obj/item/clothing/accessory/poncho/purple
	icon_state = "s_poncho"
