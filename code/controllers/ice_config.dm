var/datum/configuration/ice/ice_config = new()

/datum/configuration/ice
	category = "Ice"
	file = "config/ice_config.txt"

	// Environment
	var/snow_slowdown_factor

	// Lighting
	var/sunlight_intensity
	var/instant_lighting

	// Weather
	var/lightning_strike_chance
	var/lightnings_per_chance
	var/snow_increase_depth_chance
	var/snow_increase_neighbor_chance
	var/hail_damage
	var/fog_chill_minimum_bodytemp
	var/fog_chill_bodytemp_loss_rate