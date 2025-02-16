----------------------------------------------
------------ MOD CODE ------------------------
----------------------------------------------

--------------------
-- Upgrades to do --
--------------------
-- Add blueprint_compat + eternal_compat + perishable_compat

----------------------------------------------
------------ Init ----------------------------
----------------------------------------------

-- Load the path to the mod directory
local modsPath = love.filesystem.getSaveDirectory() .. "/Mods/"
local sacrificeFilePath = modsPath .. "TheCult/sacrificecount.txt"

SACRIFICED_CARDS = 0 -- Default value

-- Function to create sacrificecount.txt if it doesn't exist
local function create_sacrifice_count()
	if not io.open(sacrificeFilePath, "r") then -- Check if file exists
		local file = io.open(sacrificeFilePath, "w")
		if file then
			file:write("0")
			file:close()
			print("File created")
		else
			print("Error creating file!")
		end
	else
		print("The file already exists") -- File exists, do nothing
	end
end

create_sacrifice_count()

-- Function to read sacrifice count
local function read_sacrifice_count()
	local file = io.open(sacrificeFilePath, "r")
	if file then
		local content = file:read("*all")
		file:close()
		local count = tonumber(content)
		if count then
			return count
		end
	else
		print("File not found")
	end
	return 0
end

-- Function to write sacrifice count
local function write_sacrifice_count(count)
	local file = io.open(sacrificeFilePath, "w")
	if file then
		file:write(tostring(count))
		file:close()
		--print("Sacrifice count updated:", count)
	else
		print("Error writing to file!")
	end
end

-- Initialize SACRIFICED_CARDS
SACRIFICED_CARDS = read_sacrifice_count()

-- Event for updating the sacrifice count (for saving the value when the game is restarted)
local event
event = Event({
	blockable = false,
	blocking = false,
	pause_force = true,
	no_delete = true,
	trigger = "after",
	delay = 5,
	func = function()
		local new_count = read_sacrifice_count()

		-- If the file count is different, update and write it
		if new_count ~= SACRIFICED_CARDS then
			new_count = SACRIFICED_CARDS
			write_sacrifice_count(SACRIFICED_CARDS)
		end

		event.start_timer = false
	end,
})

G.E_MANAGER:add_event(event)

-- code injection for resseting the SACRIFICED_CARDS when new run
dofile(modsPath .. "TheCult/injector.lua")

----------------------------------------------
------------ Jokers --------------------------
----------------------------------------------

SMODS.Atlas({
	key = "Jokers",
	path = "Jokers.png",
	px = 71,
	py = 95,
})

