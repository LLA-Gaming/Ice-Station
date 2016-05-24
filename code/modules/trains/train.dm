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

	proc/MoveToNextTrack()
		var/obj/structure/railroad_track/track = locate() in get_turf(src)
		if(track)
			step(src, get_dir(get_turf(src), get_turf(track.GetNextTrack(dir))))

	proc/PulledBy(var/obj/train/puller)
		MoveToNextTrack()

/*	Move(var/turf/new_location, var/direction)
		..()

		if(tail)
			tail.PulledBy(src)
*/