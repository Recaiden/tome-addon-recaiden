newTalent{
	name = "Life in the Flames", short_name = "REK_DEML_PYRO_FLAMES",
	type = {"steamtech/pyromaniac", 1},
	require = steam_req_high1,
	points = 5,
	mode = "sustained",
	cooldown = 5,
	no_energy = true,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 55) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		self:addShaderAura("burning_wake", "awesomeaura", {time_factor=3500, alpha=0.6, flame_scale=0.6}, "particles_images/wings.png")
		return {
		}
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("burning_wake")

		return true
	end,

	info = function(self, t)
		return ([[Upgrade your bombs with a flammable gel.  While sustained, your Explosive Charges,  Mecharachnid Mine, and Pyre Bomb inflict a burn on their targets, dealing %0.2f fire damage over 4 turns, but cost an additional 5 steam.]]):format(damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Pyre Bomb", short_name = "REK_DEML_PYRO_PYRE_BOMB",
	type = {"steamtech/pyromaniac", 2},
	require = steam_req_high2,
	points = 5,
	cooldown = 5,
	range = 6,
	steam = function(self, t)
		local cost = 20
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then cost  = cost + 5 end
		return cost
	end,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = {STUN = 2} },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=true}
	end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 330) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
  action = function(self, t)
		local rad = self:getTalentRadius(t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		local dam = self:steamCrit(t.getDamage(self, t))
		self:project(tg, tx, ty, DamageType.REK_DEML_FIRE_STUN, {dam=dam, dur=t.getDuration(self, t)})
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then
			local burn = self:callTalent(self.T_REK_DEML_PYRO_FLAMES, "getDamage")
			self:project(tg, tx, ty, DamageType.FIREBURN, {dam=burn, dur=4, initial=0})
		end
		game.level.map:particleEmitter(tx, ty, rad, "fireflash", {radius=rad})	
		return true
	end,
	info = function(self, t)
		return ([[Lob a colossal bomb that detonates on impact, dealing %d fire damage in radius %d  and stunning (#SLATE#Steampower vs Physical#LAST#) all targets for %d turns.
Steampower: increases damage]]):format(damDesc(self, DamageType.FIRE, t.getDamage(self, t)), self:getTalentRadius(t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Blast Rider", short_name = "REK_DEML_PYRO_BLASTRIDER",
	type = {"steamtech/pyromaniac", 3},
	require = steam_req_high3,
	points = 5,
	mode= "passive",
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.10, 0.2, 0.75) end,
	gainSpeed = function(self, t)
		self:setEffect(self.EFF_SPEED, 3, {power=t.getSpeed(self, t)})
	end,
	info = function(self, t)
		return ([[The sound of detonators, bombs, and flames is music to your ears.
Whenever you detonate at least 3 explosive charges at once, you gain a burst of energy, increasing your speed by %d%% for 3 turns.]]):format(t.getSpeed(self, t)*100)
	end,
}

newTalent{
	name = "Demon of the Ash", short_name = "REK_DEML_PYRO_DEMON",
	type = {"steamtech/pyromaniac", 4},
	require = steam_req_high4,
	points = 5,
	mode = "sustained",
	sustain_steam = 20,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getFireDamageIncrease = function(self, t) return self:combatTalentScale(t, 2.5, 10) end,
	getPenetration = function(self, t) return self:combatTalentLimit(t, 60, 17, 50) end,
	getBonusDamage = function(self, t) return self:combatTalentSteamDamage(t, 1, 10) end,
	doConsumeBurn = function(self, t, target)
		if not target then return end
		if target.dead then return end
		local burn = target:hasEffect(target.EFF_BURNING)
		if not burn then return end
		local dam = burn.power * burn.dur + t.getBonusDamage(self, t)
		target:removeEffect(target.EFF_BURNING)

		local old_ps = self.__project_source
		
		self.__project_source = t
		DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, dam)
		self.__project_source = old_ps
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")

		local particle
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			particle = self:addParticles(Particles.new("shader_wings", 1, {infinite=1, x=bx, y=by}))
		else
			particle = self:addParticles(Particles.new("wildfire", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.FIRE] = t.getPenetration(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t) 
		return ([[Devote part of your steam system to the production of super-heated explosives, increasing all your fire damage by %0.1f%% and your fire resistance penetration by %d%%.  Whenever you deal non-fire damage to a burning enemy, you will consume the burn, dealing all of the remaining damage (plus %0.2f) immediately.]]):format(t.getFireDamageIncrease(self,t), t.getPenetration(self, t), t.getBonusDamage(self, t)) 
	end,
}
