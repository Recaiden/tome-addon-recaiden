local ActorTalents = require "engine.interface.ActorTalents"

-- Not the best way to do this, might clean up later
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

-- Generic requires for talents based on talent level
cursed_wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cursed_wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cursed_wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cursed_wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cursed_wil_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

cursed_wil_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cursed_wil_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cursed_wil_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cursed_wil_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cursed_wil_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
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

if not Talents.talents_types_def["cursed/solar-shadows"] then
   newTalentType{ allow_random=true, type="cursed/solar-shadows", name = _t"Shadows", description = _t"Summon shadows from the darkness to aid you." }
   load("/data-classfallen/talents/cursed/solar-shadows.lua")
end

if not Talents.talents_types_def["cursed/suffering-shadows"] then
   newTalentType{ allow_random=true, type="cursed/suffering-shadows", name = _t"Shadows of Suffering", description = _t"Remorse, Pain, Guilt, Obsession, Despair" }
   load("/data-classfallen/talents/cursed/suffering-shadows.lua")
end