//Base Instance
/area/desert_dam
	name = "Desert Dam"
	icon_state = "cliff_blocked"
	can_build_special = TRUE
	powernet_name = "ground"
	ambience_exterior = AMBIENCE_TRIJENT
	minimap_color = MINIMAP_AREA_COLONY

//INTERIOR
// areas under rock
/area/desert_dam/interior
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS

//NorthEastern Lab Section
/area/desert_dam/interior/lab_northeast
	name = "Northeastern Lab"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_RESEARCH
	unoviable_timer = FALSE

/area/desert_dam/interior/lab_northeast/east_lab_lobby
	name = "East Lab Lobby"
	icon_state = "green"

/area/desert_dam/interior/lab_northeast/east_lab_west_hallway
	name = "East Lab Western Hallway"
	icon_state = "blue"

/area/desert_dam/interior/lab_northeast/east_lab_central_hallway
	name = "East Lab Central Hallway"
	icon_state = "green"

/area/desert_dam/interior/lab_northeast/east_lab_east_hallway
	name = "East Lab East Hallway"
	icon_state = "yellow"

/area/desert_dam/interior/lab_northeast/east_lab_workshop
	name = "East Lab Workshop"
	icon_state = "ass_line"

/area/desert_dam/interior/lab_northeast/east_lab_maintenence
	name = "East Lab Maintenence"
	icon_state = "maintcentral"

/area/desert_dam/interior/lab_northeast/east_lab_containment
	name = "East Lab Containment"
	icon_state = "purple"

/area/desert_dam/interior/lab_northeast/east_lab_RND
	name = "East Lab Research and Development"
	icon_state = "purple"

/area/desert_dam/interior/lab_northeast/east_lab_biology
	name = "East Lab Biology"
	icon_state = "purple"

/area/desert_dam/interior/lab_northeast/east_lab_excavation
	name = "East Lab Excavation Prep"
	icon_state = "blue"

/area/desert_dam/interior/lab_northeast/east_lab_west_entrance
	name = "East Lab West Entrance"
	icon_state = "purple"

/area/desert_dam/interior/lab_northeast/east_lab_east_entrance
	name = "East Lab Entrance"
	icon_state = "purple"

/area/desert_dam/interior/lab_northeast/east_lab_security_armory
	name = "East Lab Armory"
	icon_state = "armory"

//Dam Interior
/area/desert_dam/interior/dam_interior
	minimap_color = MINIMAP_AREA_ENGI

/area/desert_dam/interior/dam_interior/engine_room
	name = "Engineering Generator Room"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/control_room
	name = "Engineering Control Room"
	icon_state = "red"

/area/desert_dam/interior/dam_interior/smes_main
	name = "Engineering Main Substation"
	icon_state = "purple"

/area/desert_dam/interior/dam_interior/smes_backup
	name = "Engineering Secondary Backup Substation"
	icon_state = "green"

/area/desert_dam/interior/dam_interior/engine_east_wing
	name = "Engineering East Engine Wing"
	icon_state = "blue-red"

/area/desert_dam/interior/dam_interior/engine_west_wing
	name = "Engineering West Engine Wing"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/lobby
	name = "Engineering Lobby"
	icon_state = "purple"

/area/desert_dam/interior/dam_interior/atmos_storage
	name = "Engineering Atmospheric Storage"
	icon_state = "purple"

/area/desert_dam/interior/dam_interior/northwestern_tunnel
	name = "Engineering Northwestern Tunnel"
	icon_state = "green"

/area/desert_dam/interior/dam_interior/north_tunnel
	name = "Engineering Northern Tunnel"
	icon_state = "blue-red"

/area/desert_dam/interior/dam_interior/west_tunnel
	name = "Engineering Western Tunnel"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/central_tunnel
	name = "Engineering Central Tunnel"
	icon_state = "red"

/area/desert_dam/interior/dam_interior/south_tunnel
	name = "Engineering Southern Tunnel"
	icon_state = "purple"

/area/desert_dam/interior/dam_interior/northeastern_tunnel
	name = "Engineering Northeastern Tunnel"
	icon_state = "green"

/area/desert_dam/interior/dam_interior/CE_office
	name = "Engineering Chief Engineer's Office"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/workshop
	name = "Engineering Workshop"
	icon_state = "purple"

