knowRessource = Talents.main_env.knowRessource
makeParadoxClone = Talents.main_env.makeParadoxClone
doWardenWeaponSwap = Talents.main_env.doWardenWeaponSwap
wardenPreUse = Talents.main_env.wardenPreUse
doWardenPreUse = Talents.main_env.doWardenPreUse
archerPreUse = Talents.main_env.archerPreUse
archeryWeaponCheck = Talents.main_env.archeryWeaponCheck
archery_range = Talents.main_env.archery_range

newTalent{
	name = "Wretched Titan", short_name = "REK_EMERALD_EVOLUTION",
	type = {"uber/constitution", 1},
	uber = true,
	require = {
		stat = {con = 50},
		level = 25,
		birth_descriptors={{"race", "Demon"},{"subrace", "Emerald"}},
	},
	is_race_evolution = function(self, t)
		if self:knowTalent(t.id) then return true end
		if not self.descriptor.race == "Demon" then return false end
		if not self.descriptor.subrace == "Emerald" then return false end
		return true
	end,
	cant_steal = true,
	mode = "passive",
	no_npc_use = true,
	range = 3,
	target = function(self, t)
		return {type="ball", range=0, radius=self:getTalentRange(t)}
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "size_category", 1)
		self:talentTemporaryValue(p, "can_dual_2hand", 1)
	end,
	getDamage = function(self, t) return self:combatStatScale("con", 4, 50) * (1 + (self.level - 25) / 25) end,
	getDuration = function(self, t) return math.floor(1+self.level/10) end,
	callbackOnMeleeAttack = function(self, t, target, hit, crit, weapon, damtype, mult, dam)
		if not hit then return end
		if not crit then return end
		
		local count = self:hasProc("rek_emerald_titan") or {val=0}
		if count.val >= 2 then return end
		self:setProc("rek_emerald_titan", count.val+1)
		
		local tg = self:getTalentTarget(t)
		local x, y = target.x, target.y
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.ACID, t.getDamage(self, t),
			self:getTalentRange(t),
			5, nil,
			{type="vapour"},
			nil, false
		)
		game:playSoundNear(self, "talents/cloud")
	end,
	info = function(self, t)
		return ([[#{italic}#Grow into your full size and strength, becoming the living engine of destruction that all good little wretchlings hope to be.#{normal}#

You gain 1 size category, and can now wield a two-handed weapon in each hand.  

Up to twice per turn, when you critically strike with a melee weapon, you unleash a cloud of corrosive vapour that lasts %d turns, dealing %0.1f acid damage in radius %d.
The damage and duration of the vapor will improve with your constituation and character level.]]):tformat(t.getDuration(self, t), damDesc(self, DamageType.ACID, t.getDamage(self, t)), self:getTalentRange(t))
	end,
}
