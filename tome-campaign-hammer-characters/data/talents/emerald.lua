newTalent{
	name = "Seething Skin", short_name="REK_EMERALD_SEETHING_SKIN",
	type = {"race/emerald", 1}, require = racial_req1, points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 9, 45, 25, false, 1.0)) end,
	tactical = { HEAL = 2 },
	getHealing = function(self, t) return 12 + self:getCon() * 1.5 end,
	getRegen = function(self, t) return 6 + self:getCon() * 0.6 end,
	getResist = function(self, t) return math.min(50, 10+self.level*1.6) end,
	getAffinity = function(self, t) return math.min(15, 5+self.level/3) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {
																[DamageType.ACID] = t:_getResist(self),
		})
		self:talentTemporaryValue(p, "damage_affinity", {
																[DamageType.ACID] = t:_getAffinity(self),
		})
	end,
	callbackOnLevelup = function(self, t)
		self:updateTalentPassives(t)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 8, {power=t.getRegen(self,  t)})
		self:attr("allow_on_heal", 1)
		self:heal(t.getHealing(self, t), self)
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		return ([[Surge your life force to heal %d life immediately and increase your life regeneration by %d for 8 turns.
The life healed will increase with your Constitution.

You also gain %d%% resistance and %d%% affinity to acid, based on your level.]]):tformat(t.getRegen(self,  t), t.getHealing(self, t), t:_getResist(self), t:_getAffinity(self))
	end,
}

