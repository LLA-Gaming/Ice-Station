///////////////////////////
//	   Main Configs      //
///////////////////////////
var/global/list/global_configs = list()
var/datum/configuration/main/config = new()

/datum/configuration/main
	category = "Main"
	file = "config/config.txt"

	var/servername = "Space Station 13"
	var/serversuffix = 0
	var/lobby_countdown = 180
	var/admin_legacy_system = 0
	var/ban_legacy_system = 0
	var/mentor_legacy_system = 0
	var/perseus_legacy_system = 0
	var/mycenae_starts_at_centcom = 0
	var/use_age_restriction_for_jobs = 0
	var/log_ooc = 0
	var/log_say = 0
	var/log_admin = 0
	var/log_access = 0
	var/log_game = 0
	var/log_vote = 0
	var/log_whisper = 0
	var/log_emote = 0
	var/log_attack = 0
	var/log_pda = 0
	var/log_prayer = 0
	var/log_law = 0
	var/log_hrefs = 0
	var/log_adminwarn = 0
	var/kick_inactive = 0
	var/allow_admin_ooccolor = 0
	var/allow_metadata = 0
	var/allow_vote_restart = 0
	var/allow_vote_mode = 0
	var/vote_delay = 6000
	var/vote_period = 600
	var/no_dead_vote = 0
	var/default_no_vote = 0
	var/respawn = 0
	var/dont_del_newmob = 0
	var/hostedby
	var/guest_jobban = 0
	var/usewhitelist = 0
	var/server
	var/forumurl
	var/wikiurl
	var/banappeals
	var/banrequest
	var/changelogurl
	var/load_jobs_from_txt = 0
	var/forbid_singulo_possession = 0
	var/popup_admin_pm = 0
	var/allow_holidays = 0
	var/useircbot = 0
	var/tick_lag = 0.9
	var/tickcomp = 0
	var/automute_on = 0
	var/comms_key
	var/getipintel = 0
	var/getipintelemail
	var/getipintellimit = 0.99
	var/faction_change_delay = 24 // In hours

var/datum/configuration/game_options/game_options = new()

/datum/configuration/game_options
	category = "Game Options"
	file = "config/game_options.txt"

	var/health_threshold_crit = 0
	var/health_threshold_dead = -100
	var/revival_pod_plants = 0
	var/revival_cloning = 0
	var/revival_brain_life = -1
	var/rename_cyborg = 0
	var/ooc_during_round = 0
	var/run_delay = 1
	var/walk_delay = 4
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0
	var/humans_need_surnames = 0
	var/force_random_names = 0

	var/alert_green = "threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_blue_upto = "threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_red_downto = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_delta = "The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/use_recursive_explosions = 0

	var/continuous_round_rev
	var/continuous_round_wiz
	var/continuous_round_malf
	var/continuous_round_betrayed

	var/shuttle_refuel_delay = 12000
	var/traitor_scaling_coeff = 6
	var/changeling_scaling_coeff = 7
	var/traitor_scaling_minimum = 4
	var/changeling_scaling_minimum = 2

	var/protect_roles_from_antagonist = 0
	var/allow_latejoin_antagonists = 0
	var/show_game_type_odds = 0
	var/allow_random_events = 0
	var/allow_ai = 0
	var/gateway_delay = 18000
	var/jobs_have_minimal_access = 0
	var/assistants_have_maint_access = 0
	var/everyone_has_maint_access = 0
	var/security_has_maint_access = 0
	var/sec_start_brig = 0
	var/ghost_interaction = 0
	var/silent_ai = 0
	var/silent_borg = 0
	var/sandbox_autoclose = 0
	var/default_laws = 0
	var/join_with_mutant_race = 0
	var/randomize_engine_template = 0
	var/allow_lowpop_modes = 0

var/datum/configuration/sql_config/sql_config  = new()

/datum/configuration/sql_config
	category = "SQL"
	file = "config/dbconfig.txt"

	var/sql_enabled = 0
	var/address = "localhost"
	var/port = 3306
	var/feedback_database = "feedback"
	var/feedback_login = "login"
	var/feedback_password = "pass"

///////////////////////////
//	   Config Datums     //
///////////////////////////

/datum/configuration
	var/category = 0
	var/file = "config/space_exploration_config.txt"

	New()
		..()
		global_configs.Add(src)
		var/list/values = GetConfigValues(category)
		for(var/val in values)
			if(hasvar(src, val))
				var/value
				if(isnum(text2num(values[val])))
					value = text2num(values[val])
				else
					value = values[val]
				vars[val] = value

		PostInit()

	// Used for special variable handling, etc. for example: see space_exploration/templates/config.dm @ L:15
	proc/PostInit()
		return 0

	proc/GetConfigFromCategory()
		if(!category)
			return 0

		var/list/lines = file2list(file)
		lines = lines.Copy(lines.Find("\[[category]\]") + 1, 0)

		var/line_pos
		for(var/line in lines)
			if(copytext(line, 1, 2) == "#")
				lines.Remove(line)

			if(line == null || line == "" || line == "\n" || line == " ")
				lines.Remove(line)

			if(findtext(line, "\[") && findtext(line, "\]") && copytext(line, 1, 2) == "\[")
				line_pos = lines.Find(line)
				break

		if(line_pos)
			lines = lines.Copy(1, line_pos)

		return lines

	proc/GetConfigValues()
		if(!category)
			return 0

		var/list/lines = GetConfigFromCategory(category)
		var/list/values = list()

		for(var/line in lines)
			var/token = lowertext(copytext(line, 1, findtext(line, " ", 1, 0)))
			var/value = copytext(line, length(token) + 2)

			if(!token)
				continue

			if(values.Find(token))
				var/list/newlist = list()
				newlist += values[token]
				newlist += value

				values[token] = newlist
				continue

			values.Add(token)
			values[token] = value

		return values