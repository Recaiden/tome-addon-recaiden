
newTalent{
	name = "Incarnate Storm", short_name = "REK_EVOLUTION_GLR_STORM",
	type = {"uber/dexterity", 1},
	uber = true,
	require = {
		stat = {wil = 35},
		level = 25,
		birth_descriptors={{"subclass", "Wisp"}},
		special={
			desc="10 points in Arrowstorm talents",
			fct=function(self)
				return self:getTalentLevelRaw(self.T_REK_GLR_ARROWSTORM_KALMANKA) + self:getTalentLevelRaw(self.T_REK_GLR_ARROWSTORM_VITARIS) + self:getTalentLevelRaw(self.T_REK_GLR_ARROWSTORM_PELLEGRINA) + self:getTalentLevelRaw(self.T_REK_GLR_ARROWSTORM_KAMILLA) >= 10
			end
		}
	},
	is_class_evolution = "Wisp",
	cant_steal = true,
	mode = "passive",
	is_mind = true,
	no_npc_use = true,	
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam)
		if not hitted then return end
		if not target then return end
		if core.fov.distance(self.x, self.y, target.x, target.y) < 4 then return end
		if target:hasProc("rek_glr_storm_dash") then return end
		-- zip to target 
		if not self:teleportRandom(target.x, target.y, 0) then game.logSeen(self, "The storm can't reach the target!") return end
		-- trigger arrowtorm
		self:callTalent(self.T_REK_GLR_ARROWSTORM_KALMANKA, "doStorm", self, true)
		target:setProc("rek_glr_storm_dash", 1)
	end,
	info = function(self, t)
		return ([[#{italic}#It is dishonorable to fight at a distance.#{normal}#

All damage you deal scales with distance to the target, from 150%% while adjacent to 0%% at range 4+.  When you hit an enemy at range 4+ with an archery attack, you immediately teleport to them and trigger your Arrowstorm (once per enemy per turn)]]):format()
	end,
}



-- newTalent{
-- 	name = "Light as the Wind", short_name = "REK_EVOLUTION_GLR_PANOPLY",
-- 	type = {"uber/dexterity", 1},
-- 	uber = true,
-- 	require = {
-- 		stat = {cun = 35},
-- 		level = 25,
-- 		birth_descriptors={{"subclass", "Wisp"}},
-- 		special={
-- 			desc="No fatigue",
-- 			fct=function(self)
-- 				return self:combatFatigue() == 0
-- 			end
-- 		}
-- 	},
-- 	is_class_evolution = "Wisp",
-- 	cant_steal = true,
-- 	mode = "passive",
-- 	is_mind = true,
-- 	no_npc_use = true,	
-- 	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam)
-- 		if not hitted then return end
-- 		if not target then return end
-- 		if core.fov.distance(self.x, self.y, target.x, target.y) < 4 then return end
-- 		if target:hasProc("rek_glr_storm_dash") then return end
-- 		-- zip to target 
-- 		if not self:teleportRandom(target.x, target.y, 0) then game.logSeen(self, "The storm can't reach the target!") return true end
-- 		-- trigger arrowtorm
-- 		self:callTalent(eff.src.T_REK_GLR_ARROWSTORM_KALMANKA, "doStorm", self, true)
-- 		target:setProc("rek_glr_storm_dash", 1)
-- 	end,
-- 	info = function(self, t)
-- 		return ([[#{italic}#Possessions come to possess their owner.#{normal}#
-- For each equipment slot you have empty, you gain powerful bonuses, which increase with your level.
-- No helmet ... confuse resist
-- No boots ... movespeed, stun resist
-- No gloves ...
-- No body armor (bikini counts but take away its resists) ... stronger silk armor rating, psi-regen
-- No lite ... telepathy all at increasing range, resists, healing factor
-- No belt ... crit power
-- No amulet ...
-- No rings ...
-- ]]):format()
-- 	end,
-- }