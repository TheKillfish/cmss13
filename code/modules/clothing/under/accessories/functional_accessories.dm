/obj/item/storage/internal/accessory
	storage_slots = 3

/obj/item/clothing/accessory/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands."
	icon_state = "webbing"
	icon = 'icons/obj/items/clothing/accessory/webbings.dmi'
	inv_overlay_icon = 'icons/obj/items/clothing/accessory/inventory_overlays/webbings.dmi'
	accessory_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/accessory/webbings.dmi',
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/accessory/webbings.dmi'
	)
	w_class = SIZE_LARGE //too big to store in other pouches
	var/obj/item/storage/internal/hold = /obj/item/storage/internal/accessory
	slot = ACCESSORY_SLOT_FUNCTIONAL
	high_visibility = TRUE

/obj/item/clothing/accessory/storage/Initialize()
	. = ..()
	hold = new hold(src)

/obj/item/clothing/accessory/storage/Destroy()
	QDEL_NULL(hold)
	return ..()

/obj/item/clothing/accessory/storage/clicked(mob/user, list/mods)
	if(mods["alt"] && !isnull(hold) && loc == user && !user.get_active_hand()) //To pass quick-draw attempts to storage. See storage.dm for explanation.
		return
	. = ..()

/obj/item/clothing/accessory/storage/attack_hand(mob/user as mob, mods)
	if (!isnull(hold) && hold.handle_attack_hand(user, mods))
		..(user)
	return TRUE

/obj/item/clothing/accessory/storage/MouseDrop(obj/over_object as obj)
	if (has_suit || hold)
		return

	if (hold.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/accessory/storage/attackby(obj/item/W, mob/user)
	return hold.attackby(W, user)

/obj/item/clothing/accessory/storage/emp_act(severity)
	. = ..()
	hold.emp_act(severity)

/obj/item/clothing/accessory/storage/hear_talk(mob/M, msg)
	hold.hear_talk(M, msg)
	..()

/obj/item/clothing/accessory/storage/attack_self(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("You empty [src]."))
	var/turf/T = get_turf(src)
	hold.storage_close(usr)
	for(var/obj/item/I in hold.contents)
		hold.remove_from_storage(I, T)
	src.add_fingerprint(user)

/obj/item/clothing/accessory/storage/on_attached(obj/item/clothing/C, mob/living/user, silent)
	. = ..()
	if(.)
		C.w_class = w_class //To prevent monkey business.
		C.verbs += /obj/item/clothing/suit/storage/verb/toggle_draw_mode

/obj/item/clothing/accessory/storage/on_removed(mob/living/user, obj/item/clothing/C)
	. = ..()
	if(.)
		C.w_class = initial(C.w_class)
		C.verbs -= /obj/item/clothing/suit/storage/verb/toggle_draw_mode

/obj/item/storage/internal/accessory/webbing
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
	)

/obj/item/clothing/accessory/storage/webbing
	name = "webbing"
	desc = "A sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	hold = /obj/item/storage/internal/accessory/webbing

/obj/item/clothing/accessory/storage/webbing/black
	name = "black webbing"
	icon_state = "webbing_black"
	item_state = "webbing_black"

/obj/item/clothing/accessory/storage/webbing/five_slots
	hold = /obj/item/storage/internal/accessory/webbing/five_slots

/obj/item/storage/internal/accessory/webbing/five_slots
	storage_slots = 5

/obj/item/storage/internal/accessory/black_vest
	storage_slots = 5

/obj/item/clothing/accessory/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	hold = /obj/item/storage/internal/accessory/black_vest

