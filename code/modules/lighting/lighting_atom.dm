/atom
	var/light_power = 1 // intensity of the light
	var/light_range = 0 // range in tiles of the light
	var/light_color		// RGB string representing the colour of the light

	var/datum/light_source/light
	var/list/light_sources

/atom/proc/SetOpacity(var/_opacity = 0)
	opacity = _opacity

/atom/proc/GetLightRange()
	if(light)
		return light.light_range
	else
		return light_range

/atom/proc/set_light(l_range, l_power, l_color)
	if(l_power != null) light_power = l_power
	if(l_range != null) light_range = l_range
	if(l_color != null) light_color = l_color

	update_light()

/atom/proc/SetLuminosity(var/lum, var/power, var/_color)
	return set_light(lum, power, _color)

/atom/proc/AddLuminosity(var/lum, var/power, var/_color)
	return set_light((light_range + lum), power, _color)

/atom/proc/update_light()
	if(!light_power || !light_range)
		if(light)
			light.destroy()
			light = null
	else
		if(!istype(loc, /atom/movable))
			. = src
		else
			. = loc

		if(light)
			light.update(.)
		else
			light = new /datum/light_source(src, .)

/atom/New()
	. = ..()
	if(light_power && light_range)
		update_light()

/atom/Destroy()
	if(light)
		light.destroy()
		light = null
	return ..()

/atom/movable/Destroy()
	var/turf/T = loc
	if(opacity && istype(T))
		T.reconsider_lights()
	return ..()

/atom/Entered(atom/movable/obj, atom/prev_loc)
	. = ..()

	if(obj && prev_loc != src)
		for(var/datum/light_source/L in obj.light_sources)
			L.source_atom.update_light()

/atom/proc/set_opacity(new_opacity)
	var/old_opacity = opacity
	opacity = new_opacity
	var/turf/T = loc
	if(old_opacity != new_opacity && istype(T))
		T.reconsider_lights()

/obj/item/equipped()
	. = ..()
	update_light()

/obj/item/pickup()
	. = ..()
	update_light()

/obj/item/dropped()
	. = ..()
	update_light()
