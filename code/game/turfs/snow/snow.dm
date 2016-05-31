// Global for easy access

var/global/list/Z1_SURFACE_TURFS = list()
var/global/list/Z1_SNOW_TURFS = list()

/turf/surface
	icon = 'icons/turf/snow.dmi'
	name = "surface"
	icon_state = "snow0"
	intact = 0

	gasses = list(OXYGEN = MOLES_O2STANDARD, NITROGEN = MOLES_N2STANDARD)
	temperature = TN13C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	proc/update_icon()
		return 0

	New()
		..()

		update_icon()
		if(z == 1)
			Z1_SURFACE_TURFS += src
	update_sunlight()

	proc/update_sunlight()
		for(var/t in RANGE_TURFS(1,src))
			if(istype(t,/turf/simulated))
				set_light(ice_config.sunlight_intensity)
				return
		if(light)
			set_light(0)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attackby(obj/item/C as obj, mob/user as mob)
		if (istype(C, /obj/item/stack/rods))
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return
			var/obj/item/stack/rods/R = C
			user << "\blue Constructing support lattice ..."
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
			R.use(1)
			return

		if (istype(C, /obj/item/stack/tile/plasteel))
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				var/obj/item/stack/tile/plasteel/S = C
				qdel(L)
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				S.build(src)
				S.use(1)
				return
			else
				user << "\red The plating is going to need some support."
		return

	/*
	* Snow
	*/

	snow/
		New()
			..()

			if(z == 1)
				Z1_SNOW_TURFS += src

		var/depth = 1

		update_icon()
			icon_state = "snow[depth]"
			if(prob(20))
				var/image/overlay = image(icon = icon, icon_state = "debris[rand(0, 12)]")
				overlay.plane = src.plane
				overlays.Add(overlay)

		examine()
			..()

			switch(depth)
				if(1 to 2)
					usr << "This snow looks shallow."
				if(3 to 4)
					usr << "This snow looks to be about knee-height."
				if(5 to 6)
					usr << "This snow looks to be about waist-height."
				if(7 to 8)
					usr << "This snow looks to be about human-height."

		proc/SetDepth(var/new_depth)
			depth = new_depth
			update_icon()