/area/desert_dam/interior/dam_interior/hanger
	name = "Engineering Hangar"
	icon_state = "hangar"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/interior/dam_interior/hangar_storage
	name = "Engineering Hangar Storage"
	icon_state = "storage"

/area/desert_dam/interior/dam_interior/auxilary_tool_storage
	name = "Engineering Auxiliary Tool Storage"
	icon_state = "red"

/area/desert_dam/interior/dam_interior/primary_tool_storage
	name = "Engineering Primary Tool Storage"
	icon_state = "blue"

/area/desert_dam/interior/dam_interior/tech_storage
	name = "Engineering Secure Tech Storage"
	icon_state = "dark"

/area/desert_dam/interior/dam_interior/break_room
	name = "Engineering Breakroom"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/disposals
	name = "Engineering Disposals"
	icon_state = "disposal"

/area/desert_dam/interior/dam_interior/western_dam_cave
	name = "Engineering West Entrance"
	icon_state = "red"

/area/desert_dam/interior/dam_interior/office
	name = "Engineering Office"
	icon_state = "red"

/area/desert_dam/interior/dam_interior
	name = "Engineering"
	icon_state = ""

/area/desert_dam/interior/dam_interior/north_tunnel_entrance
	name = "Engineering North Tunnel Entrance"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/east_tunnel_entrance
	name = "Engineering East Tunnel Entrance"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/south_tunnel_entrance
	name = "Engineering South Tunnel Entrance"
	icon_state = "red"

/area/desert_dam/interior/dam_interior/garage
	name = "Garage"
	icon_state = "green"

/area/desert_dam/interior/caves
	name = "Caves"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "red"
	ambience_exterior = AMBIENCE_CAVE
	soundscape_playlist = SCAPE_PL_CAVE
	soundscape_interval = 25
	sound_environment = SOUND_ENVIRONMENT_AUDITORIUM
	minimap_color = MINIMAP_AREA_CAVES

/area/desert_dam/interior/caves/east_caves
	name = "Eastern Caves"
	icon_state = "red"
	unoviable_timer = FALSE

/area/desert_dam/interior/caves/central_caves
	name = "Central Caves"
	icon_state = "yellow"
	unoviable_timer = FALSE

/area/desert_dam/interior/caves/temple
	name = "Sand Temple"
	icon_state = "green"
	unoviable_timer = FALSE

//BUILDING
//areas not under rock
// ceiling = CEILING_METAL
/area/desert_dam/building
	ceiling = CEILING_METAL

//Substations
/area/desert_dam/building/substation
	name = "Substation"
	icon = 'icons/turf/dam_areas.dmi'
	minimap_color = MINIMAP_AREA_ENGI

/area/desert_dam/building/substation/northwest
	name = "Command Substation"
	icon_state = "northewestern_ss"
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/substation/northeast
	name = "Command Substation"
	icon_state = "northeastern_ss"
	unoviable_timer = FALSE

/area/desert_dam/building/substation/central
	name = "Command Substation"
	icon_state = "central_ss"
	unoviable_timer = FALSE

/area/desert_dam/building/substation/southwest
	name = "Command Substation"
	icon_state = "southwestern_ss"

/area/desert_dam/building/substation/west
	name = "Command Substation"
	icon_state = "western_ss"
	linked_lz = DROPSHIP_LZ2

//Administration
/area/desert_dam/building/administration
	minimap_color = MINIMAP_AREA_COMMAND

/area/desert_dam/building/administration/control_room
	name = "Administration Landing Control Room"
	icon_state = "yellow"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/lobby
	name = "Administration Lobby"
	icon_state = "green"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/hallway
	name = "Administration Hallway"
	icon_state = "purple"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/office
	name = "Administration Office"
	icon_state = "blue-red"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/overseer_office
	name = "Administration Overseer's Office"
	icon_state = "red"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/meetingrooom
	name = "Administration Meeting Room"
	icon_state = "yellow"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/building/administration/archives
	name = "Administration Archives"
	icon_state = "green"
	linked_lz = DROPSHIP_LZ1


//Bar
/area/desert_dam/building/bar/bar
	name = "Bar"
	icon_state = "yellow"

/area/desert_dam/building/bar/backroom
	name = "Bar Backroom"
	icon_state = "green"

/area/desert_dam/building/bar/bar_restroom
	name = "Bar Restroom"
	icon_state = "purple"


