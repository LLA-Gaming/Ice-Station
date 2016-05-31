var/datum/space_exploration_config/ice/ice_config = new()

/datum/space_exploration_config/ice
	category = "Ice"
	file = "config/ice_config.txt"

	var/snow_slowdown_factor
	var/hour_duration
	var/hours_in_day