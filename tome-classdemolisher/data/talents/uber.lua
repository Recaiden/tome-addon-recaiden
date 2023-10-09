
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

While Gunner Drone is sustained you count as wielding a steamgun with range equal to your gunner drone's range. While this talent is also sustained you count as dual-wielding.]]):tformat()
	end,
}



newTalent{
	name = "Death Race", short_name = "REK_EVOLUTION_DEML_RAM",
	type = {"uber/cunning", 1},
	uber = true,
	require = {
		stat = {dex = 35},
		level = 25,
		birth_descriptors={{"subclass", "Demolisher"}},
		special={
			desc="Know both Ramming Speed and Mecharachnid Mine",
			fct=function(self)
				return self:knowTalent(self.T_REK_DEML_EXPLOSIVE_SPIDER_MINE) and self:knowTalent(self.T_REK_DEML_ENGINE_RAMMING_SPEED)
			end
		}
	},
	is_class_evolution = "Demolisher",
	cant_steal = true,
	mode = "passive",
	no_npc_use = true,

	is_steam = true,
	getMovement = function(self, t) return 0.4 end,
	getSteamBonus = function(self, t) return self:combatStatScale("dex", 3, 15) end,
	getFlameBonus = function(self, t) return self:combatStatScale(self:combatDefense(true), 5, 50) end,
	callbackOnKill = function(self, t, victim, death_note)
		self:incSteam(t:_getSteamBonus(self))
	end,
	callbackOnSummonKill = function(self, t, killer, victim, death_note)
		self:incSteam(t:_getSteamBonus(self))
	end,
	passives = function(self, t, p)
	end,
	info = function(self, t)
		return ([[#{italic}#You ride across the land - leaving a trail of devastation, consuming all in your path as fuel.#{normal}#

When you use Ramming Speed, you automatically drop a mecharachnid mine at your starting position, stun the main target (#SLATE#Steampower#LAST#) for 3 turns, and reset the cooldown of Full Throttle.

Your ride grants you an additional +%d%% movement speed, and Blazing Trail deals %d additional damage (based on your Defense).

When you kill an enemy, you throw any combustible bits into the boiler, recovering %d steam (based on your Dexterity).
]]):tformat(t:_getMovement(self)*100, t:_getFlameBonus(self), t:_getSteamBonus(self))
	end,
}

newTalent{
	name = "Getaway Drive", short_name = "REK_EVOLUTION_DEML_SPARE",
	type = {"uber/constitution", 1},
	uber = true,
	require = {
		stat = {con = 35},
		level = 25,
		birth_descriptors={{"subclass", "Demolisher"}},
		special={
			desc="Know Explosive Exit",
			fct=function(self)
				return self:knowTalent(self.T_REK_DEML_PILOT_EXPLOSIVE_EXIT)
			end
		}
	},
	is_class_evolution = "Demolisher",
	cant_steal = true,
	mode = "passive",
	no_npc_use = true,

	is_steam = true,
	cooldown = 50,
	fixed_cooldown = true,
	getEarlyHullMod = function(self, t) return 0.67 end,
	getAutoHullMod = function(self, t) return 0.33 end,
	trigger = function(self, t, auto)
		local value = self:getMaxHull()
		local loss = value
		if auto then value = value * t:_getAutoHullMod(self)
		else value = value * t:_getEarlyHullMod(self) end
		loss = loss - value
		self:incHull(value)
		self:setEffect(self.EFF_REK_DEML_HULL_PENALTY, 10, {src=self, power=loss})
		self:setEffect(self.EFF_REK_DEML_RIDE, 10, {src=self})
		updateSteelRider(self)
		game:playSoundNear(self, "talents/clinking")
		self:startTalentCooldown(t.id)
		return true
	end,
	info = function(self, t)
		return ([[#{italic}#My other car?  Same as my first car.#{normal}#

Your ride carries a second, smaller ride for emergency purposes.
When you activate Explosive Exit, you instantly reactivate a ride with 2/3 normal hull.
This also triggers automatically if you would be knocked off your ride, but less effectively, leaving you only 1/3 normal hull.

This has a cooldown.]]):tformat()
	end,
}
