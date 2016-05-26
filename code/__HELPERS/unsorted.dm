//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r, 2)
	textg = num2hex(255 - g, 2)
	textb = num2hex(255 - b, 2)
	return text("#[][][]", textr, textg, textb)
	return

//Returns the middle-most value
/proc/dd_range(var/low, var/high, var/num)
	return max(low,min(high,num))


/proc/Get_Angle(atom/movable/start,atom/movable/end)//For beams.
	if(!start || !end) return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination



/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlocked(A,iStep) && !LinkBlocked(iStep,B)) return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlocked(A,pStep) && !LinkBlocked(pStep,B)) return 0
		return 1

	if(DirBlocked(A,adir)) return 1
	if(DirBlocked(B,rdir)) return 1
	return 0


/proc/DirBlocked(turf/loc,var/dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return 1
			if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return 1
		else return 1	// it's a real, air blocking door
	return 0

/proc/TurfBlockedNonWindow(turf/loc)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/window))
			return 1
	return 0

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(var/f)
	f = round(f)
	f = max(1441, f) // 144.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(var/f)
	return "[round(f / 10)].[f % 10]"



//This will update a mob's name, real_name, mind.name, data_core records, pda, id and traitor text
//Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
/mob/proc/fully_replace_character_name(var/oldname,var/newname)
	if(!newname)	return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
	if(istype(src, /mob/living/carbon))
		var/mob/living/carbon/C = src
		if(C.dna)
			C.dna.real_name = real_name

	if(isAI(src))
		var/mob/living/silicon/ai/AI = src
		if(oldname != real_name)
			for(var/mob/living/silicon/robot/Slave in AI.connected_robots)
				Slave.show_laws()

	if(isrobot(src))
		var/mob/living/silicon/robot/R = src
		if(oldname != real_name)
			R.notify_ai(3, oldname, newname)
		if(R.camera)
			R.camera.c_tag = real_name

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(data_core.general,data_core.medical,data_core.security,data_core.locked))
			var/datum/data/record/R = find_record("name", oldname, L)
			if(R)	R.fields["name"] = newname

		//update our pda and id if we have them on our person
		var/list/searching = GetAllContents()
		var/search_id = 1
		var/search_tablet = 1

		for(var/A in searching)
			if( search_id && istype(A,/obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = A
				if(ID.registered_name == oldname)
					ID.registered_name = newname
					ID.update_label()
					if(!search_tablet)	break
					search_id = 0

			else if( search_tablet && istype(A,/obj/item/device/tablet) )
				var/obj/item/device/tablet/tablet = A
				var/obj/item/device/tablet_core/core = tablet.core
				if(core)
					if(core.owner == oldname)
						core.owner = newname
						tablet.update_label()
						if(!search_id)	break
						search_tablet = 0

		for(var/datum/mind/T in ticker.minds)
			for(var/datum/objective/obj in T.objectives)
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()

	return 1



//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
//Last modified by Carn
/mob/proc/rename_self(var/role, var/allow_numbers=0)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			newname = input(src,"You are a [role]. Would you like to change your name to something else?", "Name change",oldname) as text
			if((world.time-time_passed)>300)
				return	//took too long
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			src << "Sorry, that [role]-name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken."

		if(!newname)	//we'll stick with the oldname then
			return

		if(cmptext("ai",role))
			if(isAI(src))
				var/mob/living/silicon/ai/A = src
				oldname = null//don't bother with the records update crap
				//world << "<b>[newname] is the AI!</b>"
				//world << sound('sound/AI/newAI.ogg')
				// Set eyeobj name
				if(A.eyeobj)
					A.eyeobj.name = "[newname] (AI Eye)"

				// Set ai pda name
				if(A.tablet)
					if(A.tablet)
						var/obj/item/device/tablet_core/core = A.tablet.core // variable for interactin with the HDD
						core.owner = newname
						core.name = newname + " (" + core.ownjob + ")"
						A.tablet.update_label()

				// Notify Cyborgs
				for(var/mob/living/silicon/robot/Slave in A.connected_robots)
					Slave.show_laws()

		if(cmptext("cyborg",role))
			if(isrobot(src))
				var/mob/living/silicon/robot/A = src
				A.custom_name = newname

		fully_replace_character_name(oldname,newname)



//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/R in living_mob_list)
		if(R.connected_ai)
			continue
		if(R.stat == DEAD)
			continue
		if(R.emagged || R.scrambledcodes || R.syndicate)
			continue
		. += R

//Returns a list of AI's
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in living_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots > A.connected_robots))
			selected = A

	return selected

