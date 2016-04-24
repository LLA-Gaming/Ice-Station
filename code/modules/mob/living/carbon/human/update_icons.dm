	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations()			//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_base_icon_state()	//Handles updating var/base_icon_state (WIP) This is used to update the
									mob's icon_state easily e.g. "[base_icon_state]_s" is the standing icon_state
		update_body()				//Handles updating your mob's icon_state (using update_base_icon_state())
									as well as sprite-accessories that didn't really fit elsewhere (underwear, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())

>	I repurposed an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.
	//NOTE: fairly unused, maybe this could be removed?

If you have any questions/constructive-comments/bugs-to-report
Please contact me on #coderbus IRC. ~Carnie x
//Carn can sometimes be hard to reach now. However IRC is still your best bet for getting help.
*/

//Human Overlays Indexes/////////
#define LIMB_LAYER				23
#define BODY_LAYER				22		//underwear, undershirts, socks, eyes, lips(makeup)
#define MUTATIONS_LAYER			21		//Tk headglows etc.
#define DAMAGE_LAYER			20		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			19
#define ID_LAYER				18
#define SHOES_LAYER				17
#define EARS_LAYER				16
#define SUIT_LAYER				15
#define ARM_LAYER				14
#define GLOVES_LAYER			13
#define GLASSES_LAYER			12
#define BELT_LAYER				11		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		10
#define BACK_LAYER				9
#define HAIR_LAYER				8		//TODO: make part of head layer?
#define FACEMASK_LAYER			7
#define HEAD_LAYER				6
#define HANDCUFF_LAYER			5
#define LEGCUFF_LAYER			4
#define L_HAND_LAYER			3
#define R_HAND_LAYER			2		//Having the two hands seperate seems rather silly, merge them together? It'll allow for code to be reused on mobs with arbitarily many hands
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			23		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
//////////////////////////////////
/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/human/proc/update_base_icon_state()
	var/race = dna ? dna.mutantrace : null
	switch(race)
		if("lizard","golem","slime","shadow","adamantine","fly","plant")
			base_icon_state = "[dna.mutantrace]_[(gender == FEMALE) ? "f" : "m"]"
		if("skeleton")
			base_icon_state = "skeleton"
		else
			if(HUSK in mutations)
				base_icon_state = "husk"
			else
				base_icon_state = "human_[(gender == FEMALE) ? "f" : "m"]"
	//icon_state = "[base_icon_state]_s"


/mob/living/carbon/human/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/human/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

//UPDATES OVERLAYS FROM OVERLAYS_STANDING
//TODO: Remove all instances where this proc is called. It used to be the fastest way to swap between standing/lying.
/mob/living/carbon/human/update_icons()

	update_hud()		//TODO: remove the need for this

	if(overlays.len != overlays_standing.len)
		overlays.Cut()

		for(var/thing in overlays_standing)
			if(thing)	overlays += thing

	update_transform()


//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/image/standing	= image("icon"='icons/mob/dam_human.dmi', "icon_state"="blank", "layer"=-DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing

	for(var/obj/item/organ/limb/O in organs)
		if(O.brutestate)
			standing.overlays	+= "[O.icon_state]_[O.brutestate]0"	//we're adding icon_states of the base image as overlays
		if(O.burnstate)
			standing.overlays	+= "[O.icon_state]_0[O.burnstate]"

	apply_overlay(DAMAGE_LAYER)


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	//mutants don't have hair. masks and helmets can obscure our hair too.
	if( (HUSK in mutations) || (dna && dna.mutantrace) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) )
		return
	//base icons
	var/datum/sprite_accessory/S
	var/list/standing	= list()
	if(facial_hair_style)
		S = facial_hair_styles_list[facial_hair_style]
		if(S)
			var/image/img_facial_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			var/new_color = "#" + facial_hair_color
			img_facial_s.color = new_color
			if(head && (head.flags & BLOCKHAIR))
				standing	+= hide_hair(S.icon_state, S.icon, HAIR_LAYER)
			else
				standing	+= img_facial_s

	//Applies the debrained overlay if there is no brain
	if(!getorgan(/obj/item/organ/brain))
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s", "layer" = -HAIR_LAYER)
	else if(hair_style)
		S = hair_styles_list[hair_style]
		if(S)
			var/image/img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			var/new_color = "#" + hair_color
			img_hair_s.color = new_color
			if(head && (head.flags & BLOCKHAIR))
				standing	+= hide_hair(S.icon_state, S.icon, HAIR_LAYER)
			else
				standing	+= img_hair_s

	if(standing.len)
		overlays_standing[HAIR_LAYER]	= standing

	apply_overlay(HAIR_LAYER)


