/turf/surface/transit
	var/pushdirection // push things that get caught in the transit tile this direction

//Overwrite because we dont want people building rods in space.
/turf/surface/transit/attackby(obj/O as obj, mob/user as mob)
	return

/turf/surface/transit/north // moving to the north
	icon_state = "snowtransitnorth"
	pushdirection = SOUTH  // south because the space tile is scrolling south

/turf/surface/transit/east // moving to the east
	icon_state = "snowtransiteast"
	pushdirection = WEST
