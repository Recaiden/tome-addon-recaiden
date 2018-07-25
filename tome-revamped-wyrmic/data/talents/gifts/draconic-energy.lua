newTalent{
   name = "Elemental Spray", short_name = "REK_WYRMIC_ELEMENT_SPRAY",
   image = "talents/elemental_bolt.png",
   type = {"wild-gift/draconic-energy", 1},
   require = gifts_req1,
   points = 5,
   random_ego = "attack",
   message = "@Source@ spits energy!",
   equilibrium = 3,
   cooldown = 3,
   tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1, NATURE = 1 } },
   range = function(self, t) return math.floor(self:combatTalentScale(t, 5.5, 7.5)) end,
   getPassivePower = function(self, t) return self:getTalentLevel(t)*4 end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "combat_mindpower", t.getPassivePower(self, t))
   end,
   direct_hit = function(self, t) if self:getTalentLevel(t) >= 5 then return true else return false end end,
      requires_target = true,
      target = function(self, t)
	 local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
	 if self:getTalentLevel(t) >= 5 then tg.type = "beam" end
	 return tg
      end,
      getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 250) end,
      action = function(self, t)
	 local damtype = DamageType.PHYSICAL
	 local damtypeStatus = DamageType.SAND
	 local source = self.rek_wyrmic_dragon_damage
	 if source then
	    damtype = source.damtype
	    damtypeStatus = source.status
	 end
	 
	 local tg = self:getTalentTarget(t)
	 local x, y = self:getTarget(tg)
	 if not x or not y then return nil end
	 if rng.percent(25) then
	    self:project(tg, x, y, damtypeStatus,
			 {dam=self:mindCrit(t.getDamage(self, t)),
			  dur=3,
			  chance=100,
			  daze=100,
			  fail=15
			 }, nil)
	 else
	    self:project(tg, x, y, damtype, self:mindCrit(t.getDamage(self, t)), nil)
	 end
	 -- Corrosion here because it couldn't elegantly go in the vortex and the spray is acid-derived anyway.
	 if self:knowTalent(self.T_REK_WYRMIC_ACID) and aspectIsActive(self, "Acid") then
	    local cordur = self:callTalent(self.T_REK_WYRMIC_ACID, "getCorrodeDur")
	    local atk = self:callTalent(self.T_REK_WYRMIC_ACID, "getAtk")
	    local armor = self:callTalent(self.T_REK_WYRMIC_ACID, "getArmor")
	    local defense = self:callTalent(self.T_REK_WYRMIC_ACID, "getDefense")
	    self:project(tg, x, y, DamageType.REK_SILENT_CORRODE, {dam=0, dur=cordur, atk=atk, armor=armor, defense=defense}, nil)
	 end
	 local _ _, x, y = self:canProject(tg, x, y)
	 if tg.type == "beam" then
	    game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "acidbeam", {tx=x-self.x, ty=y-self.y})
	 else
	    game.level.map:particleEmitter(x, y, 1, "acid")
	 end
	 game:playSoundNear(self, "talents/cloud")
	 return true
      end,
      info = function(self, t)
	 local damage = t.getDamage(self, t)
	 local name = "Physical"
	 local nameStatus = "Blinded"
	 local damtype = DamageType.PHYSICAL
	 local source = self.rek_wyrmic_dragon_damage
	 local power = t.getPassivePower(self, t)
	 if source then
	    name = source.name
	    damtype = source.damtype
	    nameStatus = source.nameStatus
	 end
	 return ([[Launch forth a glob of elemental matter at your enemy, dealing damage and applying determinetal effecsts based on your primary aspect.
		The target will take %0.2f %s damage.
		Enemies struck have a 25%% chance to be %s for three turns.

Passively increases Mindpower by %d
Mindpower: improves damage
At Talent Level 5: becomes a piercing line of energy.
]]):format(damDesc(self, damtype, damage), name, nameStatus, power)
      end,
}