newTalent{
	name = "Adaptive Biology", short_name = "REK_EMERALD_REVENANT",
	type = {"race/emerald", 2}, require = racial_req2, points = 5,
	mode = "passive",
	getPool = function(self, t) return math.ceil(self:combatTalentScale(t, 6, 25))*4 end,
	transferRate = function(self, t) return 4 end,
	passives = function(self, t, p)
		local rate = t:_transferRate(self)
		local pool = t:_getPool(self)
		local bias = self.adaptive_biology_bias or {
			["conf"] = false,
			["silence"] = false,
			["stun"] = false,
			["pin"] = false,
		}
		local state = self.adaptive_biology_allocation or {
			["conf"] = pool/4,
			["silence"] = pool/4,
			["stun"] = pool/4,
			["pin"] = pool/4,
		}
		-- account for any raises in the talent
		pool = pool - state.conf - state.silence - state.stun - state.pin

		-- if you aren't currently affected, lose some
		if not bias.conf and state.conf >= rate then state.conf = state.conf - rate   pool = pool + rate end
		if not bias.stun and state.stun >= rate then state.stun = state.stun - rate   pool = pool + rate end
		if not bias.pin and state.pin >= rate then state.pin = state.pin - rate   pool = pool + rate end
		if not bias.silence and state.silence >= rate then state.silence = state.silence - rate   pool = pool + rate end

		while pool >= 4 do
			state.conf = state.conf + 1
			state.stun = state.stun + 1
			state.pin = state.pin + 1
			state.silence = state.silence + 1
			pool = pool - 4
		end
		self.adaptive_biology_allocation = state
		
		self:talentTemporaryValue(p, "stun_immune", state.stun/100)
		self:talentTemporaryValue(p, "confusion_immune", state.conf/100)
		self:talentTemporaryValue(p, "pin_immune", state.pin/100)
		self:talentTemporaryValue(p, "silence_immune", state.silence/100)
		
		self:talentTemporaryValue(p, "size_category", 1)
	end,
	callbackOnActBase = function(self, t)
		local is_stun = false
		local is_conf = false
		local is_pin = false
		local is_sil = false
		
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.confusion then is_conf = true end
			if e.subtype.silence then is_sil = true end
			if e.subtype.stun then is_stun = true end
			if e.subtype.pin then is_pin = true end
		end
		if not is_stun and not is_conf and not is_pin and not is_sil then return end

		self.adaptive_biology_bias = {
			["conf"] = is_conf,
			["silence"] = is_sil,
			["stun"] = is_stun,
			["pin"] = is_pin,
		}
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		local pool = t:_getPool(self)
		local state = self.adaptive_biology_allocation or {
			["conf"] = pool/4,
			["silence"] = pool/4,
			["stun"] = pool/4,
			["pin"] = pool/4,
		}
		return ([[You have pool of %d percentage points of status immunity, distributed among stun immunity, confusion immunity, silence immunity, and pinning immunity.  When you start a turn affected by one of these statuses, your immunities shift to match.
	    Stun: %d%%
	    Confusion: %d%%
	    Pinning: %d%%
	    Silence: %d%%

Also, your size category increases by one, making you about as big as a yeek.

#{italic}#...constantly growing, changing, adapting, all throughout their lives...#{normal}#]]):tformat(t.getPool(self, t), state.stun, state.conf, state.pin, state.silence)
	end,
}

newTalent{
	name = "Colossus Might", short_name = "REK_EMERALD_COLOSSUS_MIGHT",
	type = {"race/emerald", 3}, require = racial_req3,	points = 5,
	mode = "passive",
	getPowerRatio = function(self, t) return math.min(1.0, self:combatTalentScale(t, 0.5, 0.9, 1.0)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_generic_power", self:getCon() * t:_getPowerRatio(self))
		self:talentTemporaryValue(p, "size_category", 1)
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_CON then self:updateTalentPassives(t) end
	end,
	info = function(self, t)
		return ([[You add %d%% of your Constitution to all of your powers.

Also, your size category increases by one, making you about as big as a human.

#{italic}#More than any other demons, the children of emerald are still creatures of the primal jungle.#{normal}#]]):tformat(t:_getPowerRatio(self)*100)
	end,
}

function setupSummon(self, m, x, y, no_control)
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.no_inventory_access = true
	m.no_points_on_levelup = true
	m.save_hotkeys = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	m.ai_state.target_last_seen = table.clone(self.ai_state.target_last_seen)
	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	local main_weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
	m:attr("combat_apr", self:combatAPR(main_weapon))
	m.inc_damage = table.clone(self.inc_damage, true)
	m.resists_pen = table.clone(self.resists_pen, true)
	m:attr("stun_immune", self:attr("stun_immune"))
	m:attr("blind_immune", self:attr("blind_immune"))
	m:attr("pin_immune", self:attr("pin_immune"))
	m:attr("confusion_immune", self:attr("confusion_immune"))
	m:attr("numbed", self:attr("numbed"))
	if game.party:hasMember(self) then


		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="summon",
			title=_t"Summon",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end
	m:resolve() m:resolve(nil, true)
	m:forceLevelup(self.level)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "summon")

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
end

newTalent{
	name = "Wretched Horde", short_name = "REK_EMERALD_WRETCHED_HORDE",
	type = {"race/emerald", 4}, require = racial_req4, points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 45, 25, false, 1.0)) end, -- Limit >6
	range = 4,
	no_npc_use = true, -- make available to NPCs?
	getStats = function(self, t) return self:combatScale(self:getCon() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "size_category", 1)
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 3 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				break
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "demon", subtype = "minor",
				display = "u",
				name = _t"wretchling", color=colors.GREEN,
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_minor_wretchling.png"}}},
				desc = _t"A swarming acid demon, summoned to help.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				size_category = 1,
				life_rating = 8,
				max_life = resolvers.rngavg(50,80),
				combat_atk = resolvers.levelup(1, 1, 3),

				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = {
					str=t:_getStats(self),
					mag=t:_getStats(self),
					cun=t:_getStats(self),
					wil=t:_getStats(self),
					dex=t:_getStats(self),
					con=t:_getStats(self),
				},
				resolvers.equip{
					{type="weapon", subtype="longsword", autoreq=true},
					{type="weapon", subtype="dagger", autoreq=true},
				},

				level_range = {1, self.level}, exp_worth = 0,
				silent_levelup = true,

				combat_armor = 13, combat_def = 8,

				resists={[DamageType.ACID] = 100},
				
				resolvers.talents{
					[Talents.T_RUSH]=6,
					[Talents.T_ACID_BLOOD]={base=3, every=10, max=6},
					[Talents.T_CORROSIVE_VAPOUR]={base=3, every=10, max=6},
				},
				resolvers.sustains_at_birth(),
				
				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 6,
				ai_target = {actor=target},
				no_drops = 1,
			}
			setupSummon(self, m, x, y)
			m.temporary_level = true
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Reach up to the fearscape and summon down your distant kin, calling 3 wretchlings to your side for 6 turns.
		All their primary stats will be set to %d (based on your Constitution).
		Your increased damage, damage penetration, and many other stats will be inherited.

Also, your size category increases by one, making you about as big as an ogre.

#{italic}#There's a lot to hate about wretchlings: the acid, the biting, the shrieking, etc.  But the worst is that they never attack alone.#{normal}#]]):tformat(t:_getStats(self))
	end,
}
