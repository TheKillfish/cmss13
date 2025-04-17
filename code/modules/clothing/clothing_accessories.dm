/obj/item/clothing/proc/can_attach_accessory(obj/item/clothing/accessory/fancy_thing)
	if(valid_accessory_slots && istype(fancy_thing) && (fancy_thing.slot in valid_accessory_slots))
		. = 1
	else
		return 0
	if(LAZYLEN(accessories) && restricted_accessory_slots && (fancy_thing.slot in restricted_accessory_slots))
		for(var/obj/item/clothing/accessory/actual_thing in accessories)
			if (actual_thing.slot == fancy_thing.slot)
				return 0

/obj/item/clothing/proc/get_inv_overlay()
	if(!inv_overlay)
		var/tmp_icon_state = overlay_state? overlay_state : icon_state
		if(icon_override && ("[tmp_icon_state]_tie" in icon_states(icon_override)))
			inv_overlay = image(icon = icon_override, icon_state = "[tmp_icon_state]_tie", dir = SOUTH)
		else if("[tmp_icon_state]_tie" in icon_states(GLOB.default_onmob_icons[WEAR_ACCESSORY]))
			inv_overlay = image(icon = GLOB.default_onmob_icons[WEAR_ACCESSORY], icon_state = "[tmp_icon_state]_tie", dir = SOUTH)
		else
			inv_overlay = image(icon = GLOB.default_onmob_icons[WEAR_ACCESSORY], icon_state = tmp_icon_state, dir = SOUTH)
	inv_overlay.color = color
	return inv_overlay

/obj/item/clothing/proc/get_mob_overlay_accessory(mob/user_mob, slot, default_bodytype = "Default")
	if(!istype(loc, /obj/item/clothing)) //don't need special handling if it's worn as normal item.
		return
	var/bodytype = default_bodytype
	if(ishuman(user_mob))
		var/mob/living/carbon/human/user_human = user_mob
		var/user_bodytype = user_human.species.get_bodytype(user_human)
		if(LAZYISIN(sprite_sheets, user_bodytype))
			bodytype = user_bodytype

		var/tmp_icon_state = overlay_state? overlay_state : icon_state

		if(istype(loc,/obj/item/clothing/under))
			var/obj/item/clothing/under/C = loc
			if(C.flags_jumpsuit & jumpsuit_hide_states && !(C.flags_jumpsuit & UNIFORM_DO_NOT_HIDE_ACCESSORIES))
				return

		var/use_sprite_sheet = accessory_icons[slot]
		var/sprite_sheet_bodytype = LAZYACCESS(sprite_sheets, bodytype)
		if(sprite_sheet_bodytype)
			use_sprite_sheet = sprite_sheet_bodytype

		if(icon_override && ("[tmp_icon_state]_mob" in icon_states(icon_override)))
			return overlay_image(icon_override, "[tmp_icon_state]_mob", color, RESET_COLOR)
		else
			return overlay_image(use_sprite_sheet, tmp_icon_state, color, RESET_COLOR)

/obj/item/clothing/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/clothing/accessory) && can_be_accessory)
		if(!LAZYLEN(valid_accessory_slots))
			to_chat(usr, SPAN_WARNING("You cannot attach accessories of any kind to \the [src]."))
			return

		var/obj/item/clothing/accessory/attachable = item
		if(can_attach_accessory(attachable))
			if(!user.drop_held_item())
				return
			attach_accessory(user, attachable)
			return TRUE //For some suit/storage items which both allow attaching accessories and also have their own internal storage.
		else
			to_chat(user, SPAN_WARNING("You cannot attach more accessories of this type to [src]."))
		return

	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/accessory/attachable in accessories)
			attachable.attackby(item, user)
		return

	..()

/**
 *  Attach accessory A to src
 *
 *  user is the user doing the attaching. Can be null, such as when attaching
 *  items on spawn
 */
/obj/item/clothing/proc/attach_accessory(mob/user, obj/item/clothing/accessory/A, silent)
	if(!A.can_attach_to(user, src))
		return

	LAZYADD(accessories, A)
	A.on_attached(src, user, silent)
	if(A.removable)
		verbs += /obj/item/clothing/proc/removetie_verb
	update_clothing_icon()

