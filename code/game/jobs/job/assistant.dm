/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	departments = list("Civilian")
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()

/datum/job/assistant/equip_items(var/mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

/datum/job/assistant/get_access()
	if(game_options.assistants_have_maint_access) //Config has assistant maint access set
		. = ..()
		. |= list(access_maint_tunnels)
	else
		return ..()