//Cafe
/area/desert_dam/building/cafeteria
	name = "DO NOT USE"
	icon_state = "purple"
	unoviable_timer = FALSE

/area/desert_dam/building/cafeteria/cafeteria
	name = "Cafeteria"
	icon_state = "yellow"

/area/desert_dam/building/cafeteria/backroom
	name = "Cafeteria Backroom"
	icon_state = "green"

/area/desert_dam/building/cafeteria/loading
	name = "Cafeteria Loading Room"
	icon_state = "blue-red"

/area/desert_dam/building/cafeteria/cold_room
	name = "Cafeteria Coldroom"
	icon_state = "red"


//Dorms
/area/desert_dam/building/dorms
	name = "DO NOT USE"
	icon_state = "purple"
	unoviable_timer = FALSE

/area/desert_dam/building/dorms/hallway_northwing
	name = "Dormitory North Wing"
	icon_state = "yellow"

/area/desert_dam/building/dorms/hallway_westwing
	name = "Dormitory West Wing"
	icon_state = "green"

/area/desert_dam/building/dorms/restroom
	name = "Dormitory Showers"
	icon_state = "blue-red"

/area/desert_dam/building/dorms/pool
	name = "Dormitory Pool Room"
	icon_state = "red"


//Medical
/area/desert_dam/building/medical
	minimap_color = MINIMAP_AREA_MEDBAY
	unoviable_timer = FALSE

/area/desert_dam/building/medical/garage
	name = "Medical Garage"
	icon_state = "garage"

/area/desert_dam/building/medical/emergency_room
	name = "Medical Emergency Room"
	icon_state = "medbay"

/area/desert_dam/building/medical/treatment_room
	name = "Medical Treatment Room"
	icon_state = "medbay2"

/area/desert_dam/building/medical/lobby
	name = "Medical Lobby"
	icon_state = "medbay3"

/area/desert_dam/building/medical/chemistry
	name = "Medical Pharmacy"
	icon_state = "medbay"

/area/desert_dam/building/medical/west_wing_hallway
	name = "Medical West Wing"
	icon_state = "medbay2"

/area/desert_dam/building/medical/north_wing_hallway
	name = "Medical North Wing"
	icon_state = "medbay3"

/area/desert_dam/building/medical/east_wing_hallway
	name = "Medical East Wing"
	icon_state = "medbay"

/area/desert_dam/building/medical/primary_storage
	name = "Medical Primary Storage"
	icon_state = "red"

/area/desert_dam/building/medical/surgery_room_one
	name = "Medical Surgery Room One"
	icon_state = "yellow"

/area/desert_dam/building/medical/surgery_room_two
	name = "Medical Surgery Room Two"
	icon_state = "purple"

/area/desert_dam/building/medical/surgury_observation
	name = "Medical Surgery Observation"
	icon_state = "medbay2"

/area/desert_dam/building/medical/morgue
	name = "Medical Morgue"
	icon_state = "blue"

/area/desert_dam/building/medical/break_room
	name = "Medical Breakroom"
	icon_state = "medbay"

/area/desert_dam/building/medical/CMO
	name = "Medical CMO's Office"
	icon_state = "CMO"

/area/desert_dam/building/medical/office1
	name = "Medical Office One"
	icon_state = "red"

/area/desert_dam/building/medical/office2
	name = "Medical Office Two"
	icon_state = "blue"

/area/desert_dam/building/medical/virology_wing
	name = "Medical Virology Wing"
	icon_state = "medbay3"

/area/desert_dam/building/medical/virology_isolation
	name = "Medical Virology Isolation"
	icon_state = "medbay"

/area/desert_dam/building/medical
	name = "Medical"
	icon_state = "medbay2"


//Warehouse
/area/desert_dam/building/warehouse/warehouse
	name = "Warehouse"
	icon_state = "yellow"
	linked_lz = DROPSHIP_LZ2

/area/desert_dam/building/warehouse/loading
	name = "Warehouse Loading Room"
	icon_state = "red"
	linked_lz = DROPSHIP_LZ2

/area/desert_dam/building/warehouse/breakroom
	name = "Warehouse Breakroom"
	icon_state = "green"
	linked_lz = DROPSHIP_LZ2


//Hydroponics
/area/desert_dam/building/hydroponics
	minimap_color = MINIMAP_AREA_RESEARCH