newTalent{
   name = "Elemental Crash",short_name = "REK_WYRMIC_ELEMENT_PBAOE",
   image = "talents/garkul_s_revenge.png",
   type = {"wild-gift/draconic-energy", 2},
   require = gifts_req2,
   points = 5,
   random_ego = "attack",
   message = "@Source@ explodes with energy!",
   equilibrium = 8,
   cooldown = 20,
   range = 0,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 200) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
   end,
   tactical = { DEFEND = 1, ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1 } },
   requires_target = true,
   action = function(self, t)
      -- If electrocuting
      if self:knowTalent(self.T_REK_WYRMIC_ELEC) and aspectIsActive(self, "Lightning") then
	 local static_tg = self:getTalentTarget(t)
	 self:project(static_tg, self.x, self.y, function(px, py)
			 local target = game.level.map(px, py, Map.ACTOR)
			 if not target then return end
			 if not target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 10) then
			    game.logSeen(target, "%s resists the static field!", target.name:capitalize())
			    return
			 end
			 game.logSeen(target, "%s is caught in the static field!", target.name:capitalize())
			 local perc = self:callTalent(self.T_REK_WYRMIC_ELEC, "getPercent")
			 if target.rank >= 5 then perc = perc / 2.5
			 elseif target.rank >= 3.5 then perc = perc / 2
			 elseif target.rank >= 3 then perc = perc / 1.5
			 end
			 
			 local dam = target.life * perc / 100
			 if target.life - dam < 0 then dam = target.life end
			 target:takeHit(dam, self)
			 
			 game:delayedLogDamage(self, target, dam, ("#PURPLE#%d STATIC#LAST#"):format(math.ceil(dam)))
						 end, nil, {type="lightning_explosion"})
	 game:playSoundNear(self, "talents/lightning")
      end

      -- Main crash
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
      end
	 
      local tg = self:getTalentTarget(t)
      self:project(tg, self.x, self.y, damtype,
		   {dam=self:mindCrit(t.getDamage(self, t)),
		    dur=3,
		    chance=100,
		    daze=100,
		    fail=15
		   }
      )
      game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local damage = t.getDamage(self, t)
      local name = "Physical"
      local nameStatus = "Blinded"
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = source.name
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[You let out a wave of primal energy in a radius of %d.
		Your foes take %0.2f %s damage and will be %s for 3 turns.
Mindpower: improves damage
]]):format(radius, self:combatTalentStatDamage(t, "str", 30, 380), name, nameStatus)
   end,
}

newTalent{
   name = "Elemental Vortex", short_name = "REK_WYRMIC_ELEMENT_BALL",
   image = "talents/winter_s_fury.png",
   type = {"wild-gift/draconic-energy", 3},
   require = gifts_req3,
   points = 5,
   random_ego = "attack",
   equilibrium = 6,
   cooldown = 20,
   tactical = { ATTACKAREA = { FIRE = 2 } },
   range = 10,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
   end,
   getDamage = function(self, t)
      return self:combatTalentMindDamage(t, 15, 60)
   end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
   action = function(self, t)
      local duration = math.min(20, self:mindCrit(1.0) * t.getDuration(self, t))
      local radius = self:getTalentRadius(t)
      local damage = self:mindCrit(t.getDamage(self, t))
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      -- Add a lasting map effect


      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
      end
      
      game.level.map:addEffect(self,
			       x, y, duration,
			       damtype,
			       {dam=damage,
				dur=3,
				chance=15,
				daze=15,
				fail=10
			       },
			       radius,
			       5, nil,
			       {type="inferno"},
			       nil, false
      )
      game:playSoundNear(self, "talents/devouringflame")
      return true
   end,
   info = function(self, t)
      local dam = t.getDamage(self, t)
      local radius = self:getTalentRadius(t)
      local duration = t.getDuration(self, t)
      local name = "Physical"
      local nameStatus = "Blinded"
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = source.name
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[Spit a swirling cloud of elemental energy, doing %0.2f %s damage in a radius of %d each turn for %d turns.  Enemies within have a 15%% chance to be %s.
Mindpower: improves damage
Mind Crit: affects duration
]]):format(damDesc(self, damtpye, dam), name, radius, duration, nameStatus)
   end,
}

