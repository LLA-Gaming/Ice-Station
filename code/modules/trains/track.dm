/obj/structure/railroad_track
	name = "railroad track"
	icon = 'icons/obj/tracks.dmi'
	icon_state = "track"
	anchored = 1

	var/list/next_track = list()

	New()
		..()

		spawn(10)
			UpdateNearbyTracks()

	proc/UpdateNearbyTracks()
		if(dir in cardinal)
			var/turf/t1 = get_step(src, dir)
			next_track[dir2text(dir)] = locate(/obj/structure/railroad_track) in t1

			var/turf/t2 = get_step(src, turn(dir, 180))
			next_track[dir2text(turn(dir, 180))] = locate(/obj/structure/railroad_track) in t2

		if(dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			next_track[dir2text(turn(dir, -135))] = locate(/obj/structure/railroad_track) in get_step(src, turn(dir, -135))
			next_track[dir2text(turn(dir, 135))] = locate(/obj/structure/railroad_track) in get_step(src, turn(dir, 135))

			sleep(50)

			var/obj/structure/railroad_track/track = next_track[dir2text(turn(dir, -135))]
			var/turf/location = get_turf(track)
			location.color = rgb(255, 255, 0)

	proc/GetNextTrack(var/obj/train/train)
		if(next_track.Find(dir2text(train.dir)))
			return next_track[dir2text(train.dir)]
		return next_track[1]

	proc/GetMoveDelay()
		return 10
