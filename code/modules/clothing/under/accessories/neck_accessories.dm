/obj/item/clothing/accessory/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon_state = "bluetie"
	w_class = SIZE_SMALL
	slot = ACCESSORY_SLOT_DECOR
	flags_equip_slot = SLOT_ACCESSORY

/obj/item/clothing/accessory/tie/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/accessory/tie/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/accessory/tie/green
	name = "green tie"
	icon_state = "greentie"

/obj/item/clothing/accessory/tie/black
	name = "black tie"
	icon_state = "blacktie"

/obj/item/clothing/accessory/tie/gold
	name = "gold tie"
	icon_state = "goldtie"

/obj/item/clothing/accessory/tie/purple
	name = "purple tie"
	icon_state = "purpletie"

/obj/item/clothing/accessory/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated, but still useful, medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	icon = 'icons/obj/items/clothing/accessory/misc.dmi'
	inv_overlay_icon = 'icons/obj/items/clothing/accessory/inventory_overlays/misc.dmi'
	accessory_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi',
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/accessory/misc.dmi',
	)
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/equipment/medical_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/equipment/medical_righthand.dmi',
	)

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/being, mob/living/user)
	if(!ishuman(being) || !isliving(user))
		return

	var/body_part = parse_zone(user.zone_selected)
	if(!body_part)
		return

	var/sound = null
	if(being.stat == DEAD || (being.status_flags & FAKEDEATH))
		sound = "can't hear anything at all, they must have kicked the bucket"
		user.visible_message("[user] places [src] against [being]'s [body_part] and listens attentively.", "You place [src] against [being.p_their()] [body_part] and... you [sound].")
		return

	switch(body_part)
		if("chest")
			if(skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC)) // only medical personnel can take advantage of it
				if(!ishuman(being))
					return // not a human; only humans have the variable internal_organs_by_name // "cast" it a human type since we confirmed it is one
				if(isnull(being.internal_organs_by_name))
					return // they have no organs somehow
				var/datum/internal_organ/heart/heart = being.internal_organs_by_name["heart"]
				if(heart)
					switch(heart.organ_status)
						if(ORGAN_LITTLE_BRUISED)
							sound = "hear <font color='yellow'>small murmurs with each heart beat</font>, it is possible that [being.p_their()] heart is <font color='yellow'>subtly damaged</font>"
						if(ORGAN_BRUISED)
							sound = "hear <font color='orange'>deviant heart beating patterns</font>, result of probable <font color='orange'>heart damage</font>"
						if(ORGAN_BROKEN)
							sound = "hear <font color='red'>irregular and additional heart beating patterns</font>, probably caused by impaired blood pumping, [being.p_their()] heart is certainly <font color='red'>failing</font>"
						else
							sound = "hear <font color='green'>normal heart beating patterns</font>, [being.p_their()] heart is surely <font color='green'>healthy</font>"
				var/datum/internal_organ/lungs/lungs = being.internal_organs_by_name["lungs"]
				if(lungs)
					if(sound)
						sound += ". You also "
					switch(lungs.organ_status)
						if(ORGAN_LITTLE_BRUISED)
							sound += "hear <font color='yellow'>some crackles when [being.p_they()] breath</font>, [being.p_they()] is possibly suffering from <font color='yellow'>a small damage to the lungs</font>"
						if(ORGAN_BRUISED)
							sound += "hear <font color='orange'>unusual respiration sounds</font> and noticeable difficulty to breath, possibly signalling <font color='orange'>ruptured lungs</font>"
						if(ORGAN_BROKEN)
							sound += "<font color='red'>barely hear any respiration sounds</font> and a lot of difficulty to breath, [being.p_their()] lungs are <font color='red'>heavily failing</font>"
						else
							sound += "hear <font color='green'>normal respiration sounds</font> aswell, that means [being.p_their()] lungs are <font color='green'>healthy</font>, probably"
				else
					sound = "can't hear. Really, anything at all, how weird"
			else
				sound = "hear a lot of sounds... it's quite hard to distinguish, really"
		if("eyes","mouth")
			sound = "can't hear anything. Maybe that isn't the smartest idea"
		else
			sound = "hear a sound here and there, but none of them give you any good information"
	user.visible_message("[user] places [src] against [being]'s [body_part] and listens attentively.", "You place [src] against [being.p_their()] [body_part] and... you [sound].")
