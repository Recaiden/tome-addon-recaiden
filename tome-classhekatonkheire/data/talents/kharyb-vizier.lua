newTalent{
	name = "Light Work", short_name = "REK_HEKA_VIZIER_INVIS",
	type = {"spell/null-vizier", 1}, require = mag_req_high1, points = 5,
	drain_hands = 5,
	cooldown = 16,
	mode = "sustained",
	tactical = { ESCAPE = 2, DEFEND = 2 },
	no_energy = function(self, t) return self:isTalentActive(t.id) end,
	getInvisibilityPower = function(self, t) return math.ceil(self:combatTalentSpellDamage(t, 10, 50)) end,
	getDamPower = function(self, t) return self:combatTalentScale(t, 10, 30) end,
	activate = function(self, t)
		local r = {}
		self:talentTemporaryValue(r, "invisible", t:_getInvisibilityPower(self))
		self:effectTemporaryValue(r, "blind_inc_damage", t:_getDamPower(self))
		if not self.shader then
			r.set_shader = true
			self.shader = "invis_edge"
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		return r
	end,
	deactivate = function(self, t, r)
		if r.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		return ([[Split your flesh with infinite precision and grasp the light itself, bending it around you to become invisible (%d power based on spellpower).  While invisible, all damage you deal against blinded foes is increased by +%d%%.
Deactivating this talent is instant.]]):tformat(t:_getInvisibilityPower(self), t:_getDamPower(self))
	end,
}

newTalent{
	name = "Photohammer", short_name = "REK_HEKA_VIZIER_ATTACK",
	type = {"spell/null-vizier", 2},	require = mag_req_high2, points = 5,
	cooldown = 10,
	hands = 30,
	requires_target = true,
	range = 9,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 0, 230) end,
	getPunishment = function(self, t) return self:combatTalentLimit(t, 0.6, 0.1, 0.35) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.REK_HEKA_PHYSICAL_PUNISHMENT, {dam=self:spellCrit(t.getDamage(self, t)*getKharybdianTempo(self, t.id)), amp=t.getPunishment(self, t)})

		game.level.map:particleEmitter(x, y, tg.radius, "ellipse_burst", {radius=tg.radius, tx=x, ty=y, max_alpha=80, stretch_y=0.5})
		local particles = {type="light"}
		if core.shader.allow("adv") then
			particles = {type="volumetric", args={kind="conic_cylinder", life=14, base_rotation=rng.range(160, 200), radius=4, y=1.8, density=40, shininess=20, growSpeed=0.006, img="photohammer"}}
		end
		game.level.map:particleEmitter(x, y, 1, particles.type, particles.args)

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Shine forth with the overwhelming radiance of the other place, striking enemies in a circle of radius 1.  The energy deals %0.1f physical damage, plus %0.1f per non-other effect on a target (up to 7 effects).
Sustains are not effects.
Spellpower: increases damage.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*t.getPunishment(self, t)))
	end,
}

newTalent{
	name = "Empyreal Throne", short_name = "REK_HEKA_VIZIER_AURA",
	type = {"spell/null-vizier", 3}, require = mag_req_high3, points = 5,
	mode = "passive",
	getDazzle = function(self, t) return self:combatTalentLimit(t, 50, 6, 18) end,
	callbackOnHit = function(self, t, dam, src, death_note)
		if not src or not src.setEffect then return dam end
		if src == self then return dam end
		if src:hasProc("heka_throne") then return end
		src:setProc("heka_throne", true, 10)
		src:setEffect(src.EFF_DAZZLED, 5, {src=self, power=t:_getDazzle(self), apply_power=self:combatSpellpower()})
		return dam
	end,
	info = function(self, t)
		return ([[The radiance of the other place surrounds and protects you.  An enemy that damages you may then be dazzled (#SLATE#Spell save#LAST#) for 5 turns, reducing the damage they do to you by %d%%.  This can only affect a given creature once every 10 of their turns.]]):tformat(t.getDazzle(self, t))
	end,
}

newTalent{
	name = "The Sun Beneath the Sea", short_name = "REK_HEKA_VIZIER_SUN",
	type = {"spell/null-vizier", 4}, require = mag_req_high4, points = 5,
	cooldown = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	hands = 10, drain_hands = 5,
	no_sustain_autoreset = true,
	getBlindResist = function(self, t) return math.min(1, self:combatTalentScale(t, 0.3, 1.0)) end,
	getMaxCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 9)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t} end,
	burn = function(self, t)
		local tg = self:getTalentTarget(t)
		--game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		self:project(
			tg, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_REK_HEKA_WITHERED_RESISTANCES, 1, {src=self, power=5, max_power=5*t:_getMaxCount(self)})
			end
		)
	end,
	callbackOnActBase = function(self, t)
		t.burn(self, t)
	end,
	activate = function(self, t)
		self:removeEffectsFilter(self, {subtype={blind=true}}, 10)

		local tg = self:getTalentTarget(t)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		self:project(tg, self.x, self.y, DamageType.BLIND, 4)
		t.burn(self, t)
		tg.friendlyfire = true
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		game:playSoundNear(self, "talents/heal")
		
		local r = {}
		self:effectTemporaryValue(r, "blind_immune", t:_getBlindResist(self))
		r.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=0.5, a=150, appear=8, y=-0.68, speed=0, img="sun_sea_orb", radius=0}))
		if core.shader.active(4) then
			r.aura = self:addParticles(Particles.new("shader_shield", 1, {size_factor=0.2+self:getTalentRadius(t)*1.78, blend=true, img="vizier_sun_aura"}, {type="shield", shieldIntensity=0.02, ellipsoidalFactor=1, color={1,0.8,0.4}}))
		end

		return r
	end,
	deactivate = function(self, t, r)
		self:removeParticles(r.particle)
		if r.aura then self:removeParticles(r.aura) end
		return true
	end,
	info = function(self, t)
		return ([[Let the radiance of the other place flow through you, removing ay blindness effects and making you immune to blindness, while blinding enemies within range %d for %d turns (#SLATE#Spellpower vs Physical#LAST#).
Each turn, the radiance will reduce enemy resistance to damage by %d%%, stacking up to %d times.]]):tformat(self:getTalentRadius(t), 4, 5, t:_getMaxCount(self))
	end,
}
