/datum/weather_stage
	var/name
	var/duration = 0
	var/duration_min = 0
	var/duration_max = 0
	var/started = 0
	var/datum/weather/parent
	var/stage_index = 1

	New(var/datum/weather/_parent)
		parent = _parent
		duration = rand(duration_min, duration_max)

	proc/OnStart()
		started = world.time

		for(var/image/I in GetOverlays())
			THE_SURFACE.overlays += I

		return 0

	proc/OnEnd()
		for(var/image/I in GetOverlays())
			THE_SURFACE.overlays -= I

		return 0

	proc/HandleLogin(var/mob/living/L)
		return 0

	proc/Process()
		return 0

	proc/GetOverlays()
		return list()