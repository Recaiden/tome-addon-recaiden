local default_eyal_descriptors = Birther.default_eyal_descriptors

local default_hammer_descriptors = function(add)
	local base = {
    race = getBirthDescriptor("world", "Arena").descriptor_choices.race,	
    class = getBirthDescriptor("world", "Arena").descriptor_choices.class,
	}

	-- TODO move Whitehoof into undead
	-- 	local base = {

	-- 	race =
	-- 	{
	-- 		__ALL__ = "disallow",
	-- 	},

	-- 	class =
	-- 	{
	-- 		__ALL__ = "disallow"
	-- 	},
	-- }

	-- 	for name, what in pairs(default_eyal_descriptors{}.race) do base.race[name] = what end
	-- 	for name, what in pairs(default_eyal_descriptors{}.class) do base.class[name] = what end

	if add then table.merge(base, add) end
	return base
end

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Demons",
	display_name = _t"Demons: The Hammer of Urh'Rok",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Hammer",
	desc =
		{
			"Centuries ago, the Spellblaze plunged the world into an age of darkness.",
			"The people of Eyal were the lucky ones; Mal'rok was blasted apart, the broken peices of the world transformed to ever-burning hellscapes.",
			"Amidst the flames, the survivors remade themselves into demons, bent on revenge.",
			"They spent centuries traversing the void, preparing themselves for war.",
			"Now, Goedalath has arrived in high orbit.  A linked Orb of Many Ways allows passage through the planetary shield.  Khulmanar's armies are ready.  It is time to unleash the fury of hell!",
		},
	descriptor_choices = default_hammer_descriptors{},
	copy = {
		calendar = "demon", calendar_start_year = 123, calendar_start_day = 70,
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "campaign-hammer+orbital-invasion-platform"
			self.starting_quest = "campaign-hammer+start-demon"
			self.starting_intro = "doombringer"
			self.faction = 'fearscape'
			self.default_wilderness = {"playerpop", "hammer-demon"}

			engine.Faction:setInitialReaction("fearscape", "enemies", -50, true)
			engine.Faction:setInitialReaction("orc-pride", "fearscape", -50, true)
		end,
	},
	game_state = {
		exp_multiplier = 5,
		campaign_name = "hammer",
		ignore_prodigies_special_reqs = true,
		stores_restock_by_level = 1,
		__allow_rod_recall = true,
		__allow_transmo_chest = true,
		grab_online_event_zone = function() return "wilderness-1" end,
		grab_online_event_spot = function(zone, level)
			local find = {type="world-encounter", subtype="maj-eyal"}
			local where = game.level:pickSpotRemove(find)
			while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
			local x, y = mod.class.Encounter:findSpot(where)
			return x, y
		end,
		-- give rares/randbosses extra loot
		random_boss_adjust_fct = function(act)
			local core_rnd_boss_adjust = function(b)
				if b.level <= 30 then
					-- Damage reduction is applied in all cases, acknowledging the frontloaded strength of randbosses and the potential for players to lack tools early
					b.inc_damage = b.inc_damage or {}
					--local change =  (70 * (30 - b.level + 1) / 30) + 20
					local change = math.max(0, 95 - b.level * 4)
					b.inc_damage.all = math.max(-80, (b.inc_damage.all or 0) - change)  -- Minimum of 20% damage
					
					-- Things prone to binary outcomes (0 damage, 0 hit rate, ...) like armor and defense are only reduced if they exceed a cap per level regardless of source
					-- This lets us not worry about stuff like Shield Wall+lucky equipment creating early threats that some builds cannot hurt
					-- Note that while these seem strict they are *not* saying these values are unreasonable early for anything, they're saying they're unreasonable for randbosses specifically
					local max = b.level / 2
					local flat = b:combatGetFlatResist()
					change = (max - flat)
					if flat > max then
						b.flat_damage_armor.all = b.flat_damage_armor.all - (flat - max)
						-- Do NOT activate this log for production, it may trigger undefined upvalue if print is redefined
						-- print("[standard_rnd_boss_adjust]:  Adjusting flat armor", flat, "Max", max, "Change", change)
					end

					if b.level <= 20 then
						local armor = b:combatArmor()
						max = b.level
						change = (max - armor)
						if armor > max then
							b.combat_armor = b.combat_armor - (armor - max)
							-- Do NOT activate this log for production, it may trigger undefined upvalue if print is redefined
							-- print("[standard_rnd_boss_adjust]:  Adjusting armor", armor, "Max", max, "Change", change)
						end

						local defense = b:combatDefense()
						max = b.level
						change = (max - defense)
						if defense > max then
							b.combat_def = b.combat_def - (defense - max)
							-- Do NOT activate this log for production, it may trigger undefined upvalue if print is redefined
							-- print("[standard_rnd_boss_adjust]:  Adjusting defense", defense, "Max", max, "Change", change)
						end

						-- Temporarily just hard removing this early game pending this stat not being spammed everywhere causing tons of damage most people don't even notice is happening
						local retal = rng.table(table.listify(b.on_melee_hit))
						if retal then
							b.on_melee_hit = {}
							--b.on_melee_hit[retal[1]] = retal[2]
						end
					end

					-- Early game melee don't have much mobility which makes randbosses too good at running and pulling more enemies in or being generally frustrating
					b.ai_tactic.escape = 0
					b.ai_tactic.safe_range = 1

					-- Cap the talent level of disabling talents at the minimum of 1 and floor(level / 10)
					-- rnd_boss_restrict is the right way to handle this for most things, but the early game we can assume players have no reasonable way to deal with debuff spam
					-- Tactical tables can have a variety of structures, so we just look in all subtables for a key named "disable"
					if b.level <= 25 then
						for id, level in pairs(b.talents) do
							local talent = b:getTalentFromId(id)
							if talent and talent.tactical and _G.type(talent.tactical) == "table" then
								table.check(
									talent.tactical,
									function(t, where, v, tv)
										if tv == "string" and (v:lower() == "disable") then
											b.talents[id] = math.min(b.talents[id], math.max(1, math.floor(b.level / 10)))
											return false
										else 
											return true 
										end
								end)
							end
						end
					end
					_G.print("[entityFilterPost]:  Done nerfing randboss")
				end
			end
			core_rnd_boss_adjust(act)
			local lev = act.level
			if act.rank == 3.2 then
				for i = 1, 3 do
					local bonus = 1.5 + lev / 25
					local fil = {lev=lev, egos=1, greater_egos_bias = 0, power_points_factor = bonus, nb_themes_add = 1, nb_powers_add = 2, forbid_power_source=act.not_power_source,
											 base_filter = {no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}, 
																			special=function(e)
																				return (not e.unique and e.randart_able) and (not e.material_level or e.material_level >= 1) and true or false
											 end}
					}
					local o = game.state:generateRandart(fil, nil, true)
					if o then
						o.unique, o.randart, o.rare = nil, nil, true
						if o.__original then
							local e = o.__original
							e.unique, e.randart, e.rare = nil, nil, true
						end
						act:addObject(act.INVEN_INVEN, o)
						game.zone:addEntity(game.level, o, "object")
					else
						print("[entityFilterPost]: Failed to generate random object for", tostring(act.name))
					end
				end
			elseif act.rank == 4 then
				act[#act+1] = resolvers.drops{chance=100, nb=9, {tome_drops="boss"} }
				act[#act+1] = resolvers.drop_randart{}
				act[#act+1] = resolvers.drop_randart{}
				act[#act+1] = resolvers.drop_randart{}
			end
		end,
	},
	game_state_execute = function()
		-- Khulmanar is not killed by the Scourge in this timeline, but shouldn't randomly appear.
		game.uniques["mod.class.NPC/Khulmanar, General of Urh'Rok"] = 1
		-- Walrog shouldn't randomly show up in Nur, as he's part of a quest
		game.uniques["mod.class.NPC/Walrog"] = 1
	end,
}