/mob/living/carbon/human/update_mutations()
	remove_overlay(MUTATIONS_LAYER)

	var/list/standing	= list()

	var/g = (gender == FEMALE) ? "f" : "m"
	for(var/mut in mutations)
		switch(mut)
			if(HULK)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="hulk_[g]_s", "layer"=-MUTATIONS_LAYER)
			if(COLD_RESISTANCE)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_s", "layer"=-MUTATIONS_LAYER)
			if(TK)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_s", "layer"=-MUTATIONS_LAYER)
			if(LASER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_s", "layer"=-MUTATIONS_LAYER)
	if(standing.len)
		overlays_standing[MUTATIONS_LAYER]	= standing

	apply_overlay(MUTATIONS_LAYER)


/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)

	update_base_icon_state()
	//icon_state = "[base_icon_state]_s"

	update_limbs()

	var/list/standing	= list()

	//Mouth	(lipstick!)
	if(lip_style)
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[lip_style]_s", "layer" = -BODY_LAYER)

	//Eyes
	if(!dna || dna.mutantrace != "skeleton")
		var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s", "layer" = -BODY_LAYER)

		var/new_color = "#" + eye_color

		img_eyes_s.color = new_color

		standing	+= img_eyes_s

	//Underwear
	if(socks)
		var/datum/sprite_accessory/socks/U3 = socks_list[socks]
		if(U3)
			standing	+= image("icon"=U3.icon, "icon_state"="[U3.icon_state]_s", "layer"=-BODY_LAYER)

	if(underwear)
		var/datum/sprite_accessory/underwear/U = underwear_all[underwear]
		if(U)
			if(gender == FEMALE)
				standing	+=	wear_female_version(U.icon_state, U.icon, BODY_LAYER)
			else
				standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)

	if(undershirt)
		var/datum/sprite_accessory/undershirt/U2 = undershirt_list[undershirt]
		if(U2)
			if(gender == FEMALE)
				standing	+=	wear_female_version(U2.icon_state, U2.icon, BODY_LAYER)
			else
				standing	+= image("icon"=U2.icon, "icon_state"="[U2.icon_state]_s", "layer"=-BODY_LAYER)

	if(standing.len)
		overlays_standing[BODY_LAYER]	= standing

	apply_overlay(BODY_LAYER)


/mob/living/carbon/human/update_fire()

	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)

/*
/mob/living/carbon/human/proc/update_augments()
	remove_overlay(AUGMENTS_LAYER)

	var/list/standing	= list()


	if(getlimb(/obj/item/organ/limb/robot/r_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_arm_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_arm_s", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/r_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_leg_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_leg_s", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/chest))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="chest_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/head))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="head_s", "layer"=-AUGMENTS_LAYER)

	if(standing.len)
		overlays_standing[AUGMENTS_LAYER]	= standing

	apply_overlay(AUGMENTS_LAYER)
*/


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)		return
	update_body()
	update_hair()
	update_mutations()
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_fire()
	update_transform()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	update_limbs()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		var/t_color = w_uniform.item_color
		if(!t_color)		t_color = icon_state
		var/image/standing	= image("icon"='icons/mob/uniform.dmi', "icon_state"="[t_color]_s", "layer"=-UNIFORM_LAYER)
		overlays_standing[UNIFORM_LAYER]	= standing

		var/G = (gender == FEMALE) ? "f" : "m"
		if(G == "f" && U.fitted == 1)
