//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	var/age = text2num(client.player_age)
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version] || Player Age: [age]")
	if(config.log_access)
		for(var/mob/M in world)
			if(!M.key) continue // Skip over mobs that do not have keys
			if(M.ckey == "@[ckey]") continue // Skip over aghosted bodies
			if(M == src)	continue
			if(M.key && (M.key != key))
				var/matches
				if( (M.lastKnownIP == lastKnownIP) )
					matches += "IP ([lastKnownIP])"
				if( (M.computer_id == computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([computer_id])(MULTIKEY)"
					spawn() alert("It appears as though you�ve already logged into this server with a different key this round.  This is something we don�t allow.  We�ve noticed this apparent activity and might have some questions for you.")
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B><font color='blue'>[key_name_admin(src)] has the same [matches] as [key_name_admin(M)].</font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B><font color='blue'>[key_name_admin(src)] has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	player_list |= src
	update_Login_details()
	world.update_status()

	client.images = null				//remove the images such as AIs being unable to see runes
	client.screen = null				//remove hud items just in case
	if(hud_used)	del(hud_used)		//remove the hud objects
	hud_used = new /datum/hud(src)

	next_move = 1
	sight |= SEE_SELF

	if(ckey in deadmins)
		verbs += /client/proc/readmin

	..()

	if(loc && !isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	else
		client.eye = src
		client.perspective = MOB_PERSPECTIVE

	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()

	if(ticker) ticker.stalemate_check() // stalemate check

	if(CURRENT_WEATHER)
		if(CURRENT_WEATHER.current_stage)
			CURRENT_WEATHER.current_stage.HandleLogin(src)

// Calling update_interface() in /mob/Login() causes the Cyborg to immediately be ghosted; because of winget().
// Calling it in the overriden Login, such as /mob/living/Login() doesn't cause this.
/mob/proc/update_interface()
	if(client)
		if(winget(src, "mainwindow.hotkey_toggle", "is-checked") == "true")
			update_hotkey_mode()
		else
			update_normal_mode()

/mob/proc/update_hotkey_mode()
	if(client)
		winset(src, null, "mainwindow.macro=hotkeymode hotkey_toggle.is-checked=true mapwindow.map.focus=true input.background-color=#F0F0F0")

/mob/proc/update_normal_mode()
	if(client)
		winset(src, null, "mainwindow.macro=macro hotkey_toggle.is-checked=false input.focus=true input.background-color=#D3B5B5")


