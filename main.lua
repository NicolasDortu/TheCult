--- STEAMODDED HEADER
--- MOD_NAME: The Cult
--- MOD_ID: THECULT
--- MOD_AUTHOR: [Nico]
--- MOD_DESCRIPTION: May the blood free us from our sins
--- PREFIX: thecult
----------------------------------------------
------------MOD CODE -------------------------

-------------------
-- cards to do : --
-------------------
-- Pactbearer - x0.2 mult per blood card in the deck

-----------------
-- Mechanics : --
-----------------
-- Blood hand : if all played cards are blood cards, gain +10 mult +50 chips

------------------
-- planet cards :
------------------
-- 1) Yuggoth - enhances Blood hand +5 mult + 25 chips

------------------
-- Cult booster : Choose 1 between 2-3 cards of the Cult
------------------

------------------
-- Cards done : --
------------------
-- Cultist - When blind is selected, summon 1 Joker. At the end of each round, sacrifice all Jokers.
-- Sacrificer - Gain x0.1 mult per sacrificed card
-- The Forgotten - carte pêtée X10 mult negative
-- Lamb - If you have at least 25 sacrificed cards, sell this card to summon The Forgotten
-- Heretic - When blind is selected, Reduce the count of sacrificed cards by 1 and gain x0.2 mult
-- Martyr - When a blind is skipped, add 1 to the count of sacrificed cards, gain +2 mult
-- Condemned - In 5 rounds, sacrifice this Joker. Add 5 to the count of sacrificed cards. +5 mult
-- Soulbinder - when blind is selected, Sacrifice 1 consumable card and gain +5 mult
-- Ritualist - When blind is selected, destroy the joker card to the right to add it's sell value to the count of sacrificed cards (max 10)
-- Cult back
----------------
-- tarot cards :
----------------
-- 1) The Pact - Enhances 2 selected cards to Blood cards
-- 2) The Ritual - Add 2 to the count of sacrificed cards
-- Blood cards : new enhancement which add twice the count of sacrificed cards to the chip value
------------------
-- Spectral cards :
------------------
-- 1) Possession - Add a blood seal to 3 random cards instead
----------
-- bugs:--
----------
-- Seems like new run doesn't reset the sacrificed card
-- Mult not updated before a tick from the game

--------------
-- Upgrades --
--------------
-- Ajouter blueprint_compat + eternal_compat + perishable_compat
-- Ajouter le nbr de SACRIFICED_CARDS
-- Ajouter les mult même pour les cards qui en ont pas? (si holo par ex)

----------------------------------------------
------------ Utils --------------------------
SACRIFICED_CARDS = 0

----------------------------------------------
------------ Jokers --------------------------

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
		text = { "{X:mult,C:white}X0.1{} Mult per sacrificed card", "[Currently {X:mult,C:white}X#1#{} Mult]" },
	},
	atlas = "Jokers",
	rarity = 1, -- rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
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
			vars = { center.ability.extra.Xmult },
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
		text = { "The jaws that bite, the claws that catch!", "[{X:mult,C:white}X10{} Mult]" },
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
			Xmult = 10,
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
		text = { "If you have at least 25 sacrificed cards", "sell this card to summon {C:attention}The Forgotten{}" },
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
			"[Currently {X:mult,C:white}X#1#{} Mult]",
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
		-- print("calculate called")
		-- print("context.setting_blind:", context.setting_blind)
		-- print("SACRIFICED_CARDS:", SACRIFICED_CARDS)
		-- print("Initial Xmult:", card.ability.extra.Xmult)

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
			"[Currently {C:red}+#1#{} Mult]",
		},
	},
	atlas = "Jokers",
	rarity = 1,
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
			"[Currently {C:red}+#1#{} Mult]",
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
				-- print("k:", k)
				-- if v.label then
				-- 	print("label:", v.label)
				-- else
				-- 	print("label: (no label)")
				-- end
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
	calculate = function(self, card, context)
		if context.setting_blind then
			-- Debug
			-- for k, v in pairs(G.jokers.cards) do
			-- 	print("k:", k)
			-- 	print("label", v.label)
			-- 	print("cost:", v.sell_cost)
			-- end

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

----------------------------------------------
------------ Tarot cards ---------------------

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
			"Add 2 to the count of sacrificed cards",
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
	can_use = function(self, card)
		return true
	end,
	use = function(self, card)
		SACRIFICED_CARDS = SACRIFICED_CARDS + 2
		print("SACRIFICED_CARDS:", SACRIFICED_CARDS)
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
	rarity = 1,
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
		text = { "Add twice the count", "of sacrificed cards", "to the chip value" },
	},
	loc_vars = function(self, info_queue)
		return {
			vars = self.config.chips,
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
------------ Blood hand ----------------------

-- https://github.com/Steamodded/examples/blob/master/Mods/RoyalFlush/RoyalFlush.lua

----------------------------------------------
------------ Booster -------------------------

----------------------------------------------
------------ New Back ------------------------
SMODS.Back({
	name = "The Cult",
	key = "BackTheCult",
	pos = {
		x = 0,
		y = 3,
	},
	-- config = {
	--     polyglass = true
	-- },
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
