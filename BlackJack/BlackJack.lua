--- STEAMODDED HEADER
--- MOD_NAME: Blackjack Hands
--- MOD_ID: BJ
--- PREFIX: bj
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Blackjack Hands
--- VERSION: 1.0.8
----------------------------------------------
------------MOD CODE -------------------------

local get_blackjack = function(hand)
    if (#hand < 3) then
        return {}
    end
    local ret = {}
    local t = {}
    local total = 0
    local aces = 0
    local tolerance = add_bj_count()
    for i=1, #hand do
        if (hand[i].base.nominal > 0) and (hand[i].ability.effect ~= 'Stone Card') then
            total = total + hand[i].base.nominal
            t[#t+1] = hand[i]
            if hand[i].base.value == 'Ace' then
                aces = aces + 1
            end
        end
    end
    if (total > (21 + tolerance)) then
        while ((total > (21 + tolerance)) and (aces > 0)) do 
            total = total - 10
            aces = aces - 1
        end
    end
    if (total >= (21 - tolerance)) and (total <= (21 + tolerance)) then
        table.insert(ret, t)
        return ret
    end
    return {}
end

local get_blackjack_three = function(hand)
    if (#hand < 3) then
        return {}
    end
    local ret = {}
    local t = {}
    local total = 0
    local aces = 0
    local rank = -1
    local tolerance = add_bj_count()
    for i=1, #hand do
        if (hand[i].base.nominal > 0) and (hand[i].ability.effect ~= 'Stone Card') then
            if (rank == -1) then
                rank = hand[i].base.value
            end
            if (hand[i].base.value ~= rank) then
                return {}
            end
            total = total + hand[i].base.nominal
            t[#t+1] = hand[i]
            if hand[i].base.value == 'Ace' then
                aces = aces + 1
            end
        end
    end
    if (#t ~= 3) then
        return {}
    end
    if (total > (21 + tolerance)) then
        while ((total > (21 + tolerance)) and (aces > 0)) do 
            total = total - 10
            aces = aces - 1
        end
    end
    if (total >= (21 - tolerance)) and (total <= (21 + tolerance)) then
        table.insert(ret, t)
        return ret
    end
    return {}
end

local get_natural = function(hand) 
    local ret = {}
    local t = {}
    local ace = false
    local face = false
    for i=1, #hand do
        if (hand[i].base.nominal > 0) and (hand[i].ability.effect ~= 'Stone Card') then
            t[#t+1] = hand[i]
            if (hand[i].base.value == 'Ace') and (not ace) then
                ace = true
            elseif (hand[i].base.nominal == 10) and (not face) then
                face = true
            else
                return {}
            end
        end
    end
    if ace and face then
        table.insert(ret, t)
        return ret
    end
    return {}
end

local new_hands = {
    {name = "Blackjack Flush House",  mult = 18,  chips = 180, level_mult = 3, level_chips = 40, order = 0.9, example = {{'S_3', true},{'S_5', true},{'S_5', true},{'S_5', true},{'S_3', true}}, desc = {"Three of a Kind and a Pair", "whose cards sum to 21.", "all cards sharing the same suit"}, above_hand = "Flush Five", key = "jack_flush_house", visible = false},
    {name = "Blackjack House",      mult = 8,   chips = 80, level_mult = 3, level_chips = 35, order = 1, example = {{'D_3', true},{'S_3', true},{'S_6', true},{'H_3', true},{'C_6', true}}, desc = {"Three of a Kind and a Pair", "whose cards sum to 21."}, above_hand = "Four of a Kind", key = "jack_house", visible = true},
    {name = "Blackjack Flush",   mult = 7,   chips = 80,  level_mult = 3, level_chips = 35, order = 1, example = {{'H_3', true},{'H_4', true},{'H_5', true},{'H_2', true},{'H_7', true}}, desc = {"5 cards whose ranks sum to 21.", "all cards sharing the same suit"}, above_hand = "Four of a Kind", key = "jack_flush", visible = true},
    {name = "Blackjack Three",           mult = 4,   chips = 36,  level_mult = 2, order = 1, level_chips = 20, example = {{'S_7', true},{'H_7', true},{'D_7', true}}, desc = {"3 cards of the same rank", "which sum to 21."}, above_hand = "Flush", key = "jack_three", visible = true},
    {name = "Natural",        mult = 1,   chips = 7,  level_mult = 1, level_chips = 14, order = 1, example = {{'H_A', true},{'S_J', true}}, desc = {"An Ace with a 10 value card."}, above_hand = "High Card", key = "natural", visible = true},
    {name = "Blackjack",        mult = 3,   chips = 25,  level_mult = 2, level_chips = 25, order = 1, example = {{'S_3', true},{'C_4', true},{'S_5', true},{'D_2', true},{'H_7', true}}, desc = {"3 or more cards whose ranks", "sum to 21."}, above_hand = "Three of a Kind", key = "jack", visible = true}
}

new_hands[1].evaluate = function(parts, hand)
    if next(get_blackjack(hand)) and  (#parts._3 >= 1 and #parts._2 >= 2) and next(parts._flush) and #hand >= 5 then
        return {SMODS.merge_lists(parts._3, parts._2)}
    else
        return {}
    end
end

new_hands[2].evaluate = function(parts, hand)
    
    if next(get_blackjack(hand))  then
        if #parts._3 < 1 or #parts._2 < 3 then return {} end
        --return parts._all_pairs
        
        return {SMODS.merge_lists(parts._3, parts._2)}
    else
        return {}
    end
end

new_hands[3].evaluate = function(parts, hand)
    local bj = get_blackjack(hand)
    if next(bj) and next(parts._flush) then
        return bj
    else
        return {}
    end
end

new_hands[4].evaluate = function(parts, hand)
    local bj3 = get_blackjack_three(hand)
    if next(bj3) then
        return bj3
    else
        return {}
    end
end

new_hands[5].evaluate = function(parts, hand)
    local nat = get_natural(hand)
    if next(nat) then
        return nat
    else
        return {}
    end
end

new_hands[6].evaluate = function(parts, hand)
    local bj = get_blackjack(hand)
    if next(bj) then
        return bj
    else
        return {}
    end
end

for i, j in ipairs(new_hands) do
    SMODS.PokerHand {
        key = j.key,
        above_hand = j.above_hand,
        mult = j.mult,
        chips = j.chips,
        l_mult = j.level_mult,
        l_chips = j.level_chips,
        example = j.example,
        visible = j.visible,
        loc_txt = {
            name = j.name,
            description = j.desc
        },
        evaluate = j.evaluate
    }
end

function add_bj_count()
    local total = 0
    if (G.jokers ~= nil) and (G.jokers.cards ~= nil) and (G.jokers.cards[1] ~= nil) then
        for i = 1, #G.jokers.cards do
            if (G.jokers.cards[i].ability.name == "Ace up my Sleeve") and not G.jokers.cards[i].debuff then
                total = total + 1
            end
        end
    end
    return total
end

function SMODS.current_mod.process_loc_text()
    for _, v in ipairs(new_hands) do
        G.localization.misc.poker_hands[v.name] = v.name
        G.localization.misc.poker_hand_descriptions[v.name] = v.desc
    end
    G.localization.misc.challenge_names["c_all_natural"] = "All Natural"
    G.localization.misc.v_text.ch_c_nat_only = {"Only {C:attention}Natural{} hands allowed."}
    G.localization.misc.v_text.ch_c_nat_three = {"{C:attention}Natural{} starts at level {C:attention}3{}."}
    G.localization.misc.challenge_names["c_all_natural_g"] = "All Natural [Gold Stake]"
    G.localization.misc.challenge_names["c_ult_ob"] = "Ultimate Obelisk"
    G.localization.misc.v_text.ch_c_repeat_double = {"Playing a {C:attention}poker hand{} you have already played doubles all blinds."}
    G.localization.misc.v_text.ch_c_gold_stake = {"Activate {C:attention}gold stake{}"}
    G.localization.misc.challenge_names["c_gold_ob"] = "Ultimate Obelisk [Gold Stake]"
end

SMODS.Atlas({ key = "planets", atlas_table = "ASSET_ATLAS", path = "Planets.png", px = 71, py = 95})

SMODS.Atlas({ key = "jokers", atlas_table = "ASSET_ATLAS", path = "gamble.png", px = 71, py = 95})

SMODS.Atlas({ key = "blinds", atlas_table = "ANIMATION_ATLAS", path = "jack.png", px = 34, py = 34, frames = 21 })

SMODS.Planet {
    key = 'tetra',
    name = "Tetra",
    loc_txt = {
        name = "Tetra",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_natural'},
    atlas = "planets",
    pos = {x = 0, y = 0},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_natural"].played > 0 then
            return true
        end
        return false
    end
}

SMODS.Planet {
    key = 'cubic',
    name = "Cubic",
    loc_txt = {
        name = "Cubic",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_jack_three'},
    atlas = "planets",
    pos = {x = 1, y = 0},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_jack_three"].played > 0 then
            return true
        end
        return false
    end
}

SMODS.Planet {
    key = 'octa',
    name = "Octa",
    loc_txt = {
        name = "Octa",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_jack'},
    atlas = "planets",
    pos = {x = 2, y = 0},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_jack"].played > 0 then
            return true
        end
        return false
    end
}

SMODS.Planet {
    key = 'dodeca',
    name = "Dodeca",
    loc_txt = {
        name = "Dodeca",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_jack_flush'},
    atlas = "planets",
    pos = {x = 0, y = 1},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_jack_flush"].played > 0 then
            return true
        end
        return false
    end
}

SMODS.Planet {
    key = 'icosa',
    name = "Icosa",
    loc_txt = {
        name = "Icosa",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_jack_house'},
    atlas = "planets",
    pos = {x = 1, y = 1},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_jack_house"].played > 0 then
            return true
        end
        return false
    end
}

SMODS.Planet {
    key = 'pi',
    name = "Pi",
    loc_txt = {
        name = "Pi",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips"
        }
    },
    config = {hand_type = 'bj_jack_flush_house', softlock = true},
    atlas = "planets",
    pos = {x = 2, y = 1},
    loc_vars = function(self, info_queue, card)
        local hand = self.config.hand_type
        return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
    end,
    in_pool = function(self)
        if G.GAME.hands["bj_jack_flush_house"].played > 0 then
            return true
        end
        return false
    end
}

old_press = Blind.press_play
function Blind:press_play()
    local returns = old_press(self)
    if G.GAME.modifiers["repeat_double"] then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                local handname = G.FUNCS.get_poker_hand_info(G.play.cards)
                if (G.GAME.hands[handname].played > 0) then
                    G.GAME.starting_params.ante_scaling = G.GAME.starting_params.ante_scaling * 2
                    self.chips = self.chips * 2
                    self.chip_text = number_format(self.chips)
                    G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                    G.HUD_blind:recalculate() 
                    G.hand_text_area.blind_chips:juice_up()
                    delay(0.23)
                end
            return true end }))
    end
    if (returns ~= nil) then
        return returns
    end
    if self.disabled then return end
    if self.name == 'The Jack' then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            local total = 0
            for i=1, #G.play.cards do
                if (G.play.cards[i].base.nominal > 0) and (G.play.cards[i].ability.effect ~= 'Stone Card') then
                    total = total + G.play.cards[i].base.nominal
                    if G.play.cards[i].base.value == 'Ace' then
                        total = total - 10
                    end
                end
            end
            if total > 21 then
                self:wiggle()
                for i=1, #G.play.cards do
                    G.E_MANAGER:add_event(Event({func = function() G.play.cards[i]:juice_up();G.play.cards[i]:set_debuff(true); return true end }))
                    delay(0.23)
                end
            end
        return true end }))
    end
end

SMODS.Joker {
    key = 'gamble',
    name = "The Gamble",
    loc_txt = {
        name = "The Gamble",
        text = {
            "{X:mult,C:white}X3# {} Mult if played hand",
            "contains a {C:attention}Blackjack{}."
        },
        unlock = {
            "Win a run",
            "without playing",
            "a {C:attention}Blackjack{}."
        }
    },
    rarity = 3,
    atlas = 'jokers',
    pos = {x = 0, y = 0},
    cost = 4,
    config = {extra = {xmult = 3}},
    unlock_condition = {type = 'win_no_hand', extra = 'bj_jack'},
    unlocked = false,
    calculate = function(self, card, context)
        if context.joker_main then
            local get_blackjack = function(hand)
                if (#hand < 3) then
                    return {}
                end
                local ret = {}
                local t = {}
                local total = 0
                local aces = 0
                local tolerance = add_bj_count()
                for i=1, #hand do
                    if (hand[i].base.nominal > 0) and (hand[i].ability.effect ~= 'Stone Card') then
                        total = total + hand[i].base.nominal
                        t[#t+1] = hand[i]
                        if hand[i].base.value == 'Ace' then
                            aces = aces + 1
                        end
                    end
                end
                if (total > (21 + tolerance)) then
                    while ((total > (21 + tolerance)) and (aces > 0)) do 
                        total = total - 10
                        aces = aces - 1
                    end
                end
                if (total >= (21 - tolerance)) and (total <= (21 + tolerance)) then
                    table.insert(ret, t)
                    return ret
                end
                return {}
            end

            local hand = context.full_hand
            local valid = false
            local extent = function(table)
                return (#table ~= 0)
            end
            if (#hand == 3) then
                if extent(get_blackjack(hand)) then
                    valid = true
                end
            elseif (#hand == 4) then
                if (extent(get_blackjack(hand)) or extent(get_blackjack({hand[1], hand[2], hand[3]})) or extent(get_blackjack({hand[4], hand[2], hand[3]})) or extent(get_blackjack({hand[1], hand[4], hand[3]})) or extent(get_blackjack({hand[1], hand[2], hand[4]}))) then
                    valid = true
                end
            elseif (#hand == 5) then
                if (extent(get_blackjack(hand)) or
                extent(get_blackjack({hand[3], hand[4], hand[5]})) or 
                extent(get_blackjack({hand[2], hand[4], hand[5]})) or 
                extent(get_blackjack({hand[2], hand[3], hand[5]})) or 
                extent(get_blackjack({hand[2], hand[3], hand[4]})) or
                extent(get_blackjack({hand[1], hand[4], hand[5]})) or
                extent(get_blackjack({hand[1], hand[3], hand[5]})) or
                extent(get_blackjack({hand[1], hand[3], hand[4]})) or
                extent(get_blackjack({hand[1], hand[2], hand[5]})) or
                extent(get_blackjack({hand[1], hand[2], hand[4]})) or
                extent(get_blackjack({hand[1], hand[2], hand[3]})) or
                extent(get_blackjack({hand[1], hand[2], hand[3], hand[4]})) or
                extent(get_blackjack({hand[1], hand[2], hand[3], hand[5]})) or
                extent(get_blackjack({hand[1], hand[2], hand[5], hand[4]})) or
                extent(get_blackjack({hand[1], hand[5], hand[3], hand[4]})) or
                extent(get_blackjack({hand[5], hand[2], hand[3], hand[4]}))) then
                    valid = true
                end
            end

            if valid then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
                    Xmult_mod = card.ability.extra.xmult,
                    card = card
                }
            else 
                return
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {3}}
    end,
}

SMODS.Joker {
    key = 'jackpot',
    name = "777 Jackpot",
    loc_txt = {
        name = "777 Jackpot",
        text = {
            "Each played {C:attention}7{} has a {C:green}#1# in #2#{}",
            "chance to {C:attention}retrigger{}."
        }
    },
    rarity = 1,
    atlas = 'jokers',
    pos = {x = 2, y = 0},
    cost = 2,
    config = {extra = {odds = 7, times = 1}},
    calculate = function(self, card, context)
        if context.repetition and (context.cardarea == G.play) and (context.scoring_hand ~= nil) and not card.debuff then
            if (context.other_card:get_id() == 7) and (pseudorandom('jackpot') < 2*G.GAME.probabilities.normal/card.ability.extra.odds) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.times,
                    card = card
                }
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {2 * G.GAME.probabilities.normal, 7}}
    end,
}

SMODS.Joker {
    key = 'aces',
    name = "Ace up my Sleeve",
    loc_txt = {
        name = "Ace up my Sleeve",
        text = {
            "{C:attention}-1{} Blackjack Min",
            "{C:attention}+1{} Blackjack Max",
            "{C:inactive}(Blackjack Min: {}{C:attention}#1#{}{C:inactive}){}",
            "{C:inactive}(Blackjack Max: {}{C:attention}#2#{}{C:inactive}){}"
        }
    },
    rarity = 2,
    atlas = 'jokers',
    pos = {x = 1, y = 0},
    cost = 2,
    config = {extra = {odds = 7, times = 1}},
    loc_vars = function(self, info_queue, card)
        return {vars = {21 - add_bj_count(), 21 + add_bj_count()}}
    end,
}

SMODS.Blind {
    loc_txt = {
        name = 'The Jack',
        text = { 'Hands whose ranks sum over', '21 debuff all played cards' }
    },
    key = 'jack',
    name = 'The Jack',
    config = {},
    boss = {min = 3, max = 10},
    boss_colour = HEX("730000"),
    atlas = "blinds",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 5,
    mult = 2,
    debuff_hand = function(self, cards, hand, handname, check)
        local total = 0
        for i=1, #G.play.cards do
            if (G.play.cards[i].base.nominal > 0) and (G.play.cards[i].ability.effect ~= 'Stone Card') then
                total = total + G.play.cards[i].base.nominal
                if G.play.cards[i].base.value == 'Ace' then
                    total = total - 10
                end
            end
        end
        if total > 21 then
            self.triggered = true
        end
    end,
}


table.insert(G.CHALLENGES,#G.CHALLENGES+1, 
    {name = 'All Natural',
        id = 'c_all_natural',
        rules = {
            custom = {
                {id = 'nat_only'},
                {id = 'nat_three'}
            },
            modifiers = {
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
            cards = {
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'J'},
                {s = 'C', r = 'Q'},
                {s = 'C', r = 'K'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'J'},
                {s = 'S', r = 'Q'},
                {s = 'S', r = 'K'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'J'},
                {s = 'H', r = 'Q'},
                {s = 'H', r = 'K'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'J'},
                {s = 'D', r = 'Q'},
                {s = 'D', r = 'K'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
            }
        },
        restrictions = {
            banned_cards = {
                {id = 'j_jolly'},
                {id = 'j_zany'},
                {id = 'j_mad'},
                {id = 'j_crazy'},
                {id = 'j_droll'},
                {id = 'j_sly'},
                {id = 'j_wily'},
                {id = 'j_clever'},
                {id = 'j_devious'},
                {id = 'j_crafty'},
                {id = 'j_four_fingers'},
                {id = 'j_hack'},
                -- {id = 'j_ride_the_bus'},
                {id = 'j_runner'},
                {id = 'j_splash'},
                {id = 'j_sixth_sense'},
                {id = 'j_superposition'},
                {id = 'j_seance'},
                {id = 'j_shortcut'},
                -- {id = 'j_obelisk'},
                -- {id = 'j_cloud_9'},
                {id = 'j_trousers'},
                {id = 'j_flower_pot'},
                {id = 'j_wee'},
                {id = 'j_duo'},
                {id = 'j_trio'},
                {id = 'j_family'},
                {id = 'j_order'},
                {id = 'j_tribe'},
                {id = 'j_8_ball'},
                {id = 'j_bj_aces'},
                {id = 'j_bj_gamble'},
                {id = 'j_bj_jackpot'},
                {id = 'c_pluto'},
                {id = 'c_mercury'},
                {id = 'c_venus'},
                {id = 'c_earth'},
                {id = 'c_mars'},
                {id = 'c_jupiter'},
                {id = 'c_saturn'},
                {id = 'c_uranus'},
                {id = 'c_neptune'},
                {id = 'c_pluto'},
                {id = 'c_planet_x'},
                {id = 'c_ceres'},
                {id = 'c_eris'},
                {id = 'c_bj_cubic'},
                {id = 'c_bj_octa'},
                {id = 'c_bj_dodeca'},
                {id = 'c_bj_icosa'},
                {id = 'c_bj_pi'},
                {id = 'c_high_priestess'},
                {id = 'v_telescope'},
                {id = 'p_celestial_normal_2', ids = {
                    'p_celestial_normal_1','p_celestial_normal_2','p_celestial_normal_3','p_celestial_normal_4','p_celestial_jumbo_1','p_celestial_jumbo_2','p_celestial_mega_1','p_celestial_mega_2'
                }}
            },
            banned_tags = {
                {id = 'tag_meteor'}
            },
            banned_other = {
                {id = 'bl_psychic', type = 'blind'},
                {id = 'bl_eye', type = 'blind'},
                {id = 'bl_ox', type = 'blind'},
            }
        }
    }
)

table.insert(G.CHALLENGES,#G.CHALLENGES+1, 
    {name = 'All Natural [Gold Stake]',
        id = 'c_all_natural_g',
        rules = {
            custom = {
                {id = 'nat_only'},
                {id = 'nat_three'},
                {id = 'gold_stake'}
            },
            modifiers = {
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
            cards = {
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'A'},
                {s = 'C', r = 'J'},
                {s = 'C', r = 'Q'},
                {s = 'C', r = 'K'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'C', r = 'T'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'A'},
                {s = 'S', r = 'J'},
                {s = 'S', r = 'Q'},
                {s = 'S', r = 'K'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'S', r = 'T'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'A'},
                {s = 'H', r = 'J'},
                {s = 'H', r = 'Q'},
                {s = 'H', r = 'K'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'H', r = 'T'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'A'},
                {s = 'D', r = 'J'},
                {s = 'D', r = 'Q'},
                {s = 'D', r = 'K'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
                {s = 'D', r = 'T'},
            }
        },
        restrictions = {
            banned_cards = {
                {id = 'j_jolly'},
                {id = 'j_zany'},
                {id = 'j_mad'},
                {id = 'j_crazy'},
                {id = 'j_droll'},
                {id = 'j_sly'},
                {id = 'j_wily'},
                {id = 'j_clever'},
                {id = 'j_devious'},
                {id = 'j_crafty'},
                {id = 'j_four_fingers'},
                {id = 'j_hack'},
                -- {id = 'j_ride_the_bus'},
                {id = 'j_runner'},
                {id = 'j_splash'},
                {id = 'j_sixth_sense'},
                {id = 'j_superposition'},
                {id = 'j_seance'},
                {id = 'j_shortcut'},
                -- {id = 'j_obelisk'},
                -- {id = 'j_cloud_9'},
                {id = 'j_trousers'},
                {id = 'j_flower_pot'},
                {id = 'j_wee'},
                {id = 'j_duo'},
                {id = 'j_trio'},
                {id = 'j_family'},
                {id = 'j_order'},
                {id = 'j_tribe'},
                {id = 'j_8_ball'},
                {id = 'j_bj_aces'},
                {id = 'j_bj_gamble'},
                {id = 'j_bj_jackpot'},
                {id = 'c_pluto'},
                {id = 'c_mercury'},
                {id = 'c_venus'},
                {id = 'c_earth'},
                {id = 'c_mars'},
                {id = 'c_jupiter'},
                {id = 'c_saturn'},
                {id = 'c_uranus'},
                {id = 'c_neptune'},
                {id = 'c_pluto'},
                {id = 'c_planet_x'},
                {id = 'c_ceres'},
                {id = 'c_eris'},
                {id = 'c_bj_cubic'},
                {id = 'c_bj_octa'},
                {id = 'c_bj_dodeca'},
                {id = 'c_bj_icosa'},
                {id = 'c_bj_pi'},
                {id = 'c_high_priestess'},
                {id = 'v_telescope'},
                {id = 'p_celestial_normal_2', ids = {
                    'p_celestial_normal_1','p_celestial_normal_2','p_celestial_normal_3','p_celestial_normal_4','p_celestial_jumbo_1','p_celestial_jumbo_2','p_celestial_mega_1','p_celestial_mega_2'
                }}
            },
            banned_tags = {
                {id = 'tag_meteor'}
            },
            banned_other = {
                {id = 'bl_psychic', type = 'blind'},
                {id = 'bl_eye', type = 'blind'},
                {id = 'bl_ox', type = 'blind'},
            }
        }
    }
)

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Ultimate Obelisk',
        id = 'c_ult_ob',
        rules = {
            custom = {
                {id = 'repeat_double'}
            },
            modifiers = {
                {id = 'discards', value = 6},
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
                {id = 'bl_water', type = 'blind'},
                {id = 'bl_mouth', type = 'blind'},
            }
        }
    }
)

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Ultimate Obelisk [Gold Stake]',
        id = 'c_gold_ob',
        rules = {
            custom = {
                {id = 'repeat_double'},
                {id = 'gold_stake'}
            },
            modifiers = {
                {id = 'discards', value = 5},
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
                {id = 'bl_water', type = 'blind'},
                {id = 'bl_mouth', type = 'blind'},
            }
        }
    }
)


old_debuff = Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
    if G.GAME.modifiers["nat_only"] then
        local front_face = true
        for i=1, #cards do
            if cards[i].facing == 'back' then
                front_face = false
                break
            end
        end
        if (not check) or front_face then
            if handname ~= "bj_natural" then
                G.reallyNat = true
                return true
            else
                G.reallyNat = false
            end
        end
    end
    if self.disabled then return end
    return old_debuff(self, cards, hand, handname, check)
end

local start_runref = Game.start_run
function Game.start_run(self, args)
    if args.challenge then
        for i, j in pairs(args.challenge.rules.custom) do
            if j.id == "gold_stake" then
                args.stake = 8
            end
        end
    end
	start_runref(self, args)
    if args.challenge then
        if self.GAME.modifiers["nat_three"] then
            G.GAME.hands['bj_natural'].level = math.max(0, G.GAME.hands['bj_natural'].level + 2)
            G.GAME.hands['bj_natural'].mult = math.max(G.GAME.hands['bj_natural'].s_mult + G.GAME.hands['bj_natural'].l_mult*(G.GAME.hands['bj_natural'].level - 1), 1)
            G.GAME.hands['bj_natural'].chips = math.max(G.GAME.hands['bj_natural'].s_chips + G.GAME.hands['bj_natural'].l_chips*(G.GAME.hands['bj_natural'].level - 1), 0)
        end
    end
end

local old_debuff_text = Blind.get_loc_debuff_text
function Blind:get_loc_debuff_text()
    local basic = old_debuff_text(self)
    if G.GAME.modifiers["nat_only"] then
        if basic == "" then
            return "Naturals only"
        elseif ((self.debuff) and (self.debuff.hand or self.debuff.h_size_ge or self.debuff.h_size_le)) or (self.name == "The Eye") or (self.name == "The Mouth") then
            return basic .. "/ Naturals only"
        elseif (#G.hand.highlighted == 0) then
            return basic .. "/ Naturals only"
        else
            return "Naturals only"
        end
    else
        return basic
    end
    if ((self.debuff) and (self.debuff.hand or self.debuff.h_size_ge or self.debuff.h_size_le)) or (self.name == "The Eye") or (self.name == "The Mouth") then
        return basic
    end
    return ""
end

----------------------------------------------
------------MOD CODE END----------------------
