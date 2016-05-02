/datum/weather_stage
	var/name
	var/duration
	var/started
	var/datum/weather/parent
	var/stage_index = 1

	New(var/datum/weather/_parent)
		parent = _parent

	proc/OnStart()
		return 0

	proc/OnEnd()
		return 0

	proc/Process()
		return 0
