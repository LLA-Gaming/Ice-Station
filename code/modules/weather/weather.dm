var/global/datum/weather/CURRENT_WEATHER

/datum/weather
	var/name
	var/datum/weather_stage/current_stage
	var/stages_path = /datum/weather_stage
	var/list/stages = list()

	New()
		var/list/types = typesof(stages_path) - stages_path
		for(var/x in types)
			stages += null

		for(var/path in types)
			var/datum/weather_stage/stage = new path(src)
			stages[stage.stage_index] = stage

	proc/OnStart()
		CURRENT_WEATHER = src
		log_game("Starting weather: [name]")

		return 0

	proc/OnEnd()
		CURRENT_WEATHER = null
		log_game("Weather '[name]' ended.")

		return 0

	proc/Process()
		if(!current_stage)
			current_stage = stages[1]
			current_stage.OnStart()

		if((current_stage.started + current_stage.duration) < world.time)
			// No more stages left, end the weather
			if((current_stage.stage_index + 1) > length(stages))
				OnEnd()
				return 0

			// More stages...progress to next stage
			current_stage = stages[stages.Find(current_stage)]
			current_stage.started = world.time
			current_stage.OnStart()
		else
			current_stage.Process()