/area/desert_dam/building/hydroponics/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/desert_dam/building/hydroponics/hydroponics_storage
	name = "Hydroponics Storage"
	icon_state = "green"

/area/desert_dam/building/hydroponics/hydroponics_loading
	name = "Hydroponics Loading Room"
	icon_state = "garage"

/area/desert_dam/building/hydroponics/hydroponics_breakroom
	name = "Hydroponics Breakroom"
	icon_state = "red"

//Water Treatment Plant 1
/area/desert_dam/building/water_treatment_one
	minimap_color = MINIMAP_AREA_ENGI

/area/desert_dam/building/water_treatment_one
	name = "Water Treatment One"
	icon_state = "yellow"

//Water Treatment Plant 1
/area/desert_dam/building/water_treatment_one/lobby
	name = "Water Treatment One Lobby"
	icon_state = "red"

/area/desert_dam/building/water_treatment_one/breakroom
	name = "Water Treatment One Breakroom"
	icon_state = "green"

/area/desert_dam/building/water_treatment_one/garage
	name = "Water Treatment One Garage"
	icon_state = "garage"

/area/desert_dam/building/water_treatment_one/equipment
	name = "Water Treatment One Equipment Room"
	icon_state = "red"

/area/desert_dam/building/water_treatment_one/hallway
	name = "Water Treatment One Hallway"
	icon_state = "purple"

/area/desert_dam/building/water_treatment_one/control_room
	name = "Water Treatment One Control Room"
	icon_state = "yellow"

/area/desert_dam/building/water_treatment_one/purification
	name = "Water Treatment One Purification"
	icon_state = "green"

/area/desert_dam/building/water_treatment_one/floodgate_control
	name = "Water Treatment One Floodgate Control"
	icon_state = "green"

//Water Treatment Plant 2
/area/desert_dam/building/water_treatment_two
	minimap_color = MINIMAP_AREA_ENGI
	unoviable_timer = FALSE

/area/desert_dam/building/water_treatment_two
	name = "Water Treatment Two"
	icon_state = "yellow"

/area/desert_dam/building/water_treatment_two/lobby
	name = "Water Treatment Two Lobby"
	icon_state = "red"

/area/desert_dam/building/water_treatment_two/equipment
	name = "Water Treatment Two Equipment"
	icon_state = "red"

/area/desert_dam/building/water_treatment_two/hallway
	name = "Water Treatment Two Hallway"
	icon_state = "purple"

/area/desert_dam/building/water_treatment_two/control_room
	name = "Water Treatment Two Control Room"
	icon_state = "yellow"

/area/desert_dam/building/water_treatment_two/purification
	name = "Water Treatment Two Purification"
	icon_state = "green"

/area/desert_dam/building/water_treatment_two/floodgate_control
	name = "Water Treatment Two Floodgate Control"
	icon_state = "green"


//Library UNUSED
/*
/area/desert_dam/building/library/library
	name = "Library"
	icon_state = "library"
/area/desert_dam/building/library/restroom
	name = "Library Restroom"
	icon_state = "green"
/area/desert_dam/building/library/studyroom
	name = "Library Study Room"
	icon_state = "purple"
*/

//Security
/area/desert_dam/building/security
	minimap_color = MINIMAP_AREA_SEC

/area/desert_dam/building/security/prison
	name = "Security Prison"
	icon_state = "sec_prison"

/area/desert_dam/building/security/marshals_office
	name = "Security Marshal's Office"
	icon_state = "sec_hos"

/area/desert_dam/building/security/armory
	name = "Security Armory"
	icon_state = "armory"

/area/desert_dam/building/security/warden
	name = "Security Warden's Office"
	icon_state = "Warden"

/area/desert_dam/building/security/interrogation
	name = "Security Interrogation"
	icon_state = "interrogation"

/area/desert_dam/building/security/observation
	name = "Security Observation"
	icon_state = "observatory"

/area/desert_dam/building/security/detective
	name = "Security Detective's Office"
	icon_state = "detective"

/area/desert_dam/building/security/office
	name = "Security Office"
	icon_state = "yellow"

/area/desert_dam/building/security/lobby
	name = "Security Lobby"
	icon_state = "green"

/area/desert_dam/building/security/northern_hallway
	name = "Security North Hallway"
	icon_state = "purple"

