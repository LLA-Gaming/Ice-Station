/turf/surface
	icon = 'icons/turf/snow.dmi'
	name = "\proper snow"
	icon_state = "snow0"
	intact = 0

	gasses = list(OXYGEN = MOLES_O2STANDARD, NITROGEN = MOLES_N2STANDARD)
	temperature = TN13C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/surface/New()
	..()
	if(!istype(src, /turf/surface/transit))
		if(prob(20))
			icon_state = "snow[rand(0,12)]"
	update_sunlight()

/turf/surface/proc/update_sunlight()
	for(var/t in RANGE_TURFS(1,src))
		if(istype(t,/turf/simulated))
			set_light(3)
			return
	if(light)
		set_light(0)

/turf/surface/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/surface/attackby(obj/item/C as obj, mob/user as mob)

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