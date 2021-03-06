newTalent{
	name = "Solar Flare", short_name = "REK_SHINE_SUNLIGHT_SOLAR_FLARE",
	type = {"demented/sunlight", 1}, points = 5,
	require = mag_req1,
	cooldown = function(self, t)
		if self:hasEffect(self.EFF_REK_SHINE_SOLAR_MINIMA) then return t.getCooldownLong(self, t) else return t.getCooldownBase(self, t) end
	end,
	getCooldownBase = function(self, t) return 2 end,
	getCooldownLong = function(self, t) return 14 end,
	tactical = {ATTACKAREA = {LIGHT = 2}},
	positive = 10,
	insanity = function(self, t) if self:hasEffect(self.EFF_REK_SHINE_SOLAR_MINIMA) then return 16 else return 8 end end,
	range = 7,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	radius = function (self, t) return 2 end,
	getDelay = function(self, t) return 3 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local duration = 1 + t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		
		local map_eff = game.level.map:addEffect(
			self, x, y, duration, DamageType.COSMETIC, 
			{dam = t.getDamage(self, t), radius = radius, self = self, talent = t}, 
			0, 5, nil, 
			{type="solar_flare_burst", args = {radius = radius, all_static=true}},
			function(e, update_shape_only)
				if not update_shape_only and e.duration == 1 then
					local DamageType = require("engine.DamageType") --block_path means that it will always hit the tile we've targeted here
					local aoe = {type="ball", radius = e.dam.radius, friendlyfire=true, selffire=true, talent=e.dam.talent, block_path = function(self, t) return false, true, true end}
					e.src.__project_source = e
					local grids = e.src:project(aoe, e.x, e.y, DamageType.LITE_LIGHT, e.dam.dam)
					e.src.__project_source = nil
					
					game.level.map:particleEmitter(e.x, e.y, e.dam.radius, "solar_flare_burst", {radius=e.dam.radius * 0.92, grids=grids, max_alpha=80})

					-- scorched earth
					if e.src:isTalentActive(e.src.T_REK_SHINE_INCINERATOR_WORLD_CUTTER) then
						local se_duration = 4
						if e.src:isTalentActive(e.src.T_REK_SHINE_INCINERATOR_INCINERATOR) then
							se_duration = se_duration + e.src:callTalent("T_REK_SHINE_INCINERATOR_INCINERATOR", "getExtraDuration")
						end
						game.level.map:addEffect(e.src, e.x, e.y, se_duration, DamageType.LIGHT, e.src:callTalent("T_REK_SHINE_INCINERATOR_WORLD_CUTTER", "getDamage"), 0, 5, grids, {type="inferno"}, nil, e.src:spellFriendlyFire())
					end
					
					e.duration = 0
					for _, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
					e.particles = nil
					game:playSoundNear(e.src, "talents/fireflash")
					--let map remove it
				end
			end)
		if self:hasEffect(self.EFF_REK_SHINE_SOLAR_MINIMA) then
			game:onTickEnd(function() 
											 self:removeEffect(self.EFF_REK_SHINE_SOLAR_MINIMA)
										 end)
		elseif self:hasEffect(self.EFF_REK_SHINE_SOLAR_DISTORTION) then
			game:onTickEnd(function() 
											 self:removeEffect(self.EFF_REK_SHINE_SOLAR_DISTORTION)
											 self:setEffect(self.EFF_REK_SHINE_SOLAR_MINIMA, 14, {src=self})
										 end)
		else
			game:onTickEnd(function() 
											 self:setEffect(self.EFF_REK_SHINE_SOLAR_DISTORTION, 14, {src=self})
										 end)
		end
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		local delay = t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[After %d turns, the target area (radius %d) is blasted with a beam of light, dealing %0.2f damage and lighting the area.  
This talent's cooldown goes through a cycle as you cast it repeatedly: 2, 2, 14 (and double insanity)]]):tformat(delay, radius, damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Coronal Shield", short_name = "REK_SHINE_SUNLIGHT_CORONAL_SHIELD",
	type = {"demented/sunlight", 2},
	require = mag_req2,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 22,
	tactical = { BUFF = 2 },
	iconOverlay = function(self, t, p)
		local p = self.sustain_talents[t.id]
		if not p then return "" end
		if p.barrier then return ("%d"):format(p.barrier) end
		if p.recharge then return ("%d/%d"):format(t.getRecharge(self, t) - p.recharge, t.getRecharge(self, t)), "buff_font_smaller" end
		return "Ready", "buff_font_smaller"
	end,
	getShield = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	getDuration = function(self, t) return 3 end,
	getRecharge = function(self, t) return 7 end,
	range = 10,
	targetBeam = function(self, t) return {type="beam", force_max_range=true, range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if not p.recharge then return end
		p.recharge = p.recharge - 1
		if p.recharge <= (t.getRecharge(self, t) - t.getDuration(self, t)) then p.barrier = nil end
		if p.recharge <= 0 then p.recharge = nil end
	end,
	callbackPriorities={callbackOnHit = -10},
	callbackOnHit = function(self, t, cb, src, dt)
		local p = self:isTalentActive(t.id)
		if src == self or src == self.summoner or (src and src.summoner == self) then return end
		if not p then return end
		if p.recharge and p.recharge <= (t.getRecharge(self, t) - t.getDuration(self, t)) then return end
		if cb.value <= 0 or src == self then return end
		if not dt or not dt.damtype or (dt.damtype == DamageType.PHYSICAL or dt.damtype == DamageType.MIND) then return end
		local firing = false
		if not p.recharge then
			p.recharge = t.getRecharge(self, t)
			p.barrier = self:spellCrit(t.getShield(self, t))
			firing = true
		end
		if p.barrier then
			local blocked = math.min(cb.value, p.barrier)
			game:delayedLogDamage(src, self, 0, ("#GOLD#(%d to coronal shield)#LAST#"):format(blocked), false)
			p.barrier = p.barrier - blocked
			cb.value = cb.value - blocked
			if p.barrier <= 0 then p.barrier = nil end
		end
		if firing and src and src.x and src.y then
			local dam = self:spellCrit(t.getDamage(self, t))
			local tg = t.targetBeam(self, t)
			tg.x = src.x
			tg.y = src.y
			self:projectApply(tg, src.x, src.y, Map.ACTOR, function(target, x, y)
				DamageType:get(DamageType.LIGHT).projector(self, x, y, DamageType.LIGHT, dam)
				target:setEffect(target.EFF_DAZZLED, 5, {power=10, apply_power=self:combatSpellpower()})
			end)

			-- scorched earth
			if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_WORLD_CUTTER) then
				local grids = self:project(tg, self.x, self.y, function() end)
				local se_duration = 4
				if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_INCINERATOR) then
					se_duration = se_duration + self:callTalent("T_REK_SHINE_INCINERATOR_INCINERATOR", "getExtraDuration")
				end
				game.level.map:addEffect(self, self.x, self.y, se_duration, DamageType.LIGHT, self:callTalent("T_REK_SHINE_INCINERATOR_WORLD_CUTTER", "getDamage"), 0, 5, grids, {type="inferno"}, nil, self:spellFriendlyFire())
			end
			
			local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(src.x-self.x), math.abs(src.y-self.y)), "corona_beam", {tx=src.x-self.x, ty=src.y-self.y})
		end
		return true
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {}
		self:talentParticles(ret, {type="phantasm_shield"})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a protective shield of shining plamsa.
		Whenever you would take elemental damage (neither physical nor mind) the shield condenses, blocking %d elemental damage over the next %d turns, and releasing a ray of sunlight towards the attacker that deals %d light damage and dazzles any affected creature (deal 10%% less damage) for 5 turns. 
