/datum/weather/snowfall
	name = "snowfall"
	stages_path = /datum/weather_stage/snowfall

/datum/weather_stage/snowfall/light_snowing
	name = "snow"
	duration_min = 1000*60*2
	duration_max = 1000*60*7
	stage_index = 1

	GetOverlays()
		return list(WEATHER_OVERLAYS.snow)

	Process()
		if(prob(ice_config.snow_increase_depth_chance))
			var/turf/surface/snow/picked = pick(Z1_SNOW_TURFS)
			do
				picked.SetDepth(picked.depth + 1)
				picked = get_step(picked, pick(cardinal))
			while(prob(ice_config.snow_increase_neighbor_chance))
