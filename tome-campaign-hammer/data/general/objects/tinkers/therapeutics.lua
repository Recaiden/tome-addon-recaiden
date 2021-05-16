-- ToME - Tales of Maj'Eyal:
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local base_newEntity = newEntity
function newEntity(t) t.tinker_category = "therapeutics" return base_newEntity(t) end

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

local medical = {"simple", "potent", "powerful", "great", "amazing"}

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_HEALING_SALVE"..i,
	name = medical[i].." healing salve", image = "talents/healing_salve.png",
	color = colors.LIGHT_GREEN,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 110, 50)
	end,
	resolvers.medical_salves("heal %d", 15, function(self, who)
		self:attr("allow_on_heal", 1)
		who:heal(self:getCharmPower(who), who)
		self:attr("allow_on_heal", -1)
		
		if core.shader.active(4) then
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		return {id=true, used=true}
	end),
}
end

-- for i = 1, 5 do
-- newEntity{ base = "BASE_SALVE", define_as = "TINKER_METALPELT_SALVE"..i,
-- 	name = medical[i].." metalpelt salve", image = "talents/metalpelt.png",
-- 	color = colors.LIGHT_GREEN,
-- 	material_level = i,
-- 	steamtech_power_def = function(self, who)
-- 		return who:combatScaleTherapeutic(self, 50, 75)
-- 	end,
-- 	resolvers.medical_salves("heal %d", 15, function(self, who)
-- 		self:attr("allow_on_heal", 1)
-- 		who:heal(who:steamCrit(self:getCharmPower(who)), who)
-- 		self:attr("allow_on_heal", -1)
		
-- 		if core.shader.active(4) then
-- 			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
-- 			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
-- 		end
-- 		return {id=true, used=true}
-- 	end),
-- }
-- end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_PAIN_SUPPRESSOR_SALVE"..i,
	name = medical[i].." pain suppressor salve", image = "talents/pain_suppressor_salve.png",
	color = colors.GREEN,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 90, 45)
	end,
	resists_all_power = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 4)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self, who) return ("let you fight up to -%%d life and reduces all damage by %d%%%% for %d turns (takes no time to activate)"):format(self:resists_all_power(who), 2 + math.ceil(self.material_level / 2)) end, 19, function(self, who)
		who:setEffect(who.EFF_PAIN_SUPPRESSOR_SALVE, 2 + math.ceil(self.material_level / 2), {die_at=self:getCharmPower(who), resists=self:resists_all_power(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_FROST_SALVE"..i,
	name = medical[i].." frost salve", image = "talents/frost_salve.png",
	color = colors.BLUE,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 4)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return "remove "..nb.." physical effects and grants a frost aura (%d%% cold, darkness and nature affinity)" end, 25, function(self, who)
		who:removeEffectsFilter({type="physical", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter({status="detrimental", type="physical"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_FROST_SALVE, 2 + self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_FIERY_SALVE"..i,
	name = medical[i].." fiery salve", image = "talents/fiery_salve.png",
	color = colors.RED,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 4)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return "remove "..nb.." magical effects and grants a fiery aura (%d%% fire, light and lightning affinity)" end, 25, function(self, who)
		who:removeEffectsFilter({type="magical", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter({status="detrimental", type="magical"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_FIERY_SALVE, 2 + self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_WATER_SALVE"..i,
	name = medical[i].." water salve", image = "talents/water_salve.png",
	color = colors.LIGHT_BLUE,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 4)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return "remove "..nb.." mental effects and grants a water aura (%d%% blight, mind and acid affinity)." end, 25, function(self, who)
		who:removeEffectsFilter({type="mental", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter({status="detrimental", type="mental"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_WATER_SALVE, 2 + self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_UNSTOPPABLE_FORCE_SALVE"..i,
	name = medical[i].." unstoppable force salve", image = "talents/unstoppable_force_salve.png",
	color = colors.GOLD,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 30, 22)
	end,
	use_no_energy = true,
	resolvers.medical_salves("increases all saves by %d and healing factor by half", 18, function(self, who)
		who:setEffect(who.EFF_UNSTOPPABLE_FORCE_SALVE, 4 + self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

newEntity{ base = "BASE_TINKER", define_as = "TINKER_LIFE_SUPPORT5",--Therapeutics Capstone
	slot = "BODY",
	type = "armor", subtype="light",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	moddable_tile = "upper_body_19",
	moddable_tile2 = "lower_body_06",
	encumber = 9,
	power_source = {steam=true}, is_tinker = false,
	unique = true,
	name = "Life Support Suit", image = "object/artifact/life_support_suit.png",
	unided_name = "advanced medical armour",
	desc = [["We've done it, men. We cured death."]],
	rarity = false,
	cost = 1000,
	require = { stat = { str=22 }, },
	material_level = 5,
	special_desc = function(self) 
		local maxp = self:min_power_to_trigger()
		return ("You cannot bleed.\nWhen you take damage, if your life is under 20%%, heal for 30%% of your max life. %s"):format(self.power < maxp and ("(%d turns until ready)"):format(maxp - self.power) or "(15 turn cooldown)")
	end,
	wielder = {
		combat_def = 12,
		combat_armor = 10,
		die_at = -200,
		fatigue = 9,
		heal_factor = 0.3,
		combat_physresist = 25,
		ignore_bleed=1,
		resists = { all=5 },
		inscriptions_data = { LIFE_SUPPORT = {
			power = 90,
			cooldown_mod = 110,
			cooldown = 1,
		}},
		learn_talent = { [Talents.T_LIFE_SUPPORT] = 1, },
	},
	max_power = 20, power_regen = 1,
	min_power_to_trigger = function(self) return self.max_power * (self.worn_by and (100 - (self.worn_by:attr("use_object_cooldown_reduce") or 0))/100 or 1) end, -- special handling of the Charm Mastery attribute
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if self.power < self:min_power_to_trigger() then return end
		if (who.life - dam)/who.max_life >=0.2 then return end
		who:attr("allow_on_heal", 1)
		who:heal(who.max_life*0.2)
		who:attr("allow_on_heal", -1)
			if core.shader.active(4) then
				who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
				who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
			end
		self.power = 0
	end,
}

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_SECOND_SKIN"..i,
	name = medical[i].." second skin", image = "object/tinkers_second_skin_t5.png",
	on_slot = "BODY",
	material_level = i,
	object_tinker = {
		wielder = {
			life_regen = i*2,
			cut_immune = 0.2 + 0.1*i,
			poison_immune = 0.2 + 0.1*i,
			disease_immune = 0.2+0.1*i,
		},
	},
}
end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_AIR_RECYCLER"..i,
	name = medical[i].." air recycler", image = "object/tinkers_air_recycler_t5.png",
	on_slot = "HEAD",
	material_level = i,
	special_desc = function(self) return ("Returns %d air each turn."):format(self.object_tinker.wielder.air_regen) end,
	object_tinker = {
		wielder = {
			air_regen = i,
			silence_immune = 0.1*i,
		},
	},
}
end

-- for i = 1, 5 do
-- newEntity{ base = "BASE_TINKER", define_as = "TINKER_SMELLING_SALTS"..i,
-- 	name = medical[i].." smelling salts", image = "object/tinkers_hand_cannon_t5.png",
-- 	on_slot = "BELT",
-- 	special_desc = function(self) return ("Recover from stun subtype effects %d%% faster."):format(self.object_tinker.wielder.stun_recovery*100) end,
-- 	material_level = i,
-- 	object_tinker = {
-- 		wielder = {
-- 			stun_recovery = 0.3*i,
-- 		},
-- 	},
-- 	on_tinker = function(self, o, who)
-- 		if o.callbackOnActBase then return true end
-- 		o.callbackOnActBase = function(self, who)
-- 			local effs = {}
-- 			-- Go through all effects
-- 			for eff_id, p in pairs(who.tmp) do
-- 				local e = who.tempeffect_def[eff_id]
-- 				if e.subtype.stun and e.type ~= "other" then -- Daze is stun subtype
-- 					p.dur = p.dur - who.stun_recovery
-- 					if p.dur <= 0 then who:removeEffect(eff_id) end
-- 				end
-- 			end
-- 		end
-- 	end,
-- 	on_untinker = function(self, o, who)
-- 		if not o.callbackOnActBase then return true end
-- 		o.callbackOnActBase = nil
-- 	end,
-- }
-- end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_MOSS_TREAD"..i,
	name = medical[i].." moss tread", image = "object/tinkers_moss_tread_t5.png",
	on_slot = "FEET",
	material_level = i,
	object_tinker = {
		wielder = {
			inc_stealth = 2*i,
			learn_talent = {[Talents.T_TINKER_MOSS_TREAD] = i},
		},
	},
}
end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_FUNGAL_WEB"..i,
	name = medical[i].." fungal web", image = "object/tinkers_fungal_web_t5.png",
	on_slot = "BELT",
	special_desc = function(self) return ("Heals you for %d life when you use a salve."):format(self.object_tinker.wielder.heal_on_salve) end,
	material_level = i,
	object_tinker = {
		wielder = {
			heal_on_salve = 25*i,
		},
	},
	on_tinker = function(self, o, who)
		if o.callbackOnMedicalSalve then return true end
		o.callbackOnMedicalSalve = function(self, who, o, on_cd)
			who:heal(who.heal_on_salve, who)
		end
	end,
	on_untinker = function(self, o, who)
		if not o.callbackOnMedicalSalve then return true end
		o.callbackOnMedicalSalve = nil
	end,
}
end