/area/desert_dam/building/security/courtroom
	name = "Security Courtroom"
	icon_state = "courtroom"

/area/desert_dam/building/security/evidence
	name = "Security Evidence"
	icon_state = "red"

/area/desert_dam/building/security/holding
	name = "Security Holding Room"
	icon_state = "yellow"

/area/desert_dam/building/security/southern_hallway
	name = "Security South Hallway"
	icon_state = "green"

/area/desert_dam/building/security/deathrow
	name = "Security Death Row"
	icon_state = "cells_max_n"

/area/desert_dam/building/security/execution_chamber
	name = "Security Execution Chamber"
	icon_state = "red"

/area/desert_dam/building/security/staffroom
	name = "Security Staffroom"
	icon_state = "security"

//Church
/area/desert_dam/building/church
	name = "Church"
	icon_state = "courtroom"
	linked_lz = DROPSHIP_LZ2

//Mining area
/area/desert_dam/building/mining
	name = "DO NOT USE"
	icon_state = "purple"
	unoviable_timer = FALSE

/area/desert_dam/building/mining/workshop
	name = "Mining Workshop"
	icon_state = "yellow"

/area/desert_dam/building/mining/workshop_foyer
	name = "Mining Workshop Foyer"
	icon_state = "purple"

//NorthWest Lab Buildings
/area/desert_dam/building/lab_northwest
	minimap_color = MINIMAP_AREA_RESEARCH

/area/desert_dam/building/lab_northwest/west_lab_xenoflora
	name = "West Lab Xenoflora"
	icon_state = "purple"

//EXTERIOR
//under open sky
/area/desert_dam/exterior
	requires_power = 1
	always_unpowered = 1
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	//ambience = list('sound/ambience/ambiatm1.ogg')

/area/desert_dam/exterior/rock
	name = "Rock"
	icon_state = "cave"

//Landing Pad for the Alamo. THIS IS NOT THE SHUTTLE AREA
/area/desert_dam/exterior/landing_pad_one
	name = "Airstrip Landing Pad"
	icon_state = "landing_pad"
	linked_lz = DROPSHIP_LZ1
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	always_unpowered = FALSE
	power_light = TRUE
	power_equip = TRUE
	power_environ = TRUE

//Landing Pad for the Normandy. THIS IS NOT THE SHUTTLE AREA
/area/desert_dam/exterior/landing_pad_two
	name = "Aerodrome Landing Pad"
	icon_state = "landing_pad"
	linked_lz = DROPSHIP_LZ2
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	always_unpowered = FALSE
	power_light = TRUE
	power_equip = TRUE
	power_environ = TRUE

//Valleys
//Near LZ
//TODO: incorporate valleys and substrations for floodlight coverage

/area/desert_dam/exterior/valley
	name = "Valley"
	icon_state = "red"

/area/desert_dam/exterior/valley/valley_northwest
	name = "Northwest Valley"
	icon_state = "valley_north_west"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/exterior/valley/valley_cargo
	name = "Shipping Valley"
	icon_state = "valley_south_west"
	linked_lz = DROPSHIP_LZ2

/area/desert_dam/exterior/valley/valley_telecoms
	name = "Telecomms Valley"
	icon_state = "valley_west"
	linked_lz = DROPSHIP_LZ2

/area/desert_dam/exterior/valley/valley_security
	name = "Security Valley"
	icon_state = "valley_west"

// Generic bridge used in nightmare inserts... Can in fact be different places (sigh)
/area/desert_dam/exterior/valley/valley_bridge
	name = "Valley Bridge"
	icon_state = "valley"

//telecomms areas
/area/desert_dam/exterior/telecomm
	name = "\improper Trijent Dam Communications Relay"
	icon_state = "ass_line"
	ceiling_muffle = FALSE
	base_muffle = MUFFLE_LOW
	always_unpowered = 0

/area/desert_dam/exterior/telecomm/lz2_containers
	name = "\improper Containers Communications Relay"
	linked_lz = DROPSHIP_LZ2

/area/desert_dam/exterior/telecomm/lz2_tcomms
	name = "\improper Telecomms Communications Relay"
	linked_lz = DROPSHIP_LZ2


/area/desert_dam/exterior/telecomm/lz2_storage
	name = "\improper East LZ2 Communications Relay"
	linked_lz = DROPSHIP_LZ2