/proc/select_active_free_borg(var/mob/user)
	var/list/borgs = active_free_borgs()
	if(borgs.len)
		if(user)	. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in borgs
		else		. = pick(borgs)
	return .

/proc/select_active_ai(var/mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = input(user,"AI signals detected:", "AI Selection", ais[1]) in ais
		else		. = pick(ais)
	return .

//Returns a list of all mobs with their name
/proc/getmobs(var/ignore_mindless=0)

	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		if(ignore_mindless)
			if(!istype(M,/mob/camera/aiEye))
				if(!M.mind && !istype(M, /mob/dead/observer/)) continue
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
			if(M.job in list("Perseus Security Enforcer", "Perseus Security Commander"))
				name = M.name
		if (M.stat == 2)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortAtom(mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
//	for(var/mob/living/silicon/hivebot/M in world)
//		mob_list.Add(M)
//	for(var/mob/living/silicon/hive_mainframe/M in world)
//		mob_list.Add(M)
	for(var/mob/living/carbon/werewolf/WW in sortmob)
		moblist.Add(WW)
	return moblist

//E = MC^2
/proc/convert2energy(var/M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(var/E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/key_name(var/whom, var/include_link = null, var/include_name = 1, var/admin_conversation)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			if(!admin_conversation)
				. += "<a href='?priv_msg=[ckey]'>"
			else
				. += "<a href='?priv_msg=[ckey];conversation=[admin_conversation]'>"

		if(C && C.holder && C.holder.fakekey && !include_name)
			. += "Administrator"
		else
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

	return .

/proc/key_name_admin(var/whom, var/include_name = 1)
	return key_name(whom, 1, include_name)

/proc/get_mob_by_ckey(var/key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M

// Returns the atom sitting on the turf.
// For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
/proc/get_atom_on_turf(var/atom/movable/M)
	var/atom/loc = M
	while(loc && loc.loc && !istype(loc.loc, /turf/))
		loc = loc.loc
	return loc

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)

	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(var/atom/A, var/dx, var/dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

proc/arctan(x)
	var/y=arcsin(x/sqrt(1+x*x))
	return y


proc/anim(turf/location as turf,target as mob|obj,a_icon,a_icon_state as text,flick_anim as text,sleeptime = 0,direction as num)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	var/atom/movable/overlay/animation = new(location)
	if(direction)
		animation.dir = direction
	animation.icon = a_icon
	animation.layer = target:layer+1
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		animation.master = target
		flick(flick_anim, animation)
	sleep(max(sleeptime, 15))
	qdel(animation)


atom/proc/GetAllContents()
	var/list/processing_list = list(src)
	var/list/assembled = list()

	while(processing_list.len)
		var/atom/A = processing_list[1]
		processing_list -= A

		for(var/atom/a in A)
			if(!(a in assembled))
				processing_list |= a

		assembled |= A

	return assembled


atom/proc/GetTypeInAllContents(typepath)
	var/list/processing_list = list(src)
	var/list/processed = list()

	var/atom/found = null

	while(processing_list.len && found==null)
		var/atom/A = processing_list[1]
		if(istype(A, typepath))
			found = A

		processing_list -= A

		for(var/atom/a in A)
			if(!(a in processed))
				processing_list |= a

		processed |= A

	return found


//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(var/atom/source, var/atom/target, var/length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length) return 0
		if(current.opacity) return 0
		for(var/atom/A in current)
			if(A.opacity) return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/is_blocked_turf(var/turf/T)
	var/cant_pass = 0
	if(T.density) cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards2(var/atom/ref , var/atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref,free_tile)

	else return get_step(ref, base_dir)

/proc/do_mob(var/mob/user , var/mob/target, var/time = 30) //This is quite an ugly solution but i refuse to use the old request system.
	if(!user || !target) return 0
	var/user_loc = user.loc
	var/target_loc = target.loc
	var/holding = user.get_active_hand()
	sleep(time)
	if(!user || !target) return 0
	if ( user.loc == user_loc && target.loc == target_loc && user.get_active_hand() == holding && !( user.stat ) && ( !user.stunned && !user.weakened && !user.paralysis && !user.lying ) )
		return 1
	else
		return 0

/proc/do_after(mob/user, delay, numticks = 5, needhand = 1)
	if(!user || isnull(user))
		return 0
	if(numticks == 0)
		return 0

	var/delayfraction = round(delay/numticks)
	var/turf/T = user.loc
	var/holding = user.get_active_hand()
	var/holdingnull = 1
	if(holding)
		holdingnull = 0

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)


		if(!user || user.stat || user.weakened || user.stunned || !(user.loc == T))
			return 0

		if(needhand)	//Sometimes you don't want the user to have to keep their active hand
			if(!holdingnull)
				if(!holding)
					return 0
			if(user.get_active_hand() != holding)
				return 0

	return 1

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(var/datum/A, var/varname)
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

//Returns: all the areas in the world
/proc/return_areas()
	. = list()
	for(var/area/A in world)
		. += A

//Returns: all the areas in the world, sorted.
/proc/return_sorted_areas()
	return sortAtom(return_areas())

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = new/list()
	for(var/area/N in world)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/area/proc/move_contents_to(var/area/A, var/turftoleave=null, var/direction = null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi


					// Give the new turf our air, if simulated
					if(istype(X, /turf/simulated) && istype(T, /turf/simulated))
						var/turf/simulated/sim = X
						sim.copy_air_with_tile(T)

					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.loc = X
						corner.density = 1
						corner.anchored = 1
						corner.icon = X.icon
						corner.icon_state = replacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !istype(nextturf, /turf/space))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)

						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // prevents multiple shuttle corners from stacking
							continue
						if(!istype(O,/obj)) continue
						O.loc = X
					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						M.loc = X

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.set_opacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						var/turf/ttl = new turftoleave(T)

//						var/area/AR2 = ttl.loc

//						if(AR2.dynamic_lighting)						//TODO: rewrite this code so it's not messed by lighting ~Carn
//							ttl.opacity = !ttl.opacity
//							ttl.sd_set_opacity(!ttl.opacity)

						fromupdate += ttl

					else
						T.ChangeTurf(/turf/space)

					refined_src -= T
					refined_trg -= B
					continue moving


	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			air_master.remove_from_active(T1)
			T1.CalculateAdjacentTurfs()
			air_master.add_to_active(T1,1)

	if(fromupdate.len)
		for(var/turf/simulated/T2 in fromupdate)
			air_master.remove_from_active(T2)
			T2.CalculateAdjacentTurfs()
			air_master.add_to_active(T2,1)



proc/DuplicateObject(obj/original, var/perfectcopy = 0 , var/sameloc = 0)
	if(!original)
		return null

	var/obj/O = null

	if(sameloc)
		O=new original.type(original.loc)
	else
		O=new original.type(locate(0,0,0))

	if(perfectcopy)
		if((O) && (original))
			for(var/V in original.vars)
				if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key")))
					O.vars[V] = original.vars[V]
	return O


/area/proc/copy_contents_to(var/area/A , var/platingRequired = 0 )
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()


	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(istype(B, /turf/space))
							continue moving

					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi


					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)

						if(!istype(O,/obj))
							continue

						objs += O


					for(var/obj/O in objs)
						newobjs += DuplicateObject(O , 1)


					for(var/obj/O in newobjs)
						O.loc = X

					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M , 1)

					for(var/mob/M in newmobs)
						M.loc = X

					copiedobjs += newobjs
					copiedobjs += newmobs



					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","contents", "luminosity")))
							X.vars[V] = T.vars[V]

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)
//						X.opacity = !X.opacity
//						X.sd_set_opacity(!X.opacity)			//TODO: rewrite this code so it's not messed by lighting ~Carn

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving


	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			T1.CalculateAdjacentTurfs()
			air_master.add_to_active(T1,1)


	return copiedobjs



proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

//chances are 1:value. anyprob(1) will always return true
proc/anyprob(value)
	return (rand(1,value)==value)

proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else return zone


/proc/get_turf(atom/movable/AM)
	if(istype(AM))
		return locate(/turf) in AM.locs
	else if(isturf(AM))
		return AM

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/stack/cable_coil,
/obj/item/weapon/wrench,
/obj/item/weapon/weldingtool,
/obj/item/weapon/screwdriver,
/obj/item/weapon/wirecutters,
/obj/item/device/multitool,
/obj/item/weapon/crowbar)

/proc/istool(O)
	if(O && is_type_in_list(O, common_tools))
		return 1
	return 0

proc/is_hot(obj/item/W as obj)
	switch(W.type)
		if(/obj/item/weapon/weldingtool)
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				return 3800
			else
				return 0
		if(/obj/item/weapon/lighter)
			if(W:lit)
				return 1500
			else
				return 0
		if(/obj/item/weapon/match)
			if(W:lit)
				return 1000
			else
				return 0
		if(/obj/item/clothing/mask/cigarette)
			if(W:lit)
				return 1000
			else
				return 0
		if(/obj/item/weapon/pickaxe/plasmacutter)
			return 3800
		if(/obj/item/weapon/melee/energy)
			return 3500
		else
			return 0

	return 0

