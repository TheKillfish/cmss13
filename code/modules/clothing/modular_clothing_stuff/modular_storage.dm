// Basically a frankenstein of present (09/06/2026) suit storage and accessory storage, with accomodation for making suit storage versions of other storage forms such as belts

/obj/item/storage/internal/modular
	w_class = SIZE_LARGE
	storage_slots = null
	max_w_class = SIZE_SMALL
	max_storage_space = 0

/obj/item/clothing/modular/storage_item
	name = "modular storage"
	desc = "Storage for outerwear that you can remove and replace. Nifty! Although you shouldn't be seeing this one, make an issue report for this."
	icon_state = "webbing"
	icon = 'icons/obj/items/clothing/accessory/webbings.dmi'
	w_class = SIZE_LARGE
	var/obj/item/storage/internal/item_store
	high_visibility = TRUE // Appears on examine

	/// How many slots does this have? Make null if you want slotless (i.e. drop pouch) behavior.
	var/max_slots = 2
	/// How much total storage space does this have? Mostly relevant for slotless (i.e. drop pouch) behavior.
	var/max_space = 14
	/// What size items can this store?
	var/max_weight_class = SIZE_SMALL
	/// What items can this specifically carry? If used, prevents non-whitelisted items from being stored.
	var/list/item_whitelist = list()
	/// What items can this specifically NOT carry? Not applicable if item_whitelist is used.
	var/list/item_blacklist = list()
	/// Any applicable storage flags.
	var/applicable_flags = STORAGE_FLAGS_DEFAULT

/obj/item/clothing/modular/storage_item/Initialize()
	. = ..()
	item_store = new/obj/item/storage/internal/modular(src)
	item_store.storage_slots = max_slots
	item_store.max_storage_space = max_space
	item_store.max_w_class = max_weight_class
	item_store.can_hold = item_whitelist
	item_store.cant_hold = item_blacklist
	item_store.storage_flags = applicable_flags

/obj/item/clothing/modular/storage_item/Destroy()
	QDEL_NULL(item_store)
	return ..()

/obj/item/clothing/modular/storage_item/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK] && !isnull(item_store) && loc == user && !user.get_active_hand()) //To pass quick-draw attempts to storage. See storage.dm for explanation.
		return
	. = ..()

/obj/item/clothing/modular/storage_item/attack_hand(mob/user as mob, mods)
	if(!isnull(item_store) && item_store.handle_attack_hand(user, mods))
		..(user)
	return TRUE

/obj/item/clothing/modular/storage_item/MouseDrop(obj/over_object as obj)
	/*if(has_suit || item_store)
		return*/

	if(item_store.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/modular/storage_item/attackby(obj/item/thing, mob/user)
	. = ..()
	if(!.) //To prevent bugs with accessories being moved into storage slots after being attached.
		return item_store.attackby(thing, user)

/obj/item/clothing/modular/storage_item/emp_act(severity)
	. = ..()
	item_store.emp_act(severity)

/obj/item/clothing/modular/storage_item/hear_talk(mob/talker, msg, verb, datum/language/speaking, italics)
	item_store.hear_talk(talker, msg, verb, speaking, italics)
	..()

/obj/item/clothing/modular/storage_item/attack_self(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("You empty [src]."))
	var/turf/T = get_turf(src)
	item_store.storage_close(usr)
	for(var/obj/item/I in item_store.contents)
		item_store.remove_from_storage(I, T)
	src.add_fingerprint(user)
