newTalent{
	name = "Solar Citadel", short_name = "REK_SHINE_SEALS_SOLAR_CITADEL",
	type = {"celestial/seals", 1}, require = mag_req_high1, points = 5,
	cooldown = 20,
	positive = function(self, t) return 20 + (self:knowTalent(self.T_REK_SHINE_SEALS_ARMAMENTS) and 10 or 0) + (self:knowTalent(self.T_REK_SHINE_SEALS_INSURMOUNTABLE) and 10 or 0) end,
	no_energy = true,
	tactical = { DEFEND = 1, ATTACKAREA = {LIGHT = 1} },
	getDamage = function(self, t) return reflectAmp(self, self:combatTalentSpellDamage(t, 0, 30)) end,
	getDuration = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 4, 8))) end,
	range = 0,
	radius = function(self, t) return 2 end,
	target = function(self, t) -- for AI only
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, filter=function(x, y) return core.fov.distance(self.x, self.y, x, y) > 1 end}
	end,
	targetInner = function(self, t) return {type="ball", range=0, radius=1, selffire=false} end,
	action = function(self, t)	
		local crit = self:spellCrit(1.0)
		local dam = crit * t.getDamage(self, t)

		-- possible traits from 3rd talent upgrade
		local t3 = self:getTalentFromId(self.T_REK_SHINE_SEALS_INSURMOUNTABLE)
		local damFire = self:knowTalent(self.T_REK_SHINE_SEALS_INSURMOUNTABLE) and (crit * t3.getDamage(self, t3)) or nil
		local vox = self:knowTalent(self.T_REK_SHINE_SEALS_INSURMOUNTABLE) or nil
		
		local tgI = t.targetInner(self, t)
		local gridsCenter = self:project(tgI, self.x, self.y, function() end)
		game.level.map:addEffect(self, self.x, self.y, t.getDuration(self, t), DamageType.REK_SHINE_SEAL, {dam=dam, knock=false, disarm=true, damFire=damFire, silence=vox}, 0, 5, gridsCenter, MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="solar_citadel_inner", radius=self:getTalentRadius(t), base_rot=0, oversize=1.5}}, color_br=200, color_bg=200, color_bb=200, effect_shader="shader_images/blank_effect.png"}, nil, true)


		--MapEffect.new{color_br=200, color_bg=140, color_bb=20, effect_shader="shader_images/water_effect1.png"}, nil, true)


		--MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="sun_circle", radius=self:getTalentRadius(t)}}, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/sunlight_effect.png"},
			
		
		--MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, oversize=0, img="sun_sigil_dark", radius=1}}, color_br=255, color_bg=187, color_bb=187, alpha=10, effect_shader="shader_images/sunlight_effect.png"}
		
		local tg = self:getTalentTarget(t)
		local gridsRim = self:project(tg, self.x, self.y, function() end)
		game.level.map:addEffect(self, self.x, self.y, t.getDuration(self, t), DamageType.REK_SHINE_SEAL, {dam=dam, knock=true, disarm=false, damFire=damFire, silence=vox}, 0, 5, gridsRim, MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="solar_citadel_outer", radius=self:getTalentRadius(t), base_rot=0, oversize=1.5}}, color_br=200, color_bg=200, color_bb=200, effect_shader="shader_images/blank_effect.png"}, nil, true)

		if self:knowTalent(self.T_REK_SHINE_SEALS_ARMAMENTS) then
			game.level.map:addEffect(self, self.x, self.y, t.getDuration(self, t), DamageType.COSMETIC, 0, 0, 5, {}, MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="solar_citadel_empyreal", radius=self:getTalentRadius(t), base_rot=0, oversize=1.5}}, color_br=200, color_bg=200, color_bb=200, effect_shader="shader_images/blank_effect.png"}, nil, true)
		end
		
		if self:knowTalent(self.T_REK_SHINE_SEALS_INSURMOUNTABLE) then
			game.level.map:addEffect(self, self.x, self.y, t.getDuration(self, t), DamageType.COSMETIC, 0, 0, 5, {}, MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="solar_citadel_light", radius=self:getTalentRadius(t), base_rot=0, oversize=1.5}}, color_br=200, color_bg=200, color_bb=200, effect_shader="shader_images/blank_effect.png"}, nil, true)
		end
		
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Creates a circular seal of radius %d at your feet that lasts for %d turns. The seal deals %0.1f light damage per turn to any enemies within. 
Enemies in the outer ring are knocked back (#SLATE#Spellpower vs. Mental#LAST#) 2 spaces.
Enemies in the inner ring are disarmed (#SLATE#Spellpower vs. Physical#LAST#) for 3 turns.
The damage will increase with your Spellpower.]]):tformat(self:getTalentRadius(t), t.getDuration(self, t), (damDesc (self, DamageType.LIGHT, t.getDamage(self, t))))
	end,
}