//			var/index = "[t_color]_s"
//			var/icon/female_clothing_icon = female_clothing_icons[index]
//			if(!female_clothing_icon ) 	//Create standing/laying icons if they don't exist
//				generate_female_clothing(index,t_color)
			standing	= wear_female_version(t_color, 'icons/mob/uniform.dmi', UNIFORM_LAYER)
			overlays_standing[UNIFORM_LAYER]	= standing

		if(w_uniform.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")

		if(U.hastie)
			var/tie_color = U.hastie.item_color
			if(!tie_color) tie_color = U.hastie.icon_state
			var/image/I = image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]")
			I.color = U.hastie.color
			standing.overlays	+= I
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			unEquip(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id	//TODO
		if(client && hud_used)
			client.screen += wear_id

		overlays_standing[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		if(!wear_suit || wear_suit.arm_mask != "none")

			var/t_state = gloves.item_state
			if(!t_state)	t_state = gloves.icon_state
			var/image/standing	= image("icon"='icons/mob/hands.dmi', "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)
			overlays_standing[GLOVES_LAYER]	= standing

			if(gloves.blood_DNA)
				standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")
	else
		if(blood_DNA)
			overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

	apply_overlay(GLOVES_LAYER)



/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		overlays_standing[GLASSES_LAYER]	= image("icon"='icons/mob/eyes.dmi', "icon_state"="[glasses.icon_state]", "layer"=-GLASSES_LAYER)

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(ears)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				ears.screen_loc = ui_ears			//...draw the item in the inventory screen
			client.screen += ears					//Either way, add the item to the HUD

		overlays_standing[EARS_LAYER] = image("icon"='icons/mob/ears.dmi', "icon_state"="[ears.icon_state]", "layer"=-EARS_LAYER)

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing	= image("icon"='icons/mob/feet.dmi', "icon_state"="[shoes.icon_state]", "layer"=-SHOES_LAYER)
		overlays_standing[SHOES_LAYER]	= standing

		if(shoes.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(s_store)
		s_store.screen_loc = ui_sstore1		//TODO
		if(client && hud_used)
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)

	apply_overlay(SUIT_STORE_LAYER)



/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)				//if the inventory is open ...
				head.screen_loc = ui_head		//TODO	//...draw the item in the inventory screen
			client.screen += head						//Either way, add the item to the HUD

		var/image/standing = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		standing.color = head.color // For now, this is here solely for kitty ears, but everything should do this eventually
		standing.alpha = head.alpha

		overlays_standing[HEAD_LAYER]	= standing

		if(head.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used)
			client.screen += belt

		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		overlays_standing[BELT_LAYER]	= image("icon"='icons/mob/belt.dmi', "icon_state"="[t_state]", "layer"=-BELT_LAYER)

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	update_limbs()
	update_inv_gloves()

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/image/standing	= image("icon"='icons/mob/suit.dmi', "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			unEquip(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood")

		if(wear_suit.color)
			standing.color = wear_suit.color

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1	//TODO
		if(client && hud_used)
			client.screen += l_store
	if(r_store)
		r_store.screen_loc = ui_storage2	//TODO
		if(client && hud_used)
			client.screen += r_store


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)				//if the inventory is open ...
				wear_mask.screen_loc = ui_mask	//TODO	//...draw the item in the inventory screen
			client.screen += wear_mask					//Either way, add the item to the HUD

		var/image/standing	= image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)
		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")


	apply_overlay(FACEMASK_LAYER)



/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back

		overlays_standing[BACK_LAYER]	= image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)

	apply_overlay(BACK_LAYER)



/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		if(hud_used)	//hud handcuff icons
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="markus")
			L.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="gabrielle")

		overlays_standing[HANDCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
	else
		if(hud_used)
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays = null
			L.overlays = null

	apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)

	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)

