--- STEAMODDED HEADER
--- MOD_NAME: The Cult
--- MOD_ID: THECULT
--- MOD_AUTHOR: [Nico]
--- MOD_DESCRIPTION: May the blood free us from our sins
--- PREFIX: xmpl
----------------------------------------------
------------MOD CODE -------------------------

-- cards to do : --

-- Sacrificer - Gain x0.1 mult per sacrificed card
-- The Forgotten - carte pêtée X10 mult negative
-- Lamb - If you have at least 25 sacrificed cards, sell this card to summon The Forgotten
-- Soulbinder - when blind is selected, Sacrifice 1 consumable card and gain +5 mult
-- Ritualist - When blind is selected, destroy the joker card to the right to add it's sell value to the count of sacrificed cards (max 10)
-- Heretic - When blind is selected, Reduce the count of sacrificed cards by 1 and gain x0.2 mult
-- Pactbearer - x0.2 mult per blood card in the deck
-- Martyr - When a blind is skipped, add 1 to the count of sacrificed cards, gain +2 mult
-- Condemned - In 5 rounds, sacrifice this Joker. Add 5 to the count of sacrificed cards. +5 mult

-- Blood cards : new enhancement which add twice the count of sacrificed cards to the chip value
-- Blood hand : if all played cards are blood cards, gain +10 mult +50 chips
-- tarot cards :
-- 1) The Pact - Enhances 2 selected cards to Blood cards
-- 2) The Ritual - Add 1 to the count of sacrificed cards
-- planet cards :
-- 1) Yuggoth - enhances Blood hand +5 mult + 25 chips
-- Spectral cards :
-- 1) Possession - Sacrifice 1 random card in your hand, but add a blood seal to 5 random cards instead

-- Cult booster : Choose 1 between 2-3 cards of the Cult

-- Cards done : --
-- Cultist - When blind is selected, summon 1 Joker. At the end of each round, sacrifice all Jokers. X1.1 mult

----------------------------------------------
------------ Utils --------------------------
SACRIFICED_CARDS = 0

----------------------------------------------
------------ Jokers --------------------------

SMODS.Atlas {
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}

-- Sacrificer
SMODS.Joker {
    key = 'Sacrificer',
    loc_txt = {
        name = 'Sacrificer',
        text = {
            '{X:mult,C:white}X0.1{} Mult per sacrificed card',
            '[Currently {X:mult,C:white}X#1#{} Mult]'
        }
    },
    atlas = 'Jokers',
    rarity = 2,        --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    cost = 5,          --cost
    unlocked = true,   --where it is unlocked or not: if true,
    discovered = true, --whether or not it starts discovered
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            Xmult = 1 + (0.1 * SACRIFICED_CARDS)
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        -- Update Xmult based on SACRIFICED_CARDS
        card.ability.extra.Xmult = 1 + SACRIFICED_CARDS

        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                colour = G.C.MULT
            }
        end
    end
}

-- Cultist
SMODS.Joker {
    key = 'Cultist',
    loc_txt = {
        name = 'Cultist',
        text = {
            'When blind is selected,',
            'summon 1 {C:attention}Joker{}',
            'At the end of each round,',
            'sacrifice all {C:attention}Joker{}',
        }
    },
    atlas = 'Jokers',
    rarity = 1,        --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    cost = 4,          --cost
    unlocked = true,   --where it is unlocked or not: if true,
    discovered = true, --whether or not it starts discovered
    pos = { x = 1, y = 0 },
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
                'Joker',   -- _type
                G.jokers,  -- area
                nil,       -- legendary
                nil,       -- _rarity
                nil,       -- skip_materialize
                nil,       -- soulable
                'j_joker', -- forced_key
                nil        -- key_append
            )
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
        end
        if context.end_of_round then
            local jokers_to_remove = SMODS.find_card('j_joker')
            for _, joker in ipairs(jokers_to_remove) do
                joker:remove()
                SACRIFICED_CARDS = SACRIFICED_CARDS + 1
            end
        end
    end
}
----------------------------------------------
------------MOD CODE END----------------------
