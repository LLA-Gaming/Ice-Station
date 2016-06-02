/obj/effect/lightning_bolt
	name = "lightning bolt"
	icon = 'icons/effects/lightning_bolt.dmi'
	icon_state = "bolt1"
	bound_height = 32*6
	bound_width = 32*3

	New()
		..()
		icon_state = "bolt[rand(1, 1)]"

		sleep(2)

		explosion(get_turf(src), 0, 0, 1, 0, 0, 0, 2, 1)

		for(var/mob/living/M in view(7, src))
			M.flash_eyes()

		sleep(12)

		qdel(src)

/datum/weather/lightning_storm
	name = "lightning storm"
	stages_path = /datum/weather_stage/lightning_storm

/datum/weather_stage/lightning_storm/lightning
	name = "lightning"
	duration_min = 1000*60*2
	duration_max = 1000*60*6
	stage_index = 1

	Process()
		if(prob(ice_config.lightning_strike_chance))
			for(var/i = 1 to ice_config.lightnings_per_chance)
				var/turf/picked = pick(Z1_SNOW_TURFS)
				new /obj/effect/lightning_bolt(picked)