/obj/item/clothing/accessory/storage/black_vest/attackby(obj/item/W, mob/living/user)
	if(HAS_TRAIT(W, TRAIT_TOOL_WIRECUTTERS) && skillcheck(user, SKILL_RESEARCH, SKILL_RESEARCH_TRAINED))
		var/components = 0
		var/obj/item/reagent_container/glass/beaker/vial
		var/obj/item/cell/battery
		for(var/obj/item in hold.contents)
			if(istype(item, /obj/item/device/radio) || istype(item, /obj/item/stack/cable_coil) || istype(item, /obj/item/device/healthanalyzer))
				components++
			else if(istype(item, /obj/item/reagent_container/hypospray) && !istype(item, /obj/item/reagent_container/hypospray/autoinjector))
				var/obj/item/reagent_container/hypospray/H = item
				if(H.mag)
					vial = H.mag
				components++
			else if(istype(item, /obj/item/cell))
				battery = item
				components++
			else
				components--
		if(components == 5)
			var/obj/item/clothing/accessory/storage/black_vest/acid_harness/AH
			if(istype(src, /obj/item/clothing/accessory/storage/black_vest/brown_vest))
				AH = new /obj/item/clothing/accessory/storage/black_vest/acid_harness/brown(get_turf(loc))
			else
				AH = new /obj/item/clothing/accessory/storage/black_vest/acid_harness(get_turf(loc))
			if(vial)
				AH.vial = vial
				AH.hold.handle_item_insertion(vial)
			AH.battery = battery
			AH.hold.handle_item_insertion(battery)
			qdel(src)
			return
	. = ..()

/obj/item/clothing/accessory/storage/black_vest/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"

/obj/item/clothing/accessory/storage/black_vest/waistcoat
	name = "tactical waistcoat"
	desc = "A stylish black waistcoat with plenty of discreet pouches, to be both utilitarian and fashionable without compromising looks."
	icon_state = "waistcoat"

/obj/item/clothing/accessory/storage/tool_webbing
	name = "Tool Webbing"
	desc = "A brown synthcotton webbing that is similar in function to civilian tool aprons, but is more durable for field usage."
	hold = /obj/item/storage/internal/accessory/tool_webbing
	icon_state = "vest_brown"

/obj/item/clothing/accessory/storage/tool_webbing/small
	name = "Small Tool Webbing"
	desc = "A brown synthcotton webbing that is similar in function to civilian tool aprons, but is more durable for field usage. This is the small low-budget version."
	hold = /obj/item/storage/internal/accessory/tool_webbing/small

/obj/item/storage/internal/accessory/tool_webbing
	storage_slots = 7
	can_hold = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/stack/cable_coil,
		/obj/item/device/multitool,
		/obj/item/tool/shovel/etool,
		/obj/item/weapon/gun/smg/nailgun/compact,
		/obj/item/device/defibrillator/synthetic,
		/obj/item/stack/rods,
	)

/obj/item/storage/internal/accessory/tool_webbing/small
	storage_slots = 6

/obj/item/clothing/accessory/storage/tool_webbing/small/equipped
	hold = /obj/item/storage/internal/accessory/tool_webbing/small/equipped

/obj/item/storage/internal/accessory/tool_webbing/small/equipped/fill_preset_inventory()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/clothing/accessory/storage/tool_webbing/equipped
	hold = /obj/item/storage/internal/accessory/tool_webbing/equipped

/obj/item/storage/internal/accessory/tool_webbing/equipped/fill_preset_inventory()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/device/multitool(src)

/obj/item/storage/internal/accessory/surg_vest
	storage_slots = 14
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste,
	)

/obj/item/storage/internal/accessory/surg_vest/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/surgical_tray))
		var/obj/item/storage/surgical_tray/ST = W
		if(!length(ST.contents))
			return
		if(length(contents) >= storage_slots)
			to_chat(user, SPAN_WARNING("The surgical webbing vest is already full."))
			return
		if(!do_after(user, 5 SECONDS * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_ALL, BUSY_ICON_GENERIC))
			return
		for(var/obj/item/I in ST)
			if(length(contents) >= storage_slots)
				break
			ST.remove_from_storage(I)
			attempt_item_insertion(I, TRUE, user)
		user.visible_message("[user] transfers the tools from \the [ST] to the surgical webbing vest.", SPAN_NOTICE("You transfer the tools from \the [ST] to the surgical webbing vest."), max_distance = 3)
		return
	return ..()