newTalent{
	name = "Empyreal Armaments", short_name = "REK_SHINE_SEALS_ARMAMENTS",
	type = {"celestial/seals", 2}, require = mag_req_high2, points = 5,
	mode = "passive",
	getDuration = function(self, t) return 3 end,
	getCooldown = function(self, t) return 3 end,
	getDamage = function(self, t) return reflectAmp(self, self:combatTalentSpellDamage(t, 0, 45)) end,
	-- implemented in hook just below
	info = function(self, t)
		return ([[Enhance your solar citadel with the darkness of the void. Whenever anyone inside your solar citadel damages someone outside of it, they also deal do %0.1f darkness damage with a 25%% chance to blind for %d turns (#SLATE#Spellpower vs. Physical#LAST#).  This has a %d turn cooldown per attacker.
The damage will increase with your spellpower.

#{italic}#After the light comes darkness, deep and hungry.#{normal}#

#YELLOW#Learning this talent is optional and increases the cost of Solar Citadel by 10 Positive Energy#LAST#]]):tformat(damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getDuration(self, t), t.getCooldown(self, t))
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	local seff = game.level.map:hasEffectType(src.x, src.y, DamageType.REK_SHINE_SEAL)
	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_SHINE_SEAL)

	-- firing from an empowered citadel to a target outside the citadel
	if seff and seff.src and seff.src.knowTalent and seff ~= deff and (src.hasProc and not src:hasProc("shining_empyreal_darkness")) then
		if seff.src:knowTalent(seff.src.T_REK_SHINE_SEALS_ARMAMENTS) then
			local t = seff.src:getTalentFromId(seff.src.T_REK_SHINE_SEALS_ARMAMENTS)
			src:setProc("shining_empyreal_darkness", true, 3)
			local damBolt = t.getDamage(seff.src, t)
			src:project(target, target.x, target.y, DamageType.DARKNESS_BLIND, damBolt)
			game.level.map:particleEmitter(target.x, target.y, 1, "quick_fade_image", {img="empyreal_arms"})
		end
	end
	return hd
end)

newTalent{
	name = "Insurmountable Light", short_name = "REK_SHINE_SEALS_INSURMOUNTABLE",
	type = {"celestial/seals", 2}, require = mag_req_high3, points = 5,
	mode = "passive",
	getDamage = function(self, t) return reflectAmp(self, self:combatTalentSpellDamage(t, 0, 30)) end,
	info = function(self, t)
		return ([[Enhance your solar citadel with unquenchable flames. You gain 100%% silence immunity while standing in it, while enemies take an additional %0.1f fire damage each turn.
The damage will increase with your spellpower.

#{italic}#Together, our light will be visible in all places, forevermore.#{normal}#

#YELLOW#Learning this talent is optional and increases the cost of Solar Citadel by 10 Positive Energy#LAST#]]):tformat((damDesc (self, DamageType.FIRE, t.getDamage(self, t))))
	end,
}

newTalent{
	name = "Walking Citadel", short_name = "REK_SHINE_SEALS_WALKING_CITADEL",
	type = {"celestial/seals", 2}, require = mag_req_high4, points = 5,
	cooldown = 20,
	insanity = -10,
	getDamage = function(self, t) return reflectAmp(self, self:combatTalentSpellDamage(t, 0, 75)) end,
	getNumb = function(self, t) return 40 end,
	getNumbDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 7, 2, 5)) end,
	on_pre_use = function(self, t, silent)
		if not game.level then return end
		for i, e in ipairs(game.level.map.effects) do
			if e.src and e.src == self and e.damtype == DamageType.REK_SHINE_SEAL then return true end
		end
		return false
	end,
	action = function(self, t)
		local dam = self:spellCrit(t.getDamage(self, t))
		local old_effects = {}
		for i, e in pairs(game.level.map.effects) do
			game.logPlayer(self, ("DEBUG effect at (%d, %d)"):format(e.x, e.y))
			if e.x and e.y and e.src == self and e.damtype == DamageType.REK_SHINE_SEAL then
				if e.dam and e.dam.disarm then
					local tg = {type="ball", radius=e.radius, talent=t, friendlyfire=false}
					e.src:project(tg, e.x, e.y, DamageType.REK_SHINE_SEAL_WALK, {dam=dam, numb=t.getNumb(self, t)})
				end
				old_effects[#old_effects+1] = e
			end
		end
		for i, e in pairs(old_effects) do
			game.level.map:removeEffect(e)
		end
		self:forceUseTalent(self.T_REK_SHINE_SEALS_SOLAR_CITADEL, {ignore_energy=true, ignore_cd=true, ignore_ressources=true})
		local tg = {type="ball", radius=2, talent=t, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.REK_SHINE_SEAL_WALK, {dam=dam, numb=t.getNumb(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Conjure a surge of celestial power and recreate an existing solar citadel at your current location, with refreshed duration. Any foe standing within the old or new location will suffer %0.1f light and %0.1f fire damage and be numbed for %d turns, dealing %d%% less damage.]]):tformat(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getNumbDuration(self, t), t.getNumb(self, t))
	end,
}