newTalent{
   name = "Dragon's Breath", short_name = "REK_WYRMIC_ELEMENT_BREATH",
   image = "talents/draconic_will.png",
   type = {"wild-gift/draconic-energy", 4},
   require = gifts_req4,
   points = 5,
   mode = "passive",
   getRadius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
   getDamage = function(self, t) return math.max(self:combatTalentStatDamage(t, "str", 30, 520), self:combatTalentStatDamage(t, "wil", 30, 520) ) end,
   on_learn = function(self, t)
      self:learnTalent(self.T_REK_WYRMIC_BREATH_FIRE, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_COLD, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_ELEC, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_ACID, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_VENM, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_SAND, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_DARK, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_REK_WYRMIC_BREATH_WORM, true, nil, {no_unlearn=true})
   end,
   on_unlearn = function(self, t)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_FIRE)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_COLD)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_ELEC)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_ACID)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_VENM)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_SAND)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_DARK)
      self:unlearnTalent(self.T_REK_WYRMIC_BREATH_WORM)
   end,

   info = function(self, t)
      return ([[You gain the breath of a dragon, unleashing destructive energy in a cone of radius %d.  Each breath attack has its own cooldown, and you must have an aspect active to use its breath attack.
Talent Level: Improves radius of all breaths]]):format( t.getRadius(self, t))
   end,
}

--Acid
newTalent{
   name = "Corrosive Breath", short_name = "REK_WYRMIC_BREATH_ACID",
   image = "talents/acid_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes acid!",
   tactical = { ATTACKAREA = { ACID = 2 }, DISABLE = {disarm = 2} },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.ACID_DISARM, {dam=self:mindCrit(t.getDamage(self, t)), chance=100,})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="acidwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe acid in a frontal cone of radius %d. Any target caught in the area will take %0.2f acid damage.
		Enemies caught in the acid may have their weapons become useless for three turns, disarming them.
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, damage), disarm)
   end,
}

--Sand
newTalent{
   name = "Sand Breath", short_name = "REK_WYRMIC_BREATH_SAND",
   image = "talents/sand_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes sand!",
   tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = {blind = 2} },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 4)) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.SAND, {dam=self:mindCrit(t.getDamage(self, t)), chance=100, dur=3,})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="sandwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe sand in a frontal cone of radius %d. Any target caught in the area will take %0.2f physical damage, and will be blinded for %d turns.
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage), duration)
   end,
}

--Fire
newTalent{
   name = "Fire Breath", short_name = "REK_WYRMIC_BREATH_FIRE",
   image = "talents/fire_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes flame!",
   tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = {stun = 2} },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.FIRE_STUN, {dam=self:mindCrit(t.getDamage(self, t)), chance=100,initial=70,dur=3})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe fire in a frontal cone of radius %d. Any target caught in the area will take %0.2f fire damage and be flameshocked for 3 turns, stunning them.
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, damage))
   end,
}

--Cold
newTalent{
   name = "Ice Breath", short_name = "REK_WYRMIC_BREATH_COLD",
   image = "talents/ice_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes ice!",
   tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = {stun = 1} },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.ICE_SLOW, {dam=self:mindCrit(t.getDamage(self, t)), chance=100,})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_cold", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="icewings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe ice in a frontal cone of radius %d. Any target caught in the area will take %0.2f cold damage, will be slowed 20%% for three turnsand frozen for a few turns (higher rank enemies will be frozen for a shorter time).
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.COLD, damage))
   end,
}

--Lightning
newTalent{
   name = "Lightning Breath", short_name = "REK_WYRMIC_BREATH_ELEC",
   image = "talents/lightning_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes lightning!",
   tactical = { ATTACKAREA = { LIGHTNING = 2 }, DISABLE = {daze = 2} },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:mindCrit(t.getDamage(self, t))
      self:project(tg, x, y, DamageType.LIGHTNING_DAZE, {
		      power_check=self:combatMindpower(),
		      dam=rng.avg(dam/2.5, dam*1.3, 3),
		      chance=100,})
      if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y}, {type="lightning"})
      else game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      end

      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="lightningwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe lightning in a frontal cone of radius %d. Any target caught in the area will take %0.2f to %0.2f lightning damage, and be dazed for 3 turns.
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t),
	      damDesc(self, DamageType.LIGHTNING, damage / 2.5),
	   damDesc(self, DamageType.LIGHTNING, damage)*1.3)
   end,
}

