-- Modify the G.FUNCS.start_setup_run function to include the reset of sacrificed cards
local original_start_setup_run = G.FUNCS.start_setup_run
G.FUNCS.start_setup_run = function(e)
	if G.OVERLAY_MENU then
		G.FUNCS.exit_overlay_menu()
	end
	if G.SETTINGS.current_setup == "New Run" then
		if not G.GAME or (not G.GAME.won and not G.GAME.seeded) then
			if G.SAVED_GAME ~= nil then
				if not G.SAVED_GAME.GAME.won then
					G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
				end
				G:save_settings()
			end
		end
		local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
		local _challenge = G.challenge_tab or nil
		local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
		G.FUNCS.start_run(e, { stake = _stake, seed = _seed, challenge = _challenge })
		SACRIFICED_CARDS = 0
		--print("resetted the sacrificed cards")
	elseif G.SETTINGS.current_setup == "Continue" then
		if G.SAVED_GAME ~= nil then
			G.FUNCS.start_run(nil, { savetext = G.SAVED_GAME })
		end
	end
end
