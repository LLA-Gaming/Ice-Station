#define WEATHER_EFFECTS_LAYER 100

var/global/datum/weather_overlays/WEATHER_OVERLAYS = new()

/datum/weather_overlays
	var/image/snow

	New()

		/*
		* SNOW
		*/

		snow = image(icon = 'icons/effects/weather.dmi', icon_state = "snow")
		snow.layer = WEATHER_EFFECTS_LAYER
		snow.blend_mode = BLEND_ADD

		/*
		* Hail
		*/


		/*
		* Fog
		*/