/obj/item/clothing/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!LAZYISIN(accessories, A))
		return

	A.on_removed(user, src)
	LAZYREMOVE(accessories, A)

	var/any_removable = FALSE
	for(var/obj/item/clothing/accessory/accessory in accessories)
		if(accessory.removable)
			any_removable = TRUE
			break
	if(!any_removable)
		verbs -= /obj/item/clothing/proc/removetie_verb

	update_clothing_icon()

/obj/item/clothing/proc/removetie_verb()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr

	remove_accessory(usr, pick_accessory_to_remove(usr, usr))

/obj/item/clothing/proc/pick_accessory_to_remove(mob/user, mob/targetmob)
	if(!isliving(user))
		return
	if(user.stat)
		return
	if(!LAZYLEN(accessories))
		return
	var/obj/item/clothing/accessory/accessory
	var/list/removables = list()
	var/list/choice_to_accessory = list()
	for(var/obj/item/clothing/accessory/ass in accessories)
		if(!ass.removable)
			continue
		var/capitalized_name = capitalize_first_letters(ass.name)
		removables[capitalized_name] = image(icon = ass.icon, icon_state = ass.icon_state)
		choice_to_accessory[capitalized_name] = ass

	if(LAZYLEN(removables) > 1)
		var/use_radials = user.client.prefs?.no_radials_preference ? FALSE : TRUE
		var/choice = use_radials ? show_radial_menu(user, targetmob, removables, require_near = FALSE) : tgui_input_list(user, "Select an accessory to remove from [src]", "Remove accessory", removables)
		accessory = choice_to_accessory[choice]
	else
		accessory = choice_to_accessory[removables[1]]
	if(!user.Adjacent(src))
		to_chat(user, SPAN_WARNING("You're too far away!"))
		return

	return accessory

/obj/item/clothing/emp_act(severity)
	. = ..()
	if(LAZYLEN(accessories))
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)

// Accessory parent type

/obj/item/clothing/accessory
	name = "accessory"
	desc = "A generic accessory that takes the form of a tie. You should not be seeing this."
	icon = 'icons/obj/items/clothing/accessory/ties.dmi'
	icon_state = "bluetie"
	w_class = SIZE_SMALL
	flags_equip_slot = SLOT_ACCESSORY
	sprite_sheets = list(SPECIES_MONKEY = 'icons/mob/humans/species/monkeys/onmob/ties_monkey.dmi')

/obj/item/clothing/accessory/Initialize()
	. = ..()
	inv_overlay = image("icon" = inv_overlay_icon, "icon_state" = "[item_state? "[item_state]" : "[icon_state]"]")
	flags_atom |= USES_HEARING

/obj/item/clothing/accessory/Destroy()
	if(has_suit)
		has_suit.remove_accessory()
	inv_overlay = null
	. = ..()

/obj/item/clothing/accessory/proc/can_attach_to(mob/user, obj/item/clothing/C)
	return TRUE

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/S, mob/living/user, silent)
	if(!istype(S))
		return
	has_suit = S
	forceMove(has_suit)
	has_suit.overlays += get_inv_overlay()

	if(user)
		if(!silent)
			to_chat(user, SPAN_NOTICE("You attach \the [src] to \the [has_suit]."))
		src.add_fingerprint(user)
	return TRUE

/obj/item/clothing/accessory/proc/on_removed(mob/living/user, obj/item/clothing/C)
	if(!has_suit)
		return
	has_suit.overlays -= get_inv_overlay()
	has_suit = null
	if(usr)
		usr.put_in_hands(src)
		src.add_fingerprint(usr)
	else
		src.forceMove(get_turf(src))
	return TRUE

//default attackby behaviour
/obj/item/clothing/accessory/attackby(obj/item/I, mob/user)
	..()

//default attack_hand behaviour
/obj/item/clothing/accessory/attack_hand(mob/user as mob)
	if(has_suit)
		return //we aren't an object on the ground so don't call parent. If overriding to give special functions to a host item, return TRUE so that the host doesn't continue its own attack_hand.
	..()

///Extra text to append when attached to another clothing item and the host clothing is examined.
/obj/item/clothing/accessory/proc/additional_examine_text()
	return "attached to it."
