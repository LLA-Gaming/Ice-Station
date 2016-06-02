/datum/weather/hail
	name = "hail"
	stages_path = /datum/weather_stage/hail

/datum/weather_stage/hail/hailing
	name = "hail"
	duration_min = 1000*60*2
	duration_max = 1000*60*7
	stage_index = 1

	GetOverlays()
		return list()

	Process()
		for(var/mob/living/L in THE_SURFACE)
			if(!L.IsProtectedFromHail())
				L.apply_damage(ice_config.hail_damage)