//Is this even used for anything besides balloons? Yes I took out the W:lit stuff because : really shouldnt be used.
/proc/is_sharp(obj/item/W as obj)		// For the record, WHAT THE HELL IS THIS METHOD OF DOING IT?
	return ( \
		istype(W, /obj/item/weapon/screwdriver)                   || \
		istype(W, /obj/item/weapon/pen)                           || \
		istype(W, /obj/item/weapon/weldingtool)					  || \
		istype(W, /obj/item/weapon/lighter/zippo)				  || \
		istype(W, /obj/item/weapon/match)            		      || \
		istype(W, /obj/item/clothing/mask/cigarette) 		      || \
		istype(W, /obj/item/weapon/wirecutters)                   || \
		istype(W, /obj/item/weapon/circular_saw)                  || \
		istype(W, /obj/item/weapon/melee/energy/sword)            || \
		istype(W, /obj/item/weapon/melee/energy/blade)            || \
		istype(W, /obj/item/weapon/shovel)                        || \
		istype(W, /obj/item/weapon/kitchenknife)                  || \
		istype(W, /obj/item/weapon/butch)						  || \
		istype(W, /obj/item/weapon/scalpel)                       || \
		istype(W, /obj/item/weapon/kitchen/utensil/knife)         || \
		istype(W, /obj/item/weapon/shard)                         || \
		istype(W, /obj/item/weapon/broken_bottle)				  || \
		istype(W, /obj/item/weapon/reagent_containers/syringe)    || \
		istype(W, /obj/item/weapon/kitchen/utensil/fork) && W.icon_state != "forkloaded" || \
		istype(W, /obj/item/weapon/twohanded/fireaxe) \
	)

/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	"/obj/machinery/power/apc", "/obj/machinery/alarm", "/obj/item/device/radio/intercom",
	"/obj/structure/extinguisher_cabinet", "/obj/structure/reagent_dispensers/peppertank",
	"/obj/machinery/status_display", "/obj/machinery/requests_console", "/obj/machinery/light_switch", "/obj/effect/sign",
	"/obj/machinery/newscaster", "/obj/machinery/firealarm", "/obj/structure/noticeboard", "/obj/machinery/door_control",
	"/obj/machinery/computer/security/telescreen", "/obj/machinery/embedded_controller/radio/simple_vent_controller",
	"/obj/item/weapon/storage/secure/safe", "/obj/machinery/door_timer", "/obj/machinery/flasher", "/obj/machinery/keycard_auth",
	"/obj/structure/mirror", "/obj/structure/closet/fireaxecabinet", "/obj/machinery/computer/security/telescreen/entertainment"
	)
/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				//Direction works sometimes
				if(O.dir == dir)
					return 1

				//Some stuff doesn't use dir properly, so we need to check pixel instead
				switch(dir)
					if(SOUTH)
						if(O.pixel_y > 10)
							return 1
					if(NORTH)
						if(O.pixel_y < -10)
							return 1
					if(WEST)
						if(O.pixel_x > 10)
							return 1
					if(EAST)
						if(O.pixel_x < -10)
							return 1


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				if(O.pixel_x == 0 && O.pixel_y == 0)
					return 1
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/obj/proc/atmosanalyzer_scan(var/datum/gas_mixture/air_contents, mob/user, var/obj/target = src)
	var/obj/icon = target
	user.visible_message("\red [user] has used the analyzer on \icon[icon] [target].</span>")
	var/pressure = air_contents.return_pressure()
	var/total_moles = air_contents.total_moles()

	user << "\blue Results of analysis of \icon[icon] [target]."
	if(total_moles>0)
		var/o2_concentration = air_contents.gasses[OXYGEN]/total_moles
		var/n2_concentration = air_contents.gasses[NITROGEN]/total_moles
		var/co2_concentration = air_contents.gasses[CARBONDIOXIDE]/total_moles
		var/plasma_concentration = air_contents.gasses[PLASMA]/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

		user << "\blue Pressure: [round(pressure,0.1)] kPa"
		user << "\blue Nitrogen: [round(n2_concentration*100)]%"
		user << "\blue Oxygen: [round(o2_concentration*100)]%"
		user << "\blue CO2: [round(co2_concentration*100)]%"
		user << "\blue Plasma: [round(plasma_concentration*100)]%"
		if(unknown_concentration>0.01)
			user << "\red Unknown: [round(unknown_concentration*100)]%"
		user << "\blue Temperature: [round(air_contents.temperature-T0C)]&deg;C"
	else
		user << "\blue [target] is empty!"
	return

proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || target.lying)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return
	if(initator.dir == target.dir) //mobs are facing the same direction
		return 1
	if(initator.dir + 4 == target.dir || initator.dir - 4 == target.dir) //mobs are facing each other
		return 2
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return 3

/proc/copy_human(var/mob/living/carbon/human/from, var/mob/living/carbon/human/target, var/copyitems = 1, var/ignore_forbidden = 0, var/copyid = 1, var/copyhs = 0)
	target.name = from.name
	target.real_name = from.real_name

	target.hair_color = from.hair_color
	target.hair_style = from.hair_style

	target.facial_hair_color = from.facial_hair_color
	target.facial_hair_style = from.facial_hair_style

	target.eye_color = from.eye_color

	target.skin_tone = from.skin_tone

	target.age = from.age
	target.blood_type = from.blood_type

	target.gender = from.gender

	target.job = from.job

	target.undershirt = from.undershirt
	target.underwear = from.underwear
	target.socks = from.socks

	if(copyitems)
		if(from.w_uniform)
			target.equip_to_slot_or_del(new from.w_uniform.type(target), slot_w_uniform)
		if(from.shoes)
			if(istype(from.shoes, /obj/item/clothing/shoes/combat))
				var/obj/item/clothing/shoes/combat/C = new /obj/item/clothing/shoes/combat()
				C.knife = new /obj/item/weapon/stun_knife(C)
				C.icon_state = "swatk"
				target.equip_to_slot_or_del(C, slot_shoes)
			else
				target.equip_to_slot_or_del(new from.shoes.type(target), slot_shoes)
		if(from.belt)
			target.equip_to_slot_or_del(new from.belt.type(target), slot_belt)
		if(from.gloves)
			target.equip_to_slot_or_del(new from.gloves.type(target), slot_gloves)
		if(from.glasses)
			if(!istype(from.glasses, /obj/item/clothing/glasses/virtual))
				target.equip_to_slot_or_del(new from.glasses.type(target), slot_glasses)
		if(from.head)
			target.equip_to_slot_or_del(new from.head.type(target), slot_head)

		if(from.ears)
			target.equip_to_slot_or_del(new from.ears.type(target), slot_ears)

	/*	if(copyhs)
			if(from.ears)
				target.equip_to_slot_or_del(new from.ears.type(target), slot_ears)
		else
			if(target.ears)	qdel(target.ears)
			target.equip_to_slot_or_del(new /obj/item/device/radio/headset/virtual(target), slot_ears)

			// This really should never be false.
			if(istype(target.ears, /obj/item/device/radio/headset/virtual))
				if(istype(from.ears, /obj/item/device/radio/headset))
					var/obj/item/device/radio/headset/virtual/V = target.ears
					var/obj/item/device/radio/headset/H = from.ears

					if(H.keyslot1)
						V.keyslot1 = new H.keyslot1.type(V)
					if(H.keyslot2)
						V.keyslot2 = new H.keyslot2.type(V)*/

		if(from.r_store)
			target.equip_to_slot_or_del(new from.r_store.type(target), slot_r_store)
		if(from.l_store)
			target.equip_to_slot_or_del(new from.l_store.type(target), slot_l_store)
		if(from.s_store)
			target.equip_to_slot_or_del(new from.s_store.type(target), slot_s_store)
		if(from.s_store)
			target.equip_to_slot_or_del(new from.s_store.type(target), slot_s_store)
		if(from.back)
			var/obj/item/weapon/storage/backpack/B = new from.back.type()
			for(var/obj/item/I in from.back)
				if(I.type in vr_controller.forbidden_types)	continue
				var/obj/item/O = new I.type()
				B.contents += O
			target.equip_to_slot_or_del(B, slot_back)
		if(from.wear_suit)
			target.equip_to_slot_or_del(new from.wear_suit.type(target), slot_wear_suit)
		if(from.wear_mask)
			target.equip_to_slot_or_del(new from.wear_mask.type(target), slot_wear_mask)
		if(from.wear_id)
			if(istype(from.wear_id, /obj/item/weapon/card/id) || (istype(from.wear_id, /obj/item/device/tablet) && copyid))
				if(!istype(from.wear_id, /obj/item/device/tablet))
					var/obj/item/weapon/card/id/X = from.wear_id
					var/obj/item/weapon/card/id/W = new X.type()
					W.name = X.name
					W.assignment = X.assignment
					W.access = X.access
					W.registered_name = X.registered_name
					W.icon_state = X.icon_state
					target.equip_to_slot_or_del(W, slot_wear_id)
				else
					var/obj/item/device/tablet/G = from.wear_id
					if(G.id)
						var/obj/item/weapon/card/id/I = new G.id.type()
						I.name = G.id.name
						I.assignment = G.id.assignment
						I.access = G.id.access
						I.registered_name = G.id.registered_name
						I.icon_state = G.id.icon_state
						target.equip_to_slot_or_del(I, slot_wear_id)

			else if(istype(from.wear_id, /obj/item/device/tablet))
				var/obj/item/device/tablet/G = from.wear_id
				var/obj/item/device/tablet/P = new G.type()
				P.name = G.name
				P.owner = G.owner
				P.ownjob = G.ownjob
				if(G.core)
					P.core = new G.core.type()
				target.equip_to_slot_or_del(P, slot_wear_id)

		for(var/obj/item/weapon/implant/I in from)
			var/obj/item/weapon/implant/A = new I.type(target)
			A.imp_in = target
			A.implanted = 1
	else
		target.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(target), slot_w_uniform)
		target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/orange(target), slot_shoes)
