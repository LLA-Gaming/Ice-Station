/obj/structure/railroad_track
	name = "railroad track"
	icon = 'icons/obj/tracks.dmi'
	icon_state = "track"
	anchored = 1

	proc/GetNextTrack(var/direction)
		var/list/next_track = list()

		if(dir in cardinal)
			next_track[dir2text(dir)] = locate(/obj/structure/railroad_track) in get_step(src, dir)
			next_track[dir2text(turn(dir, 180))] = locate(/obj/structure/railroad_track) in get_step(src, turn(dir, 180))

		else if(dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			next_track[dir2text(turn(dir, -45))] = locate(/obj/structure/railroad_track) in get_step(src, turn(dir, -135))
			next_track[dir2text(turn(dir, 45))] = locate(/obj/structure/railroad_track) in get_step(src, turn(dir, 135))

		return next_track[dir2text(direction)]

	proc/GetMoveDelay()
		return 2.5