--Venom
newTalent{
   name = "Venomous Breath", short_name = "REK_WYRMIC_BREATH_VENM",
   image = "talents/venomous_breath.png",
   type = {"wild-gift/other", 4},
   points = 5,
   random_ego = "attack",
   equilibrium = 12,
   cooldown = 12,
   message = "@Source@ breathes venom!",
   tactical = { ATTACKAREA = { poison = 2 } },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getEffect = function(self, t) return math.ceil(self:combatTalentLimit(t, 50, 10, 20)) end,
   getDamage = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getDamage")
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:mindCrit(t.getDamage(self, t))
      self:project(tg, x, y, function(px, py)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target:canBe("poison") then
			 target:setEffect(self.EFF_CRIPPLING_POISON, 6, {src=self, power=dam/6, fail=math.ceil(self:combatTalentLimit(t, 100, 10, 20))})
		      end
      end)

      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="poisonwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local effect = t.getEffect(self, t)
      local damage = t.getDamage(self, t) / 6
      return ([[You breathe crippling poison in a frontal cone of radius %d. Any target caught in the area will take %0.2f nature damage each turn for 6 turns.
		The poison also gives enemies a %d%% chance to fail actions more complicated than basic attacks and movement, while it is in effect.
Strength or Willpower: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, damage), effect)
   end,
}

--Darkness for Undead Drakes
newTalent{
   name = "Necrotic Breath", short_name = "REK_WYRMIC_BREATH_DARK",
   image = "talents/necrotic_breath.png",
   type = {"spell/other", 4},
   points = 5,
   random_ego = "attack",
   soul = 2,
   dont_provide_pool = true,
   cooldown = 12,
   message = "@Source@ breathes a wave of darkness!",
   tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { confusion = 2, blind = 2  }, },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return self:combatTalentStatDamage(t, "mag", 30, 550) / 4
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.CIRCLE_DEATH, {dam=self:spellCrit(self:combatTalentStatDamage(t, "mag", 30, 550))/4,dur=4})
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="darkwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You breathe a wave of deathly miasma in a cone of radius %d. Any target caught in the area will take %0.2f darkness damage per turn for 4 turns and receive either a bane of confusion or a bane of blindness for 4 turns.
Magic: Improves damage
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, damage))
   end,
}

--Blight for Scourge Drakes
newTalent{
   name = "Maggot Breath", short_name = "REK_WYRMIC_BREATH_WORM",
   image = "talents/maggot_breath.png",
   type = {"demented/wyrmic", 4},
   points = 5,
   random_ego = "attack",
   insanity = -25,
   cooldown = 12,
   dont_provide_pool = true,
   message = "@Source@ breathes a wave of maggots!",
   tactical = { ATTACKAREA = { BLIGHT = 2 }, DISABLE = { slow = 2, disease = 2  }, },
   range = 0,
   radius = function(self, t)
      return self:callTalent(self.T_REK_WYRMIC_ELEMENT_BREATH, "getRadius")
   end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t) return self:combatTalentStatDamage(t, "mag", 30, 550) end,
   getDiseaseDamage = function(self, t) return t.getDamage(self, t) * 0.75 / 10 end,
   getSlow = function(self, t) return self:combatTalentLimit(t, 0.7, 0.15, 0.5) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:spellCrit(t.getDamage(self, t))
      self:project(tg, x, y, function(px, py)
		      local act = game.level.map(px, py, Map.ACTOR)
		      if act then
			 DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam)
			 if act:canBe("disease") and act:canBe("slow") then
			    act:setEffect(act.EFF_CRIPPLING_DISEASE, 10, {apply_power=math.max(self:combatMindpower(), self:combatSpellpower()), src=self, dam=t.getDiseaseDamage(self, t), speed=t.getSlow(self, t)})
			 end
		      end
      end)
      game.level.map:particleEmitter(self.x, self.y, tg.radius, "maggot_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img="sickwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
      end
      game:playSoundNear(self, "talents/vile_breath")
      return true
   end,
   info = function(self, t)
		return ([[You breathe a wave of dead maggots in a cone of radius %d. Any target caught in the area will take %0.2f blight damage and be infected with a crippling disease for 10 turns.
		Crippling disease slows creatures by %d%% and deals %0.2f blight damage per turn.
		The damage will increase with your Magic, and the critical chance is based on your Spell crit rate.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t)), t.getSlow(self, t) * 100, damDesc(self, DamageType.BLIGHT, t.getDiseaseDamage(self, t)))
   end,
}
