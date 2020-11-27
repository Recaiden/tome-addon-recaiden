newTalent{
	name = "Shadow of Flame", short_name = "REK_HOLLOW_SHADOW_FLAME",
	type = {"undead/shadow-destruction", 1},
	require = undeads_req1,
	points = 5,
	hate = 2,
	cooldown = 3,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 10,
	proj_speed = 20,
	requires_target = true,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		return tg
	end,
	allow_for_arcane_combat = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 290) end,
	passives = function(self, t, tmptable)
		self:talentTemporaryValue(tmptable, "auto_highest_inc_damage", {[DamageType.FIRE] = 1})
		self:talentTemporaryValue(tmptable, "auto_highest_resists_pen", {[DamageType.FIRE] = 1})
		self:talentTemporaryValue(tmptable, "inc_damage", {[DamageType.FIRE] = 0.00001})
		self:talentTemporaryValue(tmptable, "resists_pen", {[DamageType.FIRE] = 0.00001})
	end,	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = nil
		self:project({type="beam", friendlyfire=false, selffire=false, talent=t, self.x, self.y}, x, y, DamageType.FIREBURN, self:mindCrit(t.getDamage(self, t)))

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "light_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
      return ([[Conjures up a beam of shadow flames, setting the targets ablaze and doing %0.2f fire damage over 3 turns.
Your fire damage will use your highest damage bonus and resistance penetration among all elements.
Mindpower: increases damage
]]):
      format(damDesc(self, DamageType.FIRE, damage))
   end,
         }

newTalent{
   name = "Shadow of Storm", short_name = "REK_HOLLOW_SHADOW_LIGHTNING",
   type = {"undead/shadow-destruction",2},
   require = undeads_req2,
   points = 5,
   hate = 3,
   cooldown = 3,
   tactical = { ATTACK = { LIGHTNING = 2 } },
   range = 1,
   direct_hit = true,
   requires_target = true,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 350) end,
	 passives = function(self, t, tmptable)
		self:talentTemporaryValue(tmptable, "auto_highest_inc_damage", {[DamageType.LIGHTNING] = 1})
		self:talentTemporaryValue(tmptable, "auto_highest_resists_pen", {[DamageType.LIGHTNING] = 1})
		self:talentTemporaryValue(tmptable, "inc_damage", {[DamageType.LIGHTNING] = 0.00001})
		self:talentTemporaryValue(tmptable, "resists_pen", {[DamageType.LIGHTNING] = 0.00001})
	end,	
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:mindCrit(t.getDamage(self, t))
      self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
      local _ _, x, y = self:canProject(tg, x, y)
      game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/lightning")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Strikes the target with a pulse of shadow lightning doing %0.2f to %0.2f damage (%0.2f average).
Your lightning damage will use your highest damage bonus and resistance penetration among all elements.
Mindpower: increases damage]]):
      format(damDesc(self, DamageType.LIGHTNING, damage / 3),
             damDesc(self, DamageType.LIGHTNING, damage),
             damDesc(self, DamageType.LIGHTNING, (damage + damage / 3) / 2))
   end,
         }

newTalent{
	name = "Shadow of Violence", short_name = "REK_HOLLOW_SHADOW_DOMINATE",
	type = {"undead/shadow-destruction",3},
	require = undeads_req3,
	points = 5,
	cooldown = function(self, t) return 8 end,
	hate = 4,
	tactical = {
		ATTACK = function(self, t, aitarget)
			return self.fov.actors[aitarget] and self.fov.actors[aitarget].sqdist <= 1 and 2 or nil
		end,
		DISABLE = {pin = 2}},
	requires_target = true,
	range = 2.5,
	getDuration = function(self, t)
		return math.min(6, math.floor(2 + self:getTalentLevel(t)))
	end,
	getArmorChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 4, 30)
	end,
	getDefenseChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 6, 45)
	end,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		
		-- attempt domination
		local duration = t.getDuration(self, t)
		local armorChange = t.getArmorChange(self, t)
		local defenseChange = t.getDefenseChange(self, t)
		target:setEffect(target.EFF_HOLLOW_DOMINATED, duration, {src = self, armorChange = armorChange, defenseChange = defenseChange, apply_power=self:combatMindpower()})
		
		-- attack if adjacent
		if core.fov.distance(self.x, self.y, x, y) <= 1 then
			local shield, shield_combat = self:hasShield()
			local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
			local hit = false
			if not shield then
				hit = self:attackTarget(target, nil, 1, true)
			else
				hit = self:attackTargetWith(target, weapon, nil, 1)
				if self:attackTargetWith(target, shield_combat, nil, 1) or hit then hit = true end
			end
		end
		
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local armorChange = t.getArmorChange(self, t)
		local defenseChange = t.getDefenseChange(self, t)
		return ([[Turn your attention to a nearby foe, and dominate (#SLATE#Mindpower vs Mental#LAST#) them with your shadowy presence. A dominated creature will be unable to move for %d turns and vulnerable to attacks. They will lose %d Armour, %d Defense and Mental Save, and 10%% resistance to all damage. If the target is adjacent to you, your domination will include a melee attack.
		Effects will improve with your Willpower.
                
		This talent will also attack with your shield, if you have one equipped.]]):format(duration, -armorChange, -defenseChange)
   end,
}

newTalent{
   name = "Shadow of Speed", short_name = "REK_HOLLOW_SHADOW_BLINDSIDE",
   type = {"undead/shadow-destruction",4},
   require = undeads_req4,
   points = 5,
   cooldown = function(self, t) return math.max(6, 13 - math.floor(self:getTalentLevel(t))) end,
   range = 10,
   requires_target = true,
   tactical = { CLOSEIN = 2 },
   is_melee = true,
   is_teleport = true,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   getDefenseChange = function(self, t) return self:combatTalentStatDamage(t, "dex", 20, 50) end,
	 getBonusDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 320) * getHateMultiplier(self, 0.3, 1.5, false)end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end

      game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
      if not self:teleportRandom(x, y, 0) then game.logSeen(self, "The teleport fizzles!") return true end
      game:playSoundNear(self, "talents/teleport")
      game.level.map:particleEmitter(x, y, 1, "teleport_in")
      
      -- Attack ?
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
         local multiplier = t.getDamage(self, t)         
         local hit = self:attackTarget(target, nil, multiplier, true)
				 if hit then
					 self:project(tg, x, y, DamageType.DARKNESS, self:mindCrit(t.getBonusDamage(self, t)))
				 end
         self:setEffect(target.EFF_HOLLOW_BLINDSIDE_BONUS, 1, { power=t.getDefenseChange(self, t) })
      end
      return true
   end,info = function(self, t)
      local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
      return ([[With blinding speed you suddenly appear next to a target up to %d spaces away and attack, dealing up to %d bonus darkness damage (based on hate).
Your sudden appearance catches everyone off-guard, giving you %d damage reduction for 1 turn.

Dexterity: improves damage reduction]]):format(self:getTalentRange(t), multiplier * 100, t.getDefenseChange(self, t))
   end,
}