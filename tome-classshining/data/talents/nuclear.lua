newTalent{
	name = "Solar Flare", short_name = "REK_SHINE_NUCLEAR_SOLAR_FLARE",
	type = {"demented/nuclear", 1},
	require = mag_req1,
	cooldown = 12,
	tactical = {ATTACKAREA = {LIGHT = 2}},
	positive = 15,
	range = 7,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	radius = function (self, t) return 2 end,
	getDelay = function(self, t) return 2 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local duration = 1 + t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		
		local map_eff = game.level.map:addEffect(self, x, y, duration, DamageType.NULL_TYPE, 
		{dam = t.getDamage(self, t), radius = radius, self = self, talent = t}, 
		0, 5, nil, 
		{type="warning_ring", args = {radius = radius}},
		function(e, update_shape_only)
			if not update_shape_only and e.duration == 1 then
				local DamageType = require("engine.DamageType") --block_path means that it will always hit the tile we've targeted here
				local aoe = {type="ball", radius = e.dam.radius, friendlyfire=true, selffire=true, talent=e.dam.talent, block_path = function(self, t) return false, true, true end}
				e.src.__project_source = e
				local grids = e.src:project(aoe, e.x, e.y, DamageType.LITE_LIGHT, e.dam.dam)
				e.src.__project_source = nil
				game.level.map:particleEmitter(e.x, e.y, e.dam.radius, "sunburst", {radius=e.dam.radius * 0.92, grids=grids, tx=e.x, ty=e.y, max_alpha=80})
				e.duration = 0
				for _, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
				e.particles = nil
				game:playSoundNear(self, "talents/fireflash")
				--let map remove it
			end
			
		end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		local delay = t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[After %d turns, the target area in (radius %d) is blasted with a beam of light, dealing %0.2f damage and lighting the area]]):
		tformat(delay, radius, damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Coronal Shield", short_name = "REK_SHINE_NUCLEAR_CORONAL_SHIELD",
	type = {"demented/nuclear", 2},
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
		if p.recharge then return ("%d / %d"):format(t.getRecharge(self, t) - p.recharge, t.getRecharge(self, t)), "buff_font_smaller" end
		return "Ready", "buff_font_smaller"
	end,
	getShield = function(self, t) return self:combatTalentSpellDamage(t, 40, 200) end,
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
	callbackOnHit = function(self, t, cb, src, dt)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if p.recharge and p.recharge < 5 then return end
		if cb.value <= 0 or src == self then return end
		if not dt or not dt.type or (dt.type == DamageType.PHYSICAL or dt.type == DamageType.MIND) then return end
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
		if firing and src.x and src.y then
			local dam = self:spellCrit(t.getDamage(self, t))
			local tg = t.targetBeam(self, t)
			tg.x = src.x
			tg.y = src.y
			self:projectApply(tg, src.x, src.y, Map.ACTOR, function(target, x, y)
				DamageType:get(DamageType.LIGHT).projector(self, x, y, DamageType.LIGHT, dam)
				target:setEffect(target.EFF_DAZZLED, 5, {power=10, apply_power=self:combatSpellpower()})
			end)
			game.level.map:particleEmitter(src.x, src.y, self:getTalentRadius(t), "sunburst", {radius=self:getTalentRadius(t), max_alpha=80})
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
		Whenever you would take elmental damage (neither physical nor mind) the shield condenses, blocking %d elemental damage over the next %d turns, and releasing a ray of sunlight towards the attacker that deals %d light damage and dazzles any affected creature (deal 10%% less damage) for 5 turns. 
The shield can only be triggered every %d turns.
The shield power and beam damage will increase with your Spellpower.]]):tformat(t.getShield(self, t), t.getDuration(self, t), damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getRecharge(self, t))
	end,
}

newTalent{
	name = "Lightspeed Step", short_name = "REK_SHINE_NUCLEAR_LIGHTSPEED_STEP",
	type = {"demented/nuclear", 3},
	require = mag_req3, points = 5,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	positive = 30,
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
			game.logSeen(self, "%s's space-time folding fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from a space-time rift!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end
		
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleports you to up to %d tiles away, to a targeted location in line of sight.
The range will increase with your Light Radius.]]):tformat(range)
	end,
}

newTalent{
	name = "Nova Blast", short_name = "REK_SHINE_NUCLEAR_NOVA_BLAST",
	type = {"demented/nuclear", 4},
	require = mag_req4,
	points = 5,
	positive = -40,
	insanity = 25,
	cooldown = 16,
	tactical = { ATTACKAREA = { LIGHT = 4 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="widebeam", force_max_range=true, radius=1, range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 370) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, DamageType.LIGHT, dam)
		--TODO stun
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam_wide", {tx=x-self.x, ty=y-self.y})
		--game:shakeScreen(10, 3)
		game:playSoundNear(self, "talents/reality_breach")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Using your near-perfect knowledge of beam spells you combine them all into a powerful 3-wide beam of radiance.
		The beam deals %0.2f light damage, stuns enemies for 3 turns, and always goes as far as possible.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, damage))
	end,
}