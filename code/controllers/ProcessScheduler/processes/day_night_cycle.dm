/datum/controller/process/day_night_cycle
	var/current_hour = 0
	var/time_since_hour_changed = 0
	var/image/area_overlay

	setup()
		name = "weather"
		schedule_interval = 50

		area_overlay = image(icon = 'icons/effects/white.dmi', icon_state = "white")
		area_overlay.blend_mode = BLEND_MULTIPLY
		THE_SURFACE.overlays += area_overlay

	doWork()
		if(world.time > (time_since_hour_changed + ice_config.hour_duration))
			if((current_hour + 1) > ice_config.hours_in_day)
				current_hour = 0
			else
				current_hour++
			time_since_hour_changed = world.time

		var/brightness_percent = (0.5 * cos(ToDegrees((current_hour - 12) * (PI / (ice_config.hours_in_day / 2)))) + 0.5)

		area_overlay.color = list(
								   brightness_percent,// * (1 - 0.2) + 0.2, // rr
								   brightness_percent,// * (1 - 0.05) + 0.05, // rg
								   brightness_percent,// * (1 - 0.05) + 0.05,  // rb

								   brightness_percent,// * (1 - 0.1) + 0.1, // gr
								   brightness_percent,// * (1 - 0.3) + 0.3,  // gg
								   brightness_percent,// * (1 - 0.2) + 0.2, // gb

								   brightness_percent,// * (1 - 0.1) + 0.1, // br
								   brightness_percent,// * (1 - 0.1) + 0.1,  // bg
								   brightness_percent,// * (1 - 0.4) + 0.4 // bb
							)

		THE_SURFACE.overlays.Cut(2, 3)
		THE_SURFACE.overlays += area_overlay