/area/desert_dam/exterior/telecomm/lz1_south
	name = "\improper South LZ1 Communications Relay"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/exterior/telecomm/lz1_valley
	name = "\improper LZ1 Valley Communications Relay"
	linked_lz = DROPSHIP_LZ1

/area/desert_dam/exterior/telecomm/lz1_xenoflora
	name = "\improper Xenoflora Communications Relay"
	linked_lz = DROPSHIP_LZ1

//Away from LZ

/area/desert_dam/exterior/valley/valley_labs
	name = "Lab Valley"
	icon_state = "valley_north"

/area/desert_dam/exterior/valley/valley_mining
	name = "Mining Valley"
	icon_state = "valley_east"
	unoviable_timer = FALSE

/area/desert_dam/exterior/valley/valley_civilian
	name = "Civilian Valley"
	icon_state = "valley_south_excv"
	unoviable_timer = FALSE

/area/desert_dam/exterior/valley/valley_medical
	name = "Medical Valley"
	icon_state = "valley"
	unoviable_timer = FALSE

/area/desert_dam/exterior/valley/valley_hydro
	name = "Hydro Valley"
	icon_state = "valley"

/area/desert_dam/exterior/valley/valley_crashsite
	name = "Crash Site Valley"
	icon_state = "yellow"
	unoviable_timer = FALSE

/area/desert_dam/exterior/valley/north_valley_dam
	name = "North Dam Valley"
	icon_state = "valley"

/area/desert_dam/exterior/valley/south_valley_dam
	name = "South Dam Valley"
	icon_state = "valley"

/area/desert_dam/exterior/valley/bar_valley_dam
	name = "Bar Valley"
	icon_state = "yellow"

/area/desert_dam/exterior/valley/valley_wilderness
	name = "Wilderness Valley"
	icon_state = "central"
	unoviable_timer = FALSE


//Rivers
/area/desert_dam/exterior/river
	name = "River"
	icon_state = "bluenew"
	var/filtered = 0
	var/list/Next_areas = list()//The next river to update - that is, unless...
	var/obj/structure/machinery/console/toggle/Floodgate = null //If there's a floodgate at the end of us, this is it's ID

/area/desert_dam/exterior/river/proc/check_filtered()
	var/turf/open/gm/river/desert/R
	if(filtered)
		for(R in src)
			R.toxic = 0
	else
		for(R in src)
			R.toxic = 1
	R.update_icon()
	if(Next_areas && !(src in Next_areas)) //Shouldn't ever happen but just to be safe
		for(var/area/desert_dam/exterior/river/A in Next_areas)
			A.check_filtered()


//End of the river areas, no Next
/area/desert_dam/exterior/river/riverside_central_north
	name = "Northern Central Riverbed"
	icon_state = "purple"

/area/desert_dam/exterior/river/riverside_central_south
	name = "Southern Central Riverbed"
	icon_state = "purple"

/area/desert_dam/exterior/river/riverside_south
	name = "Southern Riverbed"
	icon_state = "bluenew"

/area/desert_dam/exterior/river/riverside_east
	name = "Eastern Riverbed"
	icon_state = "bluenew"

//The filtration plants - This area isn't for the WHOLE plant, but the areas that have water in them, so the water changes color as well.

/area/desert_dam/exterior/river/filtration_a
	name = "Filtration Plant A"

//Areas that are rivers, but will not change because they're before the floodgates
/area/desert_dam/exterior/river_mouth/southern
	name = "Southern River Mouth"
	icon_state = "purple"

/area/desert_dam/landing/console
	name = "LZ1 'Admin'"
	icon_state = "tcomsatcham"
	requires_power = 0

/area/desert_dam/landing/console2
	name = "LZ2 'Supply'"
	icon_state = "tcomsatcham"
	requires_power = 0


//Transit Shuttle
/area/shuttle/tri_trans1/alpha
	icon_state = "shuttle"

/area/shuttle/tri_trans1/away
	icon_state = "away1"

/area/shuttle/tri_trans1/omega
	icon_state = "shuttle2"

/area/shuttle/tri_trans2/alpha
	icon_state = "shuttlered"

/area/shuttle/tri_trans2/away
	icon_state = "away2"

/area/shuttle/tri_trans2/omega
	icon_state = "shuttle2"