//		target.equip_to_slot_or_del(new /obj/item/weapon/book/manual/security_space_law(target), slot_l_hand)
	if(!ignore_forbidden)
		for(var/obj/item/I in target.get_contents())
			for(var/T in vr_controller.forbidden_types)
				if(istype(I, T))
					qdel(I)
	target.update_icons()
	target.update_hud()


/proc/power_failure()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", 'sound/AI/poweroff.ogg')
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output_level = 0
		S.output_attempt = 0
		S.update_icon()
		S.power_change()

	var/list/skipped_areas = list(/area/engine/engineering, /area/turret_protected/ai)

	for(var/area/A in world)
		if( !A.requires_power || A.always_unpowered )
			continue

		var/skip = 0
		for(var/area_type in skipped_areas)
			if(istype(A,area_type))
				skip = 1
				break
		if(A.contents)
			for(var/atom/AT in A.contents)
				if(AT.z != 1) //Only check one, it's enough.
					skip = 1
				break
		if(skip) continue
		A.power_light = 0
		A.power_equip = 0
		A.power_environ = 0
		A.power_change()

	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			var/area/A = get_area(C)

			var/skip = 0
			for(var/area_type in skipped_areas)
				if(istype(A,area_type))
					skip = 1
					break
			if(skip) continue

			C.cell.charge = 0

/proc/power_restore()

	priority_announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.update_icon()
		S.power_change()
	for(var/area/A in world)
		if(!istype(A, /area/space) && !istype(A, /area/shuttle) && !istype(A,/area/arrival))
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()

/proc/power_restore_quick(var/no_announce=0,var/limited=0)

	if(!no_announce)
		priority_announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in machines)
		if(S.z != 1)
			continue
		if(limited)
			var/area/A = get_area(S)
			if(!istype(A,/area/engine/engine_smes))
				continue
		S.charge = S.capacity
		if(limited)
			S.output_level = S.output_level_max / 2
		else
			S.output_level = S.output_level_max
		S.output_attempt = 1
		S.update_icon()
		S.power_change()

/var/mob/dview/dview_mob = new

//Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

/mob/dview
	invisibility = 101
	density = 0
	see_in_dark = 1e6
	anchored = 1
