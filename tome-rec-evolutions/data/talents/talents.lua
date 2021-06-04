local ActorTalents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 12 + (level-1)  end,
}

function getHateMultiplier(self, min, max, cursedWeaponBonus, hate)
	local fraction = (hate or self.hate) / 100
	if cursedWeaponBonus then
		if self:hasDualWeapon() then
			if self:hasCursedWeapon() then fraction = fraction + 0.13 end
			if self:hasCursedOffhandWeapon() then fraction = fraction + 0.07 end
		else
			if self:hasCursedWeapon() then fraction = fraction + 0.2 end
		end
	end
	fraction = math.min(fraction, 1)
	return (min + ((max - min) * fraction))
end

if not Talents.talents_types_def["undead/shadow-destruction"] then
	newTalentType{ type="undead/shadow-destruction", name = "Shadow Destruction", is_mind=true, is_spell=true, description = "The power to destroy the world with fire and storm is yours again!"}
	newTalentType{ type="undead/shadow-magic", name = "Shadow Magic", is_mind=true, is_spell=true, description = "Contort space and safety, life and death."}
	load("/data-rec-evolutions/talents/destruction.lua")
	load("/data-rec-evolutions/talents/magic.lua")
	load("/data-rec-evolutions/talents/hollow.lua")
end

if Talents.talents_types_def["demented/slow-death"] then
	load("/data-rec-evolutions/talents/gourmand.lua")
end

spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

if not Talents.talents_types_def["spell/lightning-archery"] then
	newTalentType{ type="spell/lightning-archery", name = "Lightning Archery", is_spell=true, no_silence=true, generic=true, description = "Shock and Awe!"}
	load("/data-rec-evolutions/talents/zephyr-storm-archery.lua")
	load("/data-rec-evolutions/talents/zephyr.lua")
end
