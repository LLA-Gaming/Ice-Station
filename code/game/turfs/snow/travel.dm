//blatant copy pasta from space.dm

/turf/surface/Entered(atom/movable/A as mob|obj)
	if(movement_disabled)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	..()
	if ((!(A) || src != A.loc))	return

	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if(A.z > MAX_Z_LEVELS) return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(A, /obj/effect/meteor))
				qdel(A)
				return

			if(istype(A, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks travel Z levels  ... And moving this shit down here so it only fires when they're actually trying to change z-level.
				qdel(A) //The disk's Del() proc ensures a new one is created
				return

			var/list/disk_search = A.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(disk_search))
				if(istype(A, /mob/living))
					var/mob/living/MM = A
					if(MM.client && !MM.stat)
						MM << "\red Something you are carrying is preventing you from leaving. Don't play stupid; you know exactly what it is."
						if(MM.x <= TRANSITIONEDGE)
							MM.inertia_dir = 4
						else if(MM.x >= world.maxx -TRANSITIONEDGE)
							MM.inertia_dir = 8
						else if(MM.y <= TRANSITIONEDGE)
							MM.inertia_dir = 1
						else if(MM.y >= world.maxy -TRANSITIONEDGE)
							MM.inertia_dir = 2
					else
						for(var/obj/item/weapon/disk/nuclear/N in disk_search)
							qdel(N)//Make the disk respawn it is on a clientless mob or corpse
				else
					for(var/obj/item/weapon/disk/nuclear/N in disk_search)
						qdel(N)//Make the disk respawn if it is floating on its own
				return

			var/move_to_z = src.z
			var/safety = 1

			//Check if it's a mob pulling an object
			var/obj/was_pulling = null
			var/mob/living/MOB = null
			if(isliving(A))
				MOB = A
				if(MOB.pulling)
					was_pulling = MOB.pulling //Store the object to transition later

			var/direction
			if(x <= TRANSITIONEDGE)
				direction = WEST
			else if(x >= (world.maxx - TRANSITIONEDGE - 1))
				direction = EAST
			else if(src.y <= TRANSITIONEDGE)
				direction = SOUTH
			else if(A.y >= (world.maxy - TRANSITIONEDGE - 1))
				direction = NORTH

			move_to_z = space_grid.GetDirectionalZ(move_to_z, direction)
			while(move_to_z == src.z)
				var/move_to_z_str = pickweight(accessable_z_levels)
				move_to_z = text2num(move_to_z_str)
				safety++
				if(safety > 10)
					break

			if(!move_to_z)
				return

			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE + 1
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)




			spawn (0)
				if(was_pulling && MOB) //Carry the object they were pulling over when they transition
					was_pulling.loc = MOB.loc
					MOB.pulling = was_pulling
					was_pulling.pulledby = MOB
				if ((A && A.loc))
					A.loc.Entered(A)