The shield can only be triggered every %d turns.
The shield power and beam damage will increase with your Spellpower.]]):tformat(t.getShield(self, t), t.getDuration(self, t), damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getRecharge(self, t))
	end,
}

newTalent{
	name = "Lightspeed Step", short_name = "REK_SHINE_SUNLIGHT_LIGHTSPEED_STEP",
	type = {"demented/sunlight", 3},
	require = mag_req3, points = 5,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	positive = 10,
	insanity = -10,
	no_energy = true,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 20, 12)) end,
	range = function(self, t) return math.floor(self.lite) end,
	requires_target = true,
	target = function(self, t)	return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's teleportation fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges in a flash of light!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end

		game:playSoundNear(self, "talents/sun_move")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleports you to up to %d tiles away, to a targeted location in line of sight.
The range will increase with your Light Radius.]]):tformat(range)
	end,
}

newTalent{
	name = "Nova Blast", short_name = "REK_SHINE_SUNLIGHT_NOVA_BLAST",
	type = {"demented/sunlight", 4},
	require = mag_req4,
	points = 5,
	positive = -10,
	insanity = -25,
	cooldown = 16,
	tactical = { ATTACKAREA = { LIGHT = 4 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="widebeam", force_max_range=true, radius=1, range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 370) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, DamageType.REK_SHINE_LIGHT_STUN, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "solar_beam_wide", {tx=x-self.x, ty=y-self.y})

		-- scorched earth
		if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_WORLD_CUTTER) then
			local se_duration = 4
			if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_INCINERATOR) then
				se_duration = se_duration + self:callTalent("T_REK_SHINE_INCINERATOR_INCINERATOR", "getExtraDuration")
			end
			game.level.map:addEffect(self, self.x, self.y, se_duration, DamageType.LIGHT, self:callTalent("T_REK_SHINE_INCINERATOR_WORLD_CUTTER", "getDamage"), 0, 5, grids, {type="inferno"}, nil, self:spellFriendlyFire())
		end
		
		--game:shakeScreen(10, 3)
		game:playSoundNear(self, "talents/reality_breach")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Drawing on your deep insight into solar mysteries, you create a powerful 3-wide beam of radiance that always goes as far as possible.	The beam deals %0.2f light damage and stuns enemies for 3 turns.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, damage))
	end,
}
