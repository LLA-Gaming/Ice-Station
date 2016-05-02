/datum/controller/process/weather
	var/interval_min = 1000*60*15
	var/interval_max = 1000*60*25
	var/next_weather
	var/list/weather_types = list()

	setup()
		name = "weather"
		schedule_interval = PROCESS_DEFAULT_SCHEDULE_INTERVAL
		for(var/path in typesof(/datum/weather) - /datum/weather)
			weather_types += path

	doWork()
		if(!next_weather)
			next_weather = world.time + rand(interval_min, interval_max)

		if(!length(weather_types))
			kill()
			return

		if(CURRENT_WEATHER)
			setLastTask("process()", "[CURRENT_WEATHER.type]")
			CURRENT_WEATHER.Process()
			scheck()
		else
			var/picked = pick(weather_types)
			CURRENT_WEATHER = new picked()
			CURRENT_WEATHER.OnStart()