/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	var/obj/item/organ/limb/L = get_organ("r_arm")
	if(L.state_flags & ORGAN_MISSING)
		drop_r_hand()
		return 0
	if (handcuffed)
		drop_r_hand()
		return
	if(r_hand)
		r_hand.screen_loc = ui_rhand	//TODO
		if(client)
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_standing[R_HAND_LAYER] = image("icon" = GetHeldIconFile("right", t_state), "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)

/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	var/obj/item/organ/limb/L = get_organ("l_arm")
	if(L.state_flags & ORGAN_MISSING)
		drop_l_hand()
		return 0
	if (handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		l_hand.screen_loc = ui_lhand	//TODO
		if(client)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_standing[L_HAND_LAYER] = image("icon" = GetHeldIconFile("left", t_state), "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

/mob/living/carbon/human/proc/wear_female_version(t_color, icon, layer)
	var/index = "[t_color]_s"
	var/icon/female_clothing_icon = female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index,t_color,icon)
	var/standing	= image("icon"=female_clothing_icons["[t_color]_s"], "layer"=-layer)
	return(standing)

/mob/living/carbon/human/proc/hide_hair(t_color, icon, layer)
	var/index = "[t_color]_s"
	var/icon/hairbang_icon = hairbang_icons[index]
	if(!hairbang_icon) 	//Create standing/laying icons if they don't exist
		generate_bangs(index,t_color,icon)
	var/image/standing	= image("icon"=hairbang_icons["[t_color]_s"], "layer"=-layer)
	var/new_color = "#" + hair_color
	standing.color = new_color
	return(standing)


//Limbs!
/mob/living/carbon/human/proc/update_limbs()
	icon_state = ""//Reset here as apposed to having a null one due to some getFlatIcon calls at roundstart.

	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(LIMB_LAYER)

	//LOAD ICONS
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache()
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/organ/limb/L in organs)
		var/image/temp = generate_limb_icon(L)
		if(temp)
			new_limbs += temp

	if(new_limbs.len)
		overlays_standing[LIMB_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(LIMB_LAYER)
	update_damage_overlays()
	update_inv_gloves()

/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- race (a local variable to these procs which simplifies mutantraces for these procs)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste

	See RemieRichards on irc.rizon.net #coderbus
*/
//You might already be able to tell, this icon cache code is by RemieRichards of TGstation. If you found this RR, thanks.

var/global/list/limb_icon_cache = list()
var/global/list/arm_icon_cache = list()

/mob/living/carbon/human
	var/icon_render_key = ""

//simplifies species and mutations into one var
/mob/living/carbon/human/proc/get_race()
	var/sm_type = "human"
	//TODO: add support for fly, skeleton, and slime people
	if(HULK in mutations)
		sm_type = "hulk"
	if(HUSK in mutations)
		sm_type = "husk"

	return sm_type


//produces a key based on the human's limbs
/mob/living/carbon/human/proc/generate_icon_render_key()
	var/race = get_race()

	. = "[race]"

	switch(race)
		if("human")
			. += "-coloured-[skin_tone]"
		if("plant")
			. += "-coloured"
		if("lizard")
			. += "-coloured"
		else
			. += "-not_coloured"

	. += "-[gender]"

	for(var/obj/item/organ/limb/L in organs)
		. += "-[initial(L.name)]"
		if(L.state_flags & ORGAN_MISSING)
			. += "-removed"
		else
			. += "-fine"
			if(L.status == ORGAN_ORGANIC)
				. += "-organic"
			else
				. += "-robotic"
	var/arm_mask
	if(w_uniform)
		arm_mask = w_uniform.arm_mask
	if(wear_suit)
		arm_mask = wear_suit.arm_mask
	if(arm_mask)
		. += "-mask[arm_mask]"



//change the human's icon to the one matching it's key
/mob/living/carbon/human/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(LIMB_LAYER)
		overlays_standing[LIMB_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(LIMB_LAYER)


//draws an icon from a limb
/mob/living/carbon/human/proc/generate_limb_icon(var/obj/item/organ/limb/affecting)
	if(affecting.state_flags & ORGAN_MISSING)
		return 0

	var/image/I
	var/should_draw_gender = FALSE
	var/icon_gender = (gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable
	var/race = get_race() //simplified physical appearence of mob
	var/should_draw_greyscale = FALSE
	var/arm_mask

	if(race == "adamantine") //temporary.
		race = "golem"

	var/_layer = -LIMB_LAYER

	if(affecting.body_part == HEAD || affecting.body_part == CHEST)
		should_draw_gender = TRUE

	if(affecting.body_part == ARM_LEFT || affecting.body_part == ARM_RIGHT)
		if(undershirt != "Nude")
			var/datum/sprite_accessory/undershirt/S = undershirt_list[undershirt]
			if(S)
				arm_mask = S.arm_mask
		if(w_uniform && w_uniform.arm_mask != "full")
			arm_mask = w_uniform.arm_mask
		if(wear_suit && wear_suit.arm_mask != "full")
			arm_mask = wear_suit.arm_mask
		_layer = -ARM_LAYER

	if(race == "human" || race == "hulk")
		should_draw_greyscale = TRUE

	if(!arm_mask)
		if(affecting.status == ORGAN_ORGANIC)
			if(should_draw_greyscale)
				if(should_draw_gender)
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_s", "layer"=_layer)
				else
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=_layer)
			else
				if(should_draw_gender)
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_s", "layer"=_layer)
				else
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=_layer)
		else
			if(should_draw_gender)
				I = image("icon"='icons/mob/augments.dmi', "icon_state"="[affecting.name]_[icon_gender]_s", "layer"=_layer)
			else
				I = image("icon"='icons/mob/augments.dmi', "icon_state"="[affecting.name]_s", "layer"=_layer)

	//apply arm mask
	else
		if(arm_mask == "full")
			I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=_layer)
		else if(arm_mask != "none")
			var/index = "[race]_[affecting.name]_[arm_mask]"
			var/icon/arm_mask_icon = arm_icon_cache[index]
			if(!arm_mask_icon)
				var/icon/new_arm_mask	= icon("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s")
				var/icon/new_alpha		= icon("icon"='icons/mob/human_parts.dmi', "icon_state"="[arm_mask]_[affecting.name]")
				new_arm_mask.Blend(new_alpha, ICON_MULTIPLY)
				new_arm_mask			= fcopy_rsc(new_arm_mask)
				arm_icon_cache[index] = new_arm_mask
			I = image("icon"=arm_icon_cache[index], "layer"=_layer)
		else
			return 0

	if(affecting.status == ORGAN_ROBOTIC)
		if(I)
			return I //We're done here

	if(!should_draw_greyscale)
		if(I)
			return I //We're done here
		return 0


	//Greyscale Colouring
	var/draw_color = skintone2hex(skin_tone)
	if(race == "hulk")
		draw_color = skintone2hex("hulk")

	if(draw_color)
		I.color = "#[draw_color]"
	//End Greyscale Colouring

	if(I)
		return I
	return 0


/proc/skintone2hex(var/skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"
		if("hulk")
			. = "158202"




//Human Overlays Indexes/////////
#undef BODY_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef UNIFORM_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
#undef HAIR_LAYER
#undef HEAD_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef L_HAND_LAYER
#undef R_HAND_LAYER
#undef FIRE_LAYER
#undef TOTAL_LAYERS
