newTalent{
	name = "Unnerve", short_name = "REK_MTYR_UNSETTLING_UNNERVE",
	extra_image_sane = "talents/rek_mtyr_unsettling_unnerve.png",
	extra_image_semisane = "talents/rek_mtyr_unsettling_unnerve_insane.png",
	extra_image_insane = "talents/rek_mtyr_unsettling_unnerve_insane.png",
	type = {"demented/unsettling", 1},
	require = martyr_req1,
	points = 5,
	insanity = 10,   
	cooldown = 4,
	range = function(self, t)
		local weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeapon()
		if not (weapon and weapon.combat) and not (pf_weapon and pf_weapon.combat) then 
			if self:hasArcheryWeaponQS() then
				weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeaponQS()
			else
				return 3
			end
		end
		local br = (self.archery_bonus_range or 0)
		return math.max(weapon and br + weapon.combat.range or 6,
										offweapon and offweapon.combat and br + offweapon.combat.range or 0,
										pf_weapon and pf_weapon.combat and br + pf_weapon.combat.range or 0,
										self:attr("archery_range_override") or 0)
	end,
	radius = function(self, t)
		if amSane(self) and self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNINHIBITED) then
			local t4 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNINHIBITED)
			return t4.getRadius(self, t4)
		end
		return 0
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, friendlyfire=false, selffire=false}
	end,
	--target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	requires_target = true,
	tactical = { DISABLE = { confusion = 2 } },
	getPower = function(self, t) return math.min(50, self:combatTalentScale(t, 20, 50, 0.75)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5.5)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.1) end,
	on_learn = function(self, t)
		self:attr("show_gloves_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("show_gloves_combat", -1)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if self:getTalentRadius(t) == 0 and not target then return nil end
		
		local power = t.getPower(self, t)
		local dam = 0
		local powerlessness = 0
		local pitilessness = 0
		--DoT
		if self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNHINGE) then
			local t2 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNHINGE)
			dam = self:mindCrit(t2.getDamage(self, t2))
			if amSane(self) then
				powerlessness = t2.getPowerDrain(self, t2)
			end
		end
		
		if self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNVEIL) then
			local t3 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNVEIL)
			pitilessness = t3.getPitiless(self, t3)
		end
		
		self:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				if target == self then return end
				
				if target:canBe("confusion") then   
					-- Main effct
					target:setEffect(target.EFF_REK_MTYR_UNNERVE, t.getDuration(self,t), {power=t.getPower(self, t) or 30, damage=dam, powerlessness=powerlessness, pitilessness=pitilessness, src=self, apply_power=self:combatMindpower()})
				elseif self:knowTalent(self.T_REK_MTYR_UNSETTLING_UNINHIBITED) then
					-- same effect but weaker when bypassing immunity
					local t4 = self:getTalentFromId(self.T_REK_MTYR_UNSETTLING_UNINHIBITED)
					local diminishment = t4.getReduction(self, t4)
					target:setEffect(target.EFF_REK_MTYR_UNNERVE, t.getDuration(self,t), {power=power * (100 - diminishment) / 100, damage=dam * (100 - diminishment) / 100, powerlessness= powerlessness * (100 - diminishment) / 100, pitilessness=pitilessness * (100 - diminishment) / 100, src=self, apply_power=self:combatMindpower()})
				else
					game.logSeen(target, "%s resists the revelation!", target.name:capitalize())
				end
				
				-- sanityBonus
				if amSane(self) then
					if target and target:hasEffect(target.EFF_REK_MTYR_UNNERVE) then
						self:attackTarget(target, nil, t.getDamage(self, t), true, true)
					end
				end
			end)
		
		return true
	end,
	
	info = function(self, t)
		return ([[Inform an enemy about the true bleak vistas of reality, confusing (#SLATE#Mindpower vs. Mental#LAST#) them for %d turns (%d confusion power).  The range of this talent will increase with the firing range of a ranged weapon in your main set or offset (but is always at least 3).

#ORANGE#Sanity Bonus:#LAST# Take advantage of their moment of realization to throw a sucker punch or other sneak attack, dealing %d%% unarmed damage.
]]):tformat(t.getDuration(self, t), t.getPower(self, t), 100*t.getDamage(self, t))
	end,
}

newTalent{
	name = "Unhinge", short_name = "REK_MTYR_UNSETTLING_UNHINGE",
	type = {"demented/unsettling", 2},
	require = martyr_req2,
	points = 5,
	mode = "passive",
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 58) end,
   getPowerDrain = function(self, t) return self:combatTalentMindDamage(t, 5, 36) end,
   info = function(self, t)
      return ([[Your Unnerve effect tears at the victim's mind, dealing %d mind damage per turn.
Mindpower: improves damage

#ORANGE#Sanity Bonus:#LAST# Unnerve also reduces the victim's physical, spell, and mind power by %d.
Mindpower: improves stat reduction]]):tformat(t.getDamage(self, t), t.getPowerDrain(self, t))
   end,
}

newTalent{
   name = "Unveil", short_name = "REK_MTYR_UNSETTLING_UNVEIL",
   type = {"demented/unsettling", 3},
   require = martyr_req3,
   points = 5,
   mode = "passive",
   getPitiless = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end,
   info = function(self, t)
      return ([[The truth weighs heavily on the mind.  Each turn, unnerved targets have a %d%% chance that their cooling down talents will increase in cooldown.

#ORANGE#Sanity Bonus:#LAST# Whenever an Unnerved character acts, you may gain a small amount of insanity (based on how Confused they are).
]]):tformat(t.getPitiless(self, t))
   end,
}

newTalent{
   name = "Uninhibited", short_name = "REK_MTYR_UNSETTLING_UNINHIBITED",
   type = {"demented/unsettling", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getReduction = function(self, t) return math.max(10, self:combatTalentScale(t, 70, 25)) end,
   getRadius = function(self, t) return math.min(10, math.ceil(self:combatTalentScale(t, 0, 3))) end,
   info = function(self, t)
      return ([[Your Unnerve ability can penetrate confusion immunity, with %d%% reduced effectiveness. 

#ORANGE#Sanity Bonus:#LAST# Your Unnerve affects a %d radius ball rather than a single target.]]):tformat(t.getReduction(self, t), t.getRadius(self, t))
   end,
}