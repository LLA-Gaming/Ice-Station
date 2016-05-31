var/datum/configuration/ice/ice_config = new()

/datum/configuration/ice
	category = "Ice"
	file = "config/ice_config.txt"

	var/snow_slowdown_factor
	var/sunlight_intensity
	var/instant_lighting