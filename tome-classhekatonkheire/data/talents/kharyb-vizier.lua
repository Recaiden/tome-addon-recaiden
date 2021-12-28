newTalent{
	name = "Light Work", short_name = "REK_HEKA_VIZIER_RESERVOIR",
	type = {"spell/null-vizier", 1}, require = mag_req1, points = 5,
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
			eff.set_shader = true
			self.shader = "invis_edge"
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		return r
	end,
	deactivate = function(self, t, r)
		if eff.set_shader then
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
	type = {"spell/null-vizier", 2},	require = mag_req2, points = 5,
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
		self:project(tg, x, y, DamageType.REK_HEKA_LIGHT_PUNISHMENT, {dam=self:spellCrit(t.getDamage(self, t)*getKharybdianTempo(self, t.id)), amp=t.getPunishment(self, t)})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Shine forth with the overwhelming radiance of the other place, striking enemies in  a circle of radius 1.  The energy deas %0.1f physical damage, plus %0.1f per non-other effect on a target (up to 7 effects).
Sustains are not effects.
Spellpower: increases damage.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*t.getPunishment(self, t)))
	end,
}

newTalent{
	name = "Empyreal Throne", short_name = "REK_HEKA_VIZIER_AURA",
	type = {"spell/null-vizier", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getDazzle = function(self, t) return self:combatTalentLimit(t, 50, 6, 18) end,
	callbackOnHit = function(self, t, dam, src, death_note)
		if not src or not src.setEffect then return dam end
		if src:hasProc("heka_throne") then return end
		src:setProc("heka_throne", true, 10)
		src:setEffect(src.EFF_DAZZLED, 5, {src=self, power=t:_getDazzle(self), apply_power=self:combatSpellpower()})
	end,
	info = function(self, t)
		return ([[The radiance of the other place surrounds and protects you.  An enemy that damages you may then be dazzled (#SLATE#Spell save#LAST#) for 5 turns, reducing the damage they do to you by %d%%.  Each enemy can only be affected once every 10 of their turns.]]):tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "The Sun Beneath the Sea", short_name = "REK_HEKA_VIZIER_SUN",
	type = {"spell/null-vizier", 4}, require = mag_req4, points = 5,
	cooldown = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	hands = 10, drain_hands = 5,
	getBlindResist = function(self, t) return math.min(1, self:combatTalentScale(t, 0.3, 1.0)) end,
	getMaxCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 9)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t} end,
	burn = function(self, t)
		local tg = self:getTalentTarget(t)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		self:project(
			tg, self.x, self.y,
			function(px, py)
				local target = game.level.map(x, y, Map.ACTOR)
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

		action = function(self, t)
		local tg = self:getTalentTarget(t)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		self:project(tg, self.x, self.y, DamageType.BLIND, 4)
		t.burn(self, t)
		tg.friendlyfire = true
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
		
		local r = {}
		self:effectTemporaryValue(r, "blind_immune", t:_getBlindResist(self))
		return r
	end,
	deactivate = function(self, t, r)
		return true
	end,
	info = function(self, t)
		return ([[Let the radiance of the other place flow through you, removing ay blindness effects and making you immune to blindness, while blinding enemies within range %d for %d turns (#SLATE#Spellpower vs Physical#LAST#).
Each turn, the radiance will reduce enemy resistance to damage by %d%%, stacking up to %d times.]]):tformat(self:getTalentRadius(t), 4, 5, t:_getMaxCount(self))
	end,
}
