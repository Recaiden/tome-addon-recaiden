
newTalent{
	name = "Droneslinger", short_name = "REK_EVOLUTION_DEML_DRONE",
	type = {"uber/cunning", 1},
	uber = true,
	require = {
		stat = {cun = 50},
		level = 25,
		birth_descriptors={{"subclass", "Demolisher"}},
		special={
			desc="Learned all 4 drone talents",
			fct=function(self)
				return self:knowTalent(self.T_REK_DEML_DRONE_GUNNER) and self:knowTalent(self.T_REK_DEML_DRONE_HURRICANE) and self:knowTalent(self.T_REK_DEML_DRONE_GUARD) and self:knowTalent(self.T_REK_DEML_DRONE_SMOKE)
			end
		}
	},
	is_class_evolution = "Demolisher",
	cant_steal = true,
	mode = "sustained",
	no_npc_use = true,

	is_steam = true,
	drain_steam = 9,
	no_energy = true,
	cooldown = 10,
	tactical = { ATTACKAREA = { weapon = 2 }, },
	range = steamgun_range,
	callbackOnActBase = function(self, t)
		if self:getSteam() < 0.1 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end
		local t2 = self:getTalentFromId(self.T_REK_DEML_DRONE_GUNNER)
		t2.activateGunner(self, t2)
		local rev = self:hasEffect(self.EFF_REK_DEML_REVVED_UP)
		if rev and rng.percent(rev.power*100) then t2.activateGunner(self, t2) end
	end,
	activate = function(self, t)
		local ret = {}		

		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "talent_cd_reduction", {
																[self.T_REK_DEML_DRONE_HURRICANE] = 10,
																[self.T_REK_DEML_DRONE_SMOKE] = 10
		})
	end,
	info = function(self, t)
		return ([[#{italic}#Master fighting via autonomous steamtech.#{normal}#

The cooldown of hurricane drone and shroud drone is reduced by 10, and they count as explosive charges when you use Detonator.

You can sustain this talent to turbocharge your gunner drone, causing it to fire twice as often.

While Gunner Drone is sustained you count as wielding a steamgun with range equal to your gunner drone's range. While this talent is also sustained you count as dual-wielding.]]):format()
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