/obj/item/storage/internal/accessory/surg_vest/equipped/fill_preset_inventory()
	new /obj/item/tool/surgery/scalpel/pict_system(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/surgicaldrill(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/tool/surgery/surgical_line(src)
	new /obj/item/tool/surgery/synthgraft(src)

/obj/item/clothing/accessory/storage/surg_vest
	name = "surgical webbing vest"
	desc = "Greenish synthcotton vest purpose-made for holding surgical tools."
	icon_state = "vest_surg"
	hold = /obj/item/storage/internal/accessory/surg_vest

/obj/item/clothing/accessory/storage/surg_vest/equipped
	hold = /obj/item/storage/internal/accessory/surg_vest/equipped

/obj/item/clothing/accessory/storage/surg_vest/blue
	name = "blue surgical webbing vest"
	desc = "A matte blue synthcotton vest purpose-made for holding surgical tools."
	icon_state = "vest_blue"

/obj/item/clothing/accessory/storage/surg_vest/blue/equipped
	hold = /obj/item/storage/internal/accessory/surg_vest/equipped

/obj/item/clothing/accessory/storage/surg_vest/drop_blue
	name = "blue surgical drop pouch"
	desc = "A matte blue synthcotton drop pouch purpose-made for holding surgical tools."
	icon_state = "drop_pouch_surgical_blue"

/obj/item/clothing/accessory/storage/surg_vest/drop_blue/equipped
	hold = /obj/item/storage/internal/accessory/surg_vest/equipped

/obj/item/clothing/accessory/storage/surg_vest/drop_green
	name = "green surgical drop pouch"
	desc = "A greenish synthcotton drop pouch purpose-made for holding surgical tools."
	icon_state = "drop_pouch_surgical_green"

/obj/item/clothing/accessory/storage/surg_vest/drop_green/equipped
	hold = /obj/item/storage/internal/accessory/surg_vest/equipped

/obj/item/clothing/accessory/storage/surg_vest/drop_green/upp
	hold = /obj/item/storage/internal/accessory/surg_vest/drop_green/upp

/obj/item/storage/internal/accessory/surg_vest/drop_green/upp/fill_preset_inventory()
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/surgicaldrill(src)
	new /obj/item/tool/surgery/scalpel/pict_system(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/reagent_container/blood/OMinus(src)

/obj/item/clothing/accessory/storage/surg_vest/drop_black
	name = "black surgical drop pouch"
	desc = "A tactical black synthcotton drop pouch purpose-made for holding surgical tools."
	icon_state = "drop_pouch_surgical_black"

/obj/item/clothing/accessory/storage/surg_vest/drop_black/equipped
	hold = /obj/item/storage/internal/accessory/surg_vest/equipped

/obj/item/clothing/accessory/storage/knifeharness
	name = "M272 pattern knife vest"
	desc = "An older generation M272 pattern knife vest once employed by the USCM. Can hold up to 5 knives. It is made of synthcotton."
	icon_state = "vest_knives"
	hold = /obj/item/storage/internal/accessory/knifeharness

/obj/item/clothing/accessory/storage/knifeharness/attack_hand(mob/user, mods)
	if(!mods || !mods["alt"] || !length(hold.contents))
		return ..()

	hold.contents[length(contents)].attack_hand(user, mods)

/obj/item/storage/internal/accessory/knifeharness
	storage_slots = 5
	max_storage_space = 5
	can_hold = list(
		/obj/item/tool/kitchen/utensil/knife,
		/obj/item/tool/kitchen/utensil/pknife,
		/obj/item/tool/kitchen/knife,
		/obj/item/attachable/bayonet,
		/obj/item/weapon/throwing_knife,
	)
	storage_flags = STORAGE_ALLOW_QUICKDRAW|STORAGE_FLAGS_POUCH

	COOLDOWN_DECLARE(draw_cooldown)

/obj/item/storage/internal/accessory/knifeharness/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/weapon/throwing_knife(src)

/obj/item/storage/internal/accessory/knifeharness/attack_hand(mob/user, mods)
	. = ..()

	if(!COOLDOWN_FINISHED(src, draw_cooldown))
		to_chat(user, SPAN_WARNING("You need to wait before drawing another knife!"))
		return FALSE

	if(length(contents))
		contents[length(contents)].attack_hand(user, mods)
		COOLDOWN_START(src, draw_cooldown, BAYONET_DRAW_DELAY)

/obj/item/storage/internal/accessory/knifeharness/_item_insertion(obj/item/inserted_item, prevent_warning = 0)
	..()
	playsound(src, 'sound/weapons/gun_shotgun_shell_insert.ogg', 15, TRUE)

/obj/item/storage/internal/accessory/knifeharness/_item_removal(obj/item/removed_item, atom/new_location)
	..()
	playsound(src, 'sound/weapons/gun_shotgun_shell_insert.ogg', 15, TRUE)

/obj/item/clothing/accessory/storage/droppouch
	name = "drop pouch"
	desc = "A convenient pouch to carry loose items around."
	icon_state = "drop_pouch"

	hold = /obj/item/storage/internal/accessory/drop_pouch

/obj/item/storage/internal/accessory/drop_pouch
	w_class = SIZE_LARGE //Allow storage containers that's medium or below
	storage_slots = null
	max_w_class = SIZE_MEDIUM
	max_storage_space = 8 //weight system like backpacks, hold enough for 2 medium (normal) size items, or 4 small items, or 8 tiny items
	cant_hold = list( //Prevent inventory powergame
		/obj/item/storage/firstaid,
		/obj/item/storage/bible,
		/obj/item/storage/toolkit,
		)
	storage_flags = STORAGE_ALLOW_DRAWING_METHOD_TOGGLE

/obj/item/clothing/accessory/storage/holster
	name = "shoulder holster"
	desc = "A handgun holster with an attached pouch, allowing two magazines or speedloaders to be stored along with it."
	icon_state = "holster"
	slot = ACCESSORY_SLOT_FUNCTIONAL
	high_visibility = TRUE
	hold = /obj/item/storage/internal/accessory/holster

/obj/item/storage/internal/accessory/holster
	w_class = SIZE_LARGE
	max_w_class = SIZE_MEDIUM
	var/obj/item/weapon/gun/current_gun
	var/sheatheSound = 'sound/weapons/gun_pistol_sheathe.ogg'
	var/drawSound = 'sound/weapons/gun_pistol_draw.ogg'
	storage_flags = STORAGE_ALLOW_QUICKDRAW|STORAGE_FLAGS_POUCH
	can_hold = list(

//Can hold variety of pistols and revolvers together with ammo for them. Can also hold the flare pistol and signal/illumination flares.
	/obj/item/weapon/gun/pistol,
	/obj/item/weapon/gun/energy/taser,
	/obj/item/weapon/gun/revolver,
	/obj/item/ammo_magazine/pistol,
	/obj/item/ammo_magazine/revolver,
	/obj/item/weapon/gun/flare,
	/obj/item/device/flashlight/flare
	)

/obj/item/storage/internal/accessory/holster/on_stored_atom_del(atom/movable/AM)
	if(AM == current_gun)
		current_gun = null

/obj/item/clothing/accessory/storage/holster/attack_hand(mob/user, mods)
	var/obj/item/storage/internal/accessory/holster/H = hold
	if(H.current_gun && ishuman(user) && (loc == user || has_suit))
		if(mods && mods["alt"] && length(H.contents) > 1) //Withdraw the most recently inserted magazine, if possible.
			var/obj/item/I = H.contents[length(H.contents)]
			if(isgun(I))
				I = H.contents[length(H.contents) - 1]
			I.attack_hand(user)
		else
			H.current_gun.attack_hand(user)
		return

	..()

/obj/item/storage/internal/accessory/holster/can_be_inserted(obj/item/W, mob/user, stop_messages = FALSE)
	if( ..() ) //If the parent did their thing, this should be fine. It pretty much handles all the checks.
		if(isgun(W))
			if(current_gun)
				if(!stop_messages)
					to_chat(usr, SPAN_WARNING("[src] already holds \a [W]."))
				return
		else //Must be ammo.
			var/ammo_slots = storage_slots - 1 //We have a slot reserved for the gun
			var/ammo_stored = length(contents)
			if(current_gun)
				ammo_stored--
			if(ammo_stored >= ammo_slots)
				if(!stop_messages)
					to_chat(usr, SPAN_WARNING("[src] can't hold any more magazines."))
				return
		return 1

/obj/item/storage/internal/accessory/holster/_item_insertion(obj/item/W)
	if(isgun(W))
		current_gun = W //If there's no active gun, we want to make this our gun
		playsound(src, sheatheSound, 15, TRUE)
	. = ..()

/obj/item/storage/internal/accessory/holster/_item_removal(obj/item/W)
	if(isgun(W))
		current_gun = null
		playsound(src, drawSound, 15, TRUE)
	. = ..()

/obj/item/clothing/accessory/storage/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"

/obj/item/clothing/accessory/storage/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"

/obj/item/clothing/accessory/storage/owlf_vest
	name = "\improper OWLF agent vest"
	desc = "This is a fancy-looking ballistics vest, meant to be attached to a uniform." //No stats for these yet, just placeholder implementation.
	icon_state = "owlf_vest"
	item_state = "owlf_vest"
