newTalent{
	name = "Zodiac Step", short_name = "REK_HEKA_CHRONORIUM_TELEPORT",
	type = {"spell/other", 1}, require = mag_req1, points = 1,
	cooldown = 3,
	tactical = { CLOSEIN = 1, ESCAPE = 1 },
	range = 10,
	no_energy = true,
	is_teleport = true,
	target = function(self, t) return {type="hit", pass_terrain = true, nolock=true, range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		local geff = game.level.map:hasEffectType(x, y, DamageType.REK_HEKA_PYLON_MARKER)
		if not geff then return end

		local ox, oy = self.x, self.y
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's time folding fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from a space-time rift!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "arcane_teleport_stream", { dx = ox - self.x, dy = oy - self.y, dir_c=0, color_r=160, color_g=50, color_b=200})
		end
		game:playSoundNear(self, "talents/teleport")
		
		return true
	end,
	info = function(self, t)
		return ([[Instantly teleport to a nearby zodiac pylon.]]):tformat()
	end,
}

newTalent{
	name = "Zodiac Pylon", short_name = "REK_HEKA_CHRONORIUM_PYLON",
	type = {"spell/chronorium", 1}, require = mag_req1, points = 5,
	cooldown = 15,
	hands = 10,
	tactical = { CLOSEIN = 1, ESCAPE = 1 },
	range = 10,
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_HEKA_CHRONORIUM_TELEPORT, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_REK_HEKA_CHRONORIUM_TELEPORT)
	end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	createPylon = function(self, t, x, y)
		local img = "zodiac_0"..((game.calendar:getDayOfYear(game.turn) % 7) + 1)
		game.level.map:addEffect(self,
														 x, y, t:_getDuration(self),
														 DamageType.REK_HEKA_PYLON_MARKER, 99,
														 0,
														 5, nil,
														 MapEffect.new{zdepth=6, alpha=0, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img=img, radius=0, base_rot=0, speed = 0, oversize=0.7, a=250}}, effect_shader="shader_images/blank_effect.png"},
														 nil, false
		)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		t.createPylon(self, t, self.x, self.y)
		t.createPylon(self, t, x, y)
		
		return true
	end,
	info = function(self, t)
		return ([[Prepare the local structure of time for your passage, creating a zodiac pylon underneath you and at the targeted location.   You can instantly teleport to the pylons, and they last for %d turns.]]):tformat(t:_getDuration(self))
	end,
}

newTalent{
	name = "Recurring Visions", short_name = "REK_HEKA_CHRONORIUM_VISIONS",
	type = {"spell/chronorium", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.floor(15 * self.level/10) end,
	getSplit = function(self, t) return self:combatTalentLimit(t, 0.8, 0.3, 0.6) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if dam < t:_getThreshold(self) then return {dam=dam} end
		local split = math.min(dam - t:_getThreshold(self),  dam * t:_getSplit(self))
		self:setEffect(self.EFF_REK_HEKA_RECURRING_VISIONS, 2, {src=self, power=split, thresh=t:_getThreshold(self), ratio=t:_getSplit(self)})
		game:delayedLogDamage(src, self, 0, ("#WHITE#(%d to the future)#LAST#"):format(split), false)
		return {dam=dam-split}
	end,
	info = function(self, t)
		return ([[Misfortune struggles to find you in the present, but is always waiting in the moments yet to come.  Any incoming damage of at least %d (based on level) is split, with up to %d%% of the damage over the threshold being taken after your next turn.]]):tformat(t:_getThreshold(self), t:_getSplit(self)*100)
	end,
}

newTalent{
	name = "Riven Clock", short_name = "REK_HEKA_CHRONORIUM_CLOCK",
	type = {"spell/chronorium", 3}, require = mag_req3, points = 5,
	mode = "sustained",
	cooldown = 10,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=200, radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getScale = function(self, t) return self:combatTalentScale(t, 0.05, 0.10) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	doWave = function(self, t, x, y, distance)
		local dam = self:spellCrit(t:_getDamage(self)*(1+distance*t.getScale(self, t)))
		local tg = self:getTalentTarget(t)
		game:onTickEnd(function()
				self:project(tg, x, y, function(px, py)
											 local target = game.level.map(px, py, Map.ACTOR)
											 if target then
												 DamageType:get(DamageType.TEMPORAL).projector(self, px, py, DamageType.TEMPORAL, dam)
											 end
				end)
		end)
	end,
	callbackOnSummonKill = function(self, t, pet, target) t.callbackOnKill(self, t, target) end,
	callbackOnKill = function(self, t, target)
		if not self:knowTalent(self.T_REK_HEKA_CHRONORIUM_PYLON) then return end
		self:callTalent(self.T_REK_HEKA_CHRONORIUM_PYLON, "createPylon", target.x, target.y)
		local duration = self:callTalent(self.T_REK_HEKA_CHRONORIUM_PYLON, "getDuration")
		self:project(
			{type="ball", range=0, radius=10, talent=t}, self.x, self.y,
			function(px, py)
				local geff = game.level.map:hasEffectType(x, y, DamageType.REK_HEKA_PYLON)
				if not geff then return end
				geff.duration = duration
		end)
	end,
	callbackOnTeleport = function(self, t, teleported, ox, oy, x, y)
		if not teleported then return end
		local distance = core.fov.distance(self.x, self.y, ox, oy)
		-- Project at both the entrance and exit
		t.doWave(self, t, self.x, self.y, distance)
		t.doWave(self, t, ox, oy, distance)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local ret = {}
		if not self:addShaderAura("stone_skin", "crystalineaura", {time_factor=1500, spikeOffset=0.123123, spikeLength=0.9, spikeWidth=3, growthSpeed=2, color={0xD7/255, 0xD7/255, 0xD7/255}}, "particles_images/heka_spikes.png") then
			ret.particle = self:addParticles(Particles.new("stone_skin", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("stone_skin")
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[When you teleport, you fire a wave of temporal energy in a radius of %d around both the start and the destination point that damages enemies for %0.1f.  The damage is increased by %d%% per tile traveled.

When you kill a creature, create a zodiac pylon at its location, and refresh the duration of existing pylons.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.TEMPORAL, t.getDamage(self, t)), t:_getScale(self)*100)
	end,
}

newTalent{
	name = "Spaces Between Seconds", short_name = "REK_HEKA_CHRONORIUM_SPACES",
	type = {"spell/chronorium", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getClear = function(self, t) return self:combatTalentLimit(t, 0.5, 0.1, 0.3) end,
	callbackOnTeleport = function(self, t, teleported, ox, oy, x, y)
		if not teleported then return end
		local eff = self:hasEffect(self.EFF_REK_HEKA_RECURRING_VISIONS)
		if not eff then return end

		eff.power = eff.power * (1 - t:_getClear(self))
	end,
	info = function(self, t)
		return ([[When you teleport, some potential harm is left behind in your old location, removing %d%% of your outstanding Recurring Visions damage.]]):tformat(t:_getClear(self)*100)
	end,
}
