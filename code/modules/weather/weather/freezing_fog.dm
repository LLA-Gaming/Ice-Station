/datum/weather/freezing_fog
	name = "freezing fog"
	stages_path = /datum/weather_stage/freezing_fog

/datum/weather_stage/freezing_fog/fog
	name = "freezing fog"
	duration_min = 1000*60*2
	duration_max = 1000*60*7
	stage_index = 1

	GetOverlays()
		return list()

	Process()
		for(var/mob/living/L in THE_SURFACE)
			L.bodytemperature = max((L.bodytemperature - ice_config.fog_chill_bodytemp_loss_rate), ice_config.fog_chill_minimum_bodytemp)