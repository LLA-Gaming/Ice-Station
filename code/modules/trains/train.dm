/obj/train
	name = "train"
	icon = 'icons/obj/train.dmi'
	icon_state = "train"
	anchored = 1
	density = 1

	var/obj/train/head
	var/obj/train/tail

	New()
		..()

		head = locate(/obj/train) in get_step(get_turf(src), dir)
		tail = locate(/obj/train) in get_step(get_turf(src), turn(dir, 180))

	examine()
		for(var/i in 1 to 15)
			var/obj/structure/railroad_track/track = locate() in get_turf(src)
			if(track)
				step(src, get_dir(get_turf(src), get_turf(track.GetNextTrack(src))))
			sleep(track.GetMoveDelay())

	Move(var/turf/new_location, var/direction)
		var/previous_dir = dir

		..()

		var/obj/structure/railroad_track/track = locate() in new_location
		if(track)
			dir = track.dir

		if(tail)
			step(tail, previous_dir)
