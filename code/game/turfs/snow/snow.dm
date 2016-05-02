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