-- Sacrificer
SMODS.Joker({
	key = "Sacrificer",
	loc_txt = {
		name = "Sacrificer",
		text = {
			"{X:mult,C:white}X0.1{} Mult per sacrificed card",
			"{C:inactive}[Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult]{}",
		},
	},
	atlas = "Jokers",
	rarity = 3, -- rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
	cost = 5, -- cost
	unlocked = true, -- where it is unlocked or not: if true,
	discovered = true, -- whether or not it starts discovered
	pos = {
		x = 0,
		y = 0,
	},
	config = {
		extra = {
			Xmult = 1 + (0.1 * SACRIFICED_CARDS),
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { (1 + (0.1 * SACRIFICED_CARDS)) },
		}
	end,
	calculate = function(self, card, context)
		if
			context.joker_main -- or con  text.cardarea == G.play and context.main_scoring
		then
			-- Update Xmult based on SACRIFICED_CARDS
			card.ability.extra.Xmult = 1 + (0.1 * SACRIFICED_CARDS)
			return {
				card = card,
				Xmult_mod = card.ability.extra.Xmult,
				message = "X" .. card.ability.extra.Xmult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Cultist
SMODS.Joker({
	key = "Cultist",
	loc_txt = {
		name = "Cultist",
		text = {
			"When blind is selected,",
			"summon 1 {C:attention}Joker{}",
			"At the end of each round,",
			"sacrifice all {C:attention}Joker{}",
			"{C:inactive}[Currently #1# Sacrifices]{}",
		},
	},
	atlas = "Jokers",
	rarity = 1,
	cost = 4,
	unlocked = true,
	discovered = true,
	pos = {
		x = 1,
		y = 0,
	},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.j_joker
		return {
			vars = { SACRIFICED_CARDS },
		}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				card = card,
			}
		end

		if context.setting_blind then
			local new_card = create_card(
				"Joker", -- _type
				G.jokers, -- area
				nil, -- legendary
				nil, -- _rarity
				nil, -- skip_materialize
				nil, -- soulable
				"j_joker", -- forced_key
				nil -- key_append
			)
			new_card:add_to_deck()
			-- card:set_edition({ negative = true }, true)
			G.jokers:emplace(new_card)
		end
		if context.end_of_round then
			local jokers_to_remove = SMODS.find_card("j_joker")
			for _, joker in ipairs(jokers_to_remove) do
				joker:remove()
				SACRIFICED_CARDS = SACRIFICED_CARDS + 1
			end
		end
	end,
})

-- The Forgotten
SMODS.Joker({
	key = "TheForgotten",
	loc_txt = {
		name = "The Forgotten",
		text = { "The jaws that bite", "the claws that catch!", "{X:mult,C:white}X6.66{} Mult" },
	},
	atlas = "Jokers",
	rarity = 4,
	cost = 666,
	unlocked = false,
	discovered = false,
	pos = {
		x = 2,
		y = 0,
	},
	config = {
		extra = {
			Xmult = 6.66,
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { center.ability.extra.Xmult },
		}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				card = card,
				Xmult_mod = card.ability.extra.Xmult,
				message = "X" .. card.ability.extra.Xmult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Lamb
SMODS.Joker({
	key = "Lamb",
	loc_txt = {
		name = "Lamb",
		text = {
			"If you have at least 25 sacrificed cards",
			"sell this card to summon {C:attention}The Forgotten{}",
			"{C:inactive}[Currently #1# Sacrifices]{}",
		},
	},
	atlas = "Jokers",
	rarity = 1,
	cost = 2,
	unlocked = true,
	discovered = true,
	pos = {
		x = 3,
		y = 0,
	},
	loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = G.P_CENTERS.j_thecult_TheForgotten
		return {
			vars = { SACRIFICED_CARDS },
		}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				card = card,
			}
		end

		if context.selling_card and context.cardarea == G.jokers and SACRIFICED_CARDS > 24 then
			local new_card = create_card(
				"Joker", -- _type
				G.jokers, -- area
				nil, -- legendary
				nil, -- _rarity
				nil, -- skip_materialize
				nil, -- soulable
				"j_thecult_TheForgotten", -- forced_key
				nil -- key_append
			)
			new_card:add_to_deck()
			new_card:set_edition({
				negative = true,
			}, true)
			G.jokers:emplace(new_card)
		end
	end,
})

-- Heretic
SMODS.Joker({
	key = "Heretic",
	loc_txt = {
		name = "Heretic",
		text = {
			"When blind is selected,",
			"Reduce the count of sacrificed cards by 1",
			"Gain {X:mult,C:white}X0.2{} Mult",
			"{C:inactive}[Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult]{}",
		},
	},
	atlas = "Jokers",
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 4,
		y = 0,
	},
	config = {
		extra = {
			Xmult = 1,
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { center.ability.extra.Xmult },
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			if SACRIFICED_CARDS > 0 then
				SACRIFICED_CARDS = SACRIFICED_CARDS - 1
				card.ability.extra.Xmult = card.ability.extra.Xmult + 0.2
			end
		end

		if context.joker_main then
			return {
				card = card,
				Xmult_mod = card.ability.extra.Xmult,
				message = "X" .. card.ability.extra.Xmult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Martyr
SMODS.Joker({
	key = "Martyr",
	loc_txt = {
		name = "Martyr",
		text = {
			"When blind is skipped,",
			"Increase the count of sacrificed cards by 1",
			"Gain {C:red}+2{} Mult",
			"{C:inactive}[Currently{} {C:red}+#1#{} {C:inactive}Mult]{}",
		},
	},
	atlas = "Jokers",
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 0,
		y = 1,
	},
	config = {
		extra = {
			mult = 0,
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { center.ability.extra.mult },
		}
	end,
	calculate = function(self, card, context)
		if context.skip_blind then
			SACRIFICED_CARDS = SACRIFICED_CARDS + 1
			card.ability.extra.mult = card.ability.extra.mult + 2
		end

		if context.joker_main then
			return {
				card = card,
				mult_mod = card.ability.extra.mult,
				message = "+" .. card.ability.extra.mult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Condemned
SMODS.Joker({
	key = "Condemned",
	loc_txt = {
		name = "Condemned",
		text = { "In 5 rounds,", "Sacrifice this Joker", "Add 5 to the count of Sacrificed cards", "{C:red}+5{} Mult" },
	},
	atlas = "Jokers",
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 1,
		y = 1,
	},
	config = {
		extra = {
			mult = 5,
			count_round = 0,
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { center.ability.extra.mult },
		}
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers then
			-- print("count_round:", card.ability.extra.count_round)
			if card.ability.extra.count_round < 4 then
				card.ability.extra.count_round = card.ability.extra.count_round + 1
			else
				card:remove()
				SACRIFICED_CARDS = SACRIFICED_CARDS + 5
			end
		end

		if context.joker_main then
			return {
				card = card,
				mult_mod = card.ability.extra.mult,
				message = "+" .. card.ability.extra.mult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Soulbinder
SMODS.Joker({
	key = "Soulbinder",
	loc_txt = {
		name = "Soulbinder",
		text = {
			"When blind is selected,",
			"Sacrifice 1 random consumable card",
			"Gain {C:red}+2{} Mult",
			"{C:inactive}[Currently{} {C:red}+#1#{} {C:inactive}Mult]{}",
		},
	},
	atlas = "Jokers",
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 2,
		y = 1,
	},
	config = {
		extra = {
			mult = 0,
		},
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { center.ability.extra.mult },
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			local consumables_in_hand = {}

			for k, v in pairs(G.consumeables.cards) do
				table.insert(consumables_in_hand, v)
			end

			if #consumables_in_hand > 0 then
				local random_tarot = consumables_in_hand[math.random(#consumables_in_hand)]
				random_tarot:remove()
				SACRIFICED_CARDS = SACRIFICED_CARDS + 1
				card.ability.extra.mult = card.ability.extra.mult + 2
			end
		end

		if context.joker_main then
			return {
				card = card,
				mult_mod = card.ability.extra.mult,
				message = "+" .. card.ability.extra.mult,
				colour = G.C.MULT,
			}
		end
	end,
})

-- Ritualist
SMODS.Joker({
	key = "Ritualist",
	loc_txt = {
		name = "Ritualist",
		text = {
			"When blind is selected,",
			"Destroy the joker to the right",
			"Add it's sell value to the count",
			"of sacrificed cards (max 10)",
			"{C:inactive}[Currently #1# Sacrifices]{}",
		},
	},
	atlas = "Jokers",
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 3,
		y = 1,
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { SACRIFICED_CARDS },
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			local ritualist_key = nil
			for k, v in pairs(G.jokers.cards) do
				if v.label == "j_thecult_Ritualist" then
					ritualist_key = k
					break
				end
			end

			if ritualist_key then
				--local right_joker_key = ritualist_key + 1
				local right_joker = G.jokers.cards[ritualist_key + 1]

				if right_joker then
					local sell_value = right_joker.sell_cost
					if sell_value > 10 then
						sell_value = 10
					end

					right_joker:remove()

					SACRIFICED_CARDS = SACRIFICED_CARDS + sell_value
				end
			end
		end

		if context.joker_main then
			return {
				card = card,
			}
		end
	end,
})

-- Pactbearer
SMODS.Joker({
	key = "Pactbearer",
	loc_txt = {
		name = "Pactbearer",
		text = {
			"{X:mult,C:white}X1{} Mult per blood card in hand played",
		},
	},
	atlas = "Jokers",
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = true,
	pos = {
		x = 4,
		y = 1,
	},
	config = {
		extra = {
			Xmult = 1,
		},
	},
	calculate = function(self, card, context)
		if context.scoring_hand and #context.scoring_hand > 0 then
			local blood_count = 0

			-- Iterate over the played hand and count blood cards
			for _, played_card in pairs(context.scoring_hand) do
				if played_card.seal == "thecult_Blood_seal" then
					blood_count = blood_count + 1
				end
			end

			-- Update Xmult based on the blood count
			card.ability.extra.Xmult = 1 + blood_count

			if context.joker_main then
				return {
					card = card,
					Xmult_mod = card.ability.extra.Xmult,
					message = "X" .. card.ability.extra.Xmult,
					colour = G.C.MULT,
				}
			end
		end
	end,
})

----------------------------------------------
------------ Tarot cards ---------------------
----------------------------------------------

-- The Ritual
SMODS.Atlas({
	key = "Ritual",
	path = "TheRitual.png",
	px = 71,
	py = 95,
})

SMODS.Consumable({
	key = "Ritual",
	set = "Tarot",
	loc_txt = {
		name = "The Ritual",
		text = {
			"Add {C:attention}2{} to the count of sacrificed cards",
			"{C:inactive}[Currently #1# Sacrifices]{}",
		},
	},
	atlas = "Ritual",
	rarity = 1,
	cost = 3,
	unlocked = true,
	discovered = true,
	pos = {
		x = 0,
		y = 0,
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = { SACRIFICED_CARDS },
		}
	end,
	can_use = function(self, card)
		return true
	end,
	use = function(self, card)
		SACRIFICED_CARDS = SACRIFICED_CARDS + 2
		--print("SACRIFICED_CARDS:", SACRIFICED_CARDS)
	end,
})

-- The Pact
SMODS.Atlas({
	key = "Pact",
	path = "ThePact.png",
	px = 71,
	py = 95,
})

SMODS.Consumable({
	key = "Pact",
	set = "Tarot",
	config = {
		-- How many cards can be selected.
		max_highlighted = 1,
		-- the key of the seal to change to
		extra = "thecult_Blood_seal",
	},
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with seal args.
		info_queue[#info_queue + 1] = G.P_SEALS[(card.ability or self.config).extra]
		-- Description vars
		return { vars = { (card.ability or self.config).max_highlighted } }
	end,
	loc_txt = {
		name = "The Pact",
		text = {
			"Select {C:attention}#1#{} card to",
			"apply {C:attention}Blood Seal{}",
		},
	},
	atlas = "Pact",
	rarity = 2,
	cost = 4,
	unlocked = true,
	discovered = true,
	pos = {
		x = 0,
		y = 0,
	},
	use = function(self, card, area, copier)
		for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					card:juice_up(0.3, 0.5)
					return true
				end,
			}))

			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)
					return true
				end,
			}))

			delay(0.5)
		end
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				G.hand:unhighlight_all()
				return true
			end,
		}))
	end,
})

----------------------------------------------
------------ Spectral cards ------------------
----------------------------------------------

SMODS.Atlas({
	key = "Possession",
	path = "Possession.png",
	px = 71,
	py = 95,
})

SMODS.Consumable({
	key = "Possession",
	set = "Spectral",
	config = {
		-- How many cards can be selected.
		count = 3,
		-- the key of the seal to change to
		extra = "thecult_Blood_seal",
	},
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with seal args.
		info_queue[#info_queue + 1] = G.P_SEALS[(card.ability or self.config).extra]
		-- Description vars
		return { vars = { (card.ability or self.config).count } }
	end,
	loc_txt = {
		name = "Possession",
		text = {
			"Apply {C:attention}Blood Seal{}",
			"to #1# random cards",
		},
	},
	atlas = "Possession",
	rarity = 3,
	cost = 9,
	unlocked = true,
	discovered = true,
	pos = {
		x = 0,
		y = 0,
	},
	can_use = function(self, card)
		if G.hand then
			return true
		end
		return false
	end,
	use = function(self, card)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				play_sound("tarot1")
				card:juice_up(0.3, 0.5)
				return true
			end,
		}))

		local selected_cards = {}

		for i = 1, card.ability.count do
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					local random_card
					repeat
						random_card = pseudorandom_element(G.hand.cards, pseudoseed("possession"))
					until random_card and not selected_cards[random_card]

					if random_card then
						random_card:set_seal(card.ability.extra, nil, true)
						selected_cards[random_card] = true
					end
					return true
				end,
			}))
		end
	end,
})

----------------------------------------------
------------ Blood seal ----------------------
----------------------------------------------

SMODS.Atlas({
	key = "Bloodseal",
	path = "BloodSeal.png",
	px = 71,
	py = 95,
})

SMODS.Seal({
	name = "Blood Seal",
	key = "Blood_seal",
	badge_colour = HEX("e31b1b"),
	sound = { sound = "gold_seal", per = 0.8, vol = 1 },
	config = { chips = 0 },
	loc_txt = {
		label = "Blood Seal",
		name = "Blood Seal",
		text = {
			"Add twice the count",
			"of sacrificed cards",
			"to the chip value",
			"{C:inactive}[Currently #2# Sacrifices]{}",
		},
	},
	loc_vars = function(self, info_queue)
		return {
			vars = { self.config.chips, SACRIFICED_CARDS },
		}
	end,
	atlas = "Bloodseal",
	pos = {
		x = 0,
		y = 0,
	},
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			return {
				chips = SACRIFICED_CARDS * 2,
			}
		end
	end,
})

----------------------------------------------
------------ Blood flush ---------------------
----------------------------------------------

SMODS.PokerHand({
	key = "Blood_flush",
	chips = 100,
	mult = 10,
	l_mult = 5,
	l_chips = 50,
	visible = false,
	loc_txt = {

		name = "Blood Flush",
		description = {
			"5 cards with a Blood Seal",
		},
	},
	example = {
		{ "S_2", true },
		{ "H_J", true },
		{ "D_8", true },
		{ "H_K", true },
		{ "C_3", true },
	},

	evaluate = function(parts, hand)
		local count = 0
		local total_value = 0
		for _, card in ipairs(hand) do
			if card.seal == "thecult_Blood_seal" then
				count = count + 1
				local value = card.base.value
				if value == "Jack" or value == "Queen" or value == "King" then
					value = 10
				elseif value == "Ace" then
					value = 11
				end
				total_value = total_value + value
			end
		end
		if count == 5 then
			return { hand, total_value }
		end
	end,
})

-- Yuggoth planet card
SMODS.Atlas({
	key = "Yuggoth",
	path = "Yuggoth.png",
	px = 71,
	py = 95,
})

SMODS.Consumable({
	set = "Planet",
	key = "Yuggoth",
	rarity = 2,
	cost = 4,
	unlocked = true,
	config = { hand_type = "thecult_Blood_flush" },
	pos = { x = 0, y = 0 },
	atlas = "Yuggoth",
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge(localize("k_planet_q"), get_type_colour(self or card.config, card), nil, 1.2)
	end,
	process_loc_text = function(self)
		--use another planet's loc txt instead
		local target_text = G.localization.descriptions[self.set]["c_mercury"].text
		SMODS.Consumable.process_loc_text(self)
		G.localization.descriptions[self.set][self.key].text = target_text
	end,
	generate_ui = 0,
	loc_txt = {
		name = "Yuggoth",
	},
})

----------------------------------------------
------------ Booster -------------------------
----------------------------------------------

SMODS.Atlas({
	key = "BoosterCult",
	path = "BoosterCult.png",
	px = 71,
	py = 95,
})
SMODS.Booster({
	key = "BoosterCult",
	atlas = "BoosterCult",
	group_key = "k_buffoon_pack",
	cost = 5,
	unlocked = true,
	discovered = true,
	pos = {
		x = 0,
		y = 0,
	},
	loc_txt = {
		name = "Cult Booster",
		text = { "Choose {C:attention}1{} of up to", "{C:attention}2{} Jokers of The Cult" },
	},
	weight = 2,
	config = { extra = 2, choose = 1 }, -- Allow choosing 1 out of 2 cards
	create_card = function(self, card, i)
		-- Get a random Joker from "The Cult" set with weights
		local cult_cards = {
			{ key = "j_thecult_Cultist", weight = 3 },
			{ key = "j_thecult_Lamb", weight = 3 },
			{ key = "j_thecult_Sacrificer", weight = 1 },
			{ key = "j_thecult_Heretic", weight = 2 },
			{ key = "j_thecult_Martyr", weight = 2 },
			{ key = "j_thecult_Condemned", weight = 3 },
			{ key = "j_thecult_Soulbinder", weight = 1 },
			{ key = "j_thecult_Ritualist", weight = 3 },
			{ key = "j_thecult_Pactbearer", weight = 1 },
		}

		-- Function to select a card based on weights
		local function weighted_random(cards)
			local total_weight = 0
			for _, card in ipairs(cards) do
				total_weight = total_weight + card.weight
			end

			local random_weight = math.random() * total_weight
			for _, card in ipairs(cards) do
				random_weight = random_weight - card.weight
				if random_weight <= 0 then
					return card.key
				end
			end
		end

		-- Keep track of proposed cards to avoid duplicates
		self.proposed_cards = self.proposed_cards or {}
		local available_cards = {}
		for _, card in ipairs(cult_cards) do
			if not self.proposed_cards[card.key] then
				table.insert(available_cards, card)
			end
		end

		if #available_cards == 0 then
			-- Reset proposed cards if all have been proposed
			self.proposed_cards = {}
			available_cards = cult_cards
		end

		local random_card_key = weighted_random(available_cards)
		self.proposed_cards[random_card_key] = true

		return { key = random_card_key, set = "Joker", area = G.pack_cards, skip_materialize = true }
	end,
	select_card = function(self, card) end,
	loc_vars = pack_loc_vars,
})

----------------------------------------------
-------------- Back --------------------------
----------------------------------------------

SMODS.Atlas({
	key = "CultBack",
	path = "CultBack.png",
	px = 71,
	py = 95,
})

SMODS.Back({
	name = "The Cult",
	key = "BackTheCult",
	atlas = "CultBack",
	pos = {
		x = 0,
		y = 0,
	},
	loc_txt = {
		name = "The Cult",
		text = { "Start with 1 {C:attention}Cultist{}" },
	},
	apply = function()
		G.E_MANAGER:add_event(Event({
			func = function()
				local new_card = create_card(
					"Joker", -- _type
					G.jokers, -- area
					nil, -- legendary
					nil, -- _rarity
					nil, -- skip_materialize
					nil, -- soulable
					"j_thecult_Cultist", -- forced_key
					nil -- key_append
				)
				-- Add the new card to the deck
				new_card:add_to_deck()
				new_card:set_edition({
					base = true,
				}, true)

				-- Place the new card in the jokers area
				G.jokers:emplace(new_card)
				return true
			end,
		}))
	end,
})

----------------------------------------------
------------MOD CODE END----------------------
----------------------------------------------
