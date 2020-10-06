local ActorTalents = require "engine.interface.ActorTalents"

archery_range = ActorTalents.main_env.archery_range

-- Not the best way to do this, might clean up later
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

incPsi2 = function(self, cost)
	if not self:attr("zero_resource_cost") and not self:attr("force_talent_ignore_ressources") then 
		self:incPsi(cost)
	end
end

wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
wil_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
wil_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
wil_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
wil_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
wil_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
wil_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}
mastery_dex_req = {
	stat = { dex=function(level) return 10 + (level-1) * 6 end },
	level = function(level) return 0 + (level-1)  end,
}
dex_req1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
dex_req2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
dex_req3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
dex_req4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
dex_req5 = {
	stat = { dex=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
dex_req_high1 = {
	stat = { dex=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
dex_req_high2 = {
	stat = { dex=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
dex_req_high3 = {
	stat = { dex=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
dex_req_high4 = {
	stat = { dex=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

archeryWeaponCheck = function(self, weapon, ammo, silent, weapon_type)
	if not weapon then
		if not silent then
			-- ammo contains error message
			game.logPlayer(self, ({
				["disarmed"] = "You are currently disarmed and cannot use this talent.",
				["no shooter"] = ("You require a %s to use this talent."):format(weapon_type or "missile launcher"),
				["no ammo"] = "You require ammo to use this talent.",
				["bad ammo"] = "Your ammo cannot be used.",
				["incompatible ammo"] = "Your ammo is incompatible with your missile launcher.",
				["incompatible missile launcher"] = ("You require a %s to use this talent."):format(weapon_type or "bow"),
			})[ammo] or "You require a missile launcher and ammo for this talent.")
		end
		return false
	else
		local infinite = ammo and ammo.infinite or self:attr("infinite_ammo")
		if not ammo or (ammo.combat.shots_left <= 0 and not infinite) then
			if not silent then game.logPlayer(self, "You do not have enough ammo left!") end
			return false
		end
	end
	return true
end

archerPreUse = function(self, t, silent, weapon_type)
	local weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeapon(weapon_type)
	weapon = weapon or pf_weapon
	return archeryWeaponCheck(self, weapon, ammo, silent, weapon_type)
end

if not Talents.talents_types_def["psionic/idol"] then
	newTalentType{ allow_random=true, is_mind=true, type="psionic/idol", name = "Idol", description = "You're the best, and deep down everyone knows it." }
	load("/data-classharrower/talents/idol.lua")
end

if not Talents.talents_types_def["psionic/noumena"] then
	newTalentType{ allow_random=true, is_mind=true, type="psionic/noumena", name = "Noumena", description = "Sometimes things happen that don't belong here.  Things that no one can explain." }
	load("/data-classharrower/talents/noumena.lua")
end

if not Talents.talents_types_def["technique/psychic-marksman"] then
	newTalentType{ allow_random=true, is_mind=true, type="technique/psychic-marksman", name = "Psychic Marksman", description = "A true warrior strikes perfectly, killing with only their mind.  But the bow and arrows help." }
	load("/data-classharrower/talents/psychic-marksman.lua")
end

if not Talents.talents_types_def["technique/psychic-shots"] then
	newTalentType{ allow_random=true, is_mind=true, type="technique/psychic-shots", name = "Psychic Shots", description = "Special Psi-aimed archery techniques" }
	load("/data-classharrower/talents/psychic-shots.lua")
end