var/datum/configuration/gamemodes/gamemode_config = new()

/datum/configuration/gamemodes
	category = "Game Modes"
	file = "config/game_options.txt"

	var/extended = 1
	var/traitor = 0
	var/traitorchan = 0
	var/double_agents = 0
	var/betrayed = 0
	var/nuclear = 0
	var/revolution = 0
	var/cult = 0
	var/changeling = 0
	var/wizard = 0
	var/malfunction = 0
	var/meteor = 0
	var/blob = 0
	var/sandbox = 0

	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode

	New()
		..()
		gamemode_config = src
		var/list/L = typesof(/datum/game_mode) - /datum/game_mode
		for(var/T in L)
			// I wish I didn't have to instance the game modes in order to look up
			// their information, but it is the only way (at least that I know of).
			var/datum/game_mode/M = new T()

			if(M.config_tag)
				if(!(M.config_tag in modes))		// ensure each mode is added only once
					diary << "Adding game mode [M.name] ([M.config_tag]) to configuration."
					modes += M.config_tag
					mode_names[M.config_tag] = M.name
					probabilities[M.config_tag] = vars[M.config_tag]
					if(M.votable)
						votable_modes += M.config_tag
			del(M)
		votable_modes += "secret"

	proc/pick_mode(mode_name)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
			var/datum/game_mode/M = new T()
			if(M.config_tag && M.config_tag == mode_name)
				return M
			del(M)
		return new /datum/game_mode/extended()

	proc/get_runnable_modes()
		var/list/datum/game_mode/runnable_modes = new
		for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
			var/datum/game_mode/M = new T()
			//world << "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]"
			if(!(M.config_tag in modes))
				del(M)
				continue
			if(probabilities[M.config_tag]<=0)
				del(M)
				continue
			if(M.can_start())
				runnable_modes[M] = probabilities[M.config_tag]
				//world << "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]"
		return runnable_modes