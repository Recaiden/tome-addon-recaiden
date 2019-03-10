
newTalent{
   name = "Elemental Spray", short_name = "REK_WYRMIC_ELEMENT_SPRAY",
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
	 local damtype = DamageType.REK_WYRMIC_NULL
	 local damtypeStatus = DamageType.REK_WYRMIC_NULL
	 local source = self.rek_wyrmic_dragon_damage
	 if source then
	    damtype = source.damtype
	    damtypeStatus = source.status
	 end
	 
	 local tg = self:getTalentTarget(t)
	 local x, y = self:getTarget(tg)
	 if not x or not y then return nil end
	 self:project(tg, x, y, damtypeStatus, self:mindCrit(t.getDamage(self, t)), nil)
	 -- Corrosion here because it couldn't elegantly go in the vortex and the spray is acid-derived anyway.
	 if self:knowTalent(self.T_REK_WYRMIC_ACID) then
	    local cordur = self:callTalent(self.T_REK_WYRMIC_ACID, "getCorrodeDur")
	    local atk = self:callTalent(self.T_REK_WYRMIC_ACID, "getAtk")
	    self:project(tg, x, y, DamageType.REK_SILENT_CORRODE, {dam=0, dur=cordur, atk=atk}, nil)
	 end
	 local _ _, x, y = self:canProject(tg, x, y)

	 -- Visual depends on Aspect
	 if tg.type == "beam" then
	    local nameBeam = "rek_wyrmic_"..DamageType:get(damtype).name.."_beam"
	    game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), nameBeam, {tx=x-self.x, ty=y-self.y})
	 else
	    local nameBall = "rek_wyrmic_"..DamageType:get(damtype).name.."_ball"
	    game.level.map:particleEmitter(x, y, 1, nameBall, {tx=x, ty=y, radius=1})
	 end
 
	 game:playSoundNear(self, "talents/cloud")
	 return true
      end,
      info = function(self, t)
	 local damage = t.getDamage(self, t)
	 local name = "Physical"
	 local nameStatus = "unaffected otherwise (you don't have an aspect)"
	 local damtype = DamageType.PHYSICAL
	 local source = self.rek_wyrmic_dragon_damage
	 local power = t.getPassivePower(self, t)
	 if source then
	    name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	    damtype = source.damtype
	    nameStatus = source.nameStatus
	 end
	 return ([[Launch forth a glob of elemental matter at your enemy, dealing damage and applying detrimental effects based on your primary aspect.
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
      local static_tg = self:getTalentTarget(t)
      --self:rekWyrmicElectrocute(static_tg)
      -- if self:knowTalent(self.T_REK_WYRMIC_ELEC) then
      -- 	 game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0, rM=0, gm=0, gM=0, bm=0.7, bM=0.9, am=0.4, aM=0.6})
      -- end

      -- Main crash
      local damtype = DamageType.REK_WYRMIC_NULL
      local vistype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
	 vistype = source.damtype
      end
	 
      local tg = self:getTalentTarget(t)
      self:project(tg, self.x, self.y, damtype,
		   {dam=self:mindCrit(t.getDamage(self, t)),
		    dur=3,
		    chance=100,
		    fail=40
		   }
      )
      local nameBall = "rek_wyrmic_"..DamageType:get(vistype).name.."_ball"
      game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), nameBall, {tx=self.x, ty=self.y, radius=self:getTalentRadius(t)})
      game:playSoundNear(self, "talents/tidalwave")
      --game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local damage = t.getDamage(self, t)
      local name = "Physical"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[You let out a wave of primal energy in a radius of %d.
		Your foes take %0.2f %s damage and will be %s for 3 turns.
Mindpower: improves damage
]]):format(radius, damDesc(self, damtpye, damage), name, nameStatus)
   end,
}

newTalent{
   name = "Elemental Vortex", short_name = "REK_WYRMIC_ELEMENT_BALL",
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

      local damtype = DamageType.REK_WYRMIC_NULL
      local vistype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
	 vistype = source.damtype
      end

      local nameStorm = "rek_wyrmic_"..DamageType:get(vistype).name.."_storm"

      -- Devour if you know Fire Aspect
      local perc_drain = 0
      if  self:knowTalent(self.T_REK_WYRMIC_FIRE) then
	 perc_drain = self:callTalent(self.T_REK_WYRMIC_FIRE, "getDrain")
      end
      
      game.level.map:addEffect(self,
			       x, y, duration,
			       damtype,
			       {dam=damage,
				dur=3,
				chance=15,
				fail=10,
				drain=perc_drain / 100
			       },
			       radius,
			       5, nil,
			       {type=nameStorm},
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
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[Spit a swirling cloud of elemental energy, doing %0.2f %s damage in a radius of %d each turn for %d turns.  Enemies within have a 15%% chance each turn to be %s.
Mindpower: improves damage
Mind Crit: affects duration
]]):format(damDesc(self, damtpye, dam), name, radius, duration, nameStatus)
   end,
}


-- Breath
newTalent{
   name = "Dragon's Breath", short_name = "REK_WYRMIC_ELEMENT_BREATH",
   type = {"wild-gift/draconic-energy", 4},
   require = gifts_req4,
   points = 5,
   range = 0,
   equilibrium = 15,
   random_ego = "attack",
   tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1, NATURE = 1 } },
   message = "@Source@ breathes energy!",
   cooldown = function(self, t) return 13 - math.min(7, math.floor(self:getTalentLevel(t))) end,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
   direct_hit = true,
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   getDamage = function(self, t)
      return math.max(self:combatTalentStatDamage(t, "str", 100, 620),
		      self:combatTalentStatDamage(t, "wil", 100, 620) )
   end,
   action = function(self, t)
      local damtype = DamageType.REK_WYRMIC_NULL
      local vistype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
	 vistype = source.damtype
      end

      -- Damage
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local crit = self:mindCrit( 1.0 )
      -- if crit - 1.0 > 0 and self:knowTalent(self.T_REK_WYRMIC_MULTICOLOR_GUILE) then
      -- 	 local cd = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_GUILE, "CDreduce")
      -- 	 self:setEffect(self.EFF_REK_WYRMIC_BREATH_RECOVERY, cd, {})
      -- end
      local dam = crit * t.getDamage(self, t)
      self:project(tg, x, y, damtype,
		   {dam=dam,
		    dur=3,
		    chance=100,
		    fail=40
		   }
      )

      --Visuals
      -- exceptions till I can properly add it to the particle generator
      local part_breath = "breath_"..DamageType:get(vistype).name
      local part_wings = ""
      if vistype == DamageType.PHYSICAL then
	 part_breath = "breath_earth"
	 part_wings = "sandwings"
      elseif vistype == DamageType.NATURE then
	 part_breath = "breath_slime"
	 part_wings = "poisonwings"
      elseif vistype == DamageType.DARKNESS then
	 part_breath = "breath_dark"
	 part_wings = "darkwings"
      elseif vistype == DamageType.BLIGHT then
	 part_breath = "maggot_breath"
	 part_wings = "sickwings"
      elseif vistype == DamageType.COLD then
	 part_wings = "icewings"
      elseif vistype == DamageType.LIGHTNING then
	 part_wings = "lightningwings"
      elseif vistype == DamageType.ACID then
	 part_wings = "acidwings"
      end
      
      if core.shader.active() and vistype == DamageType.LIGHTNING then
	 game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y}, {type="lightning"})
      else
	 game.level.map:particleEmitter(self.x, self.y, tg.radius, part_breath, {radius=tg.radius, tx=x-self.x, ty=y-self.y})
      end
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {img=part_wings, x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
      end

      --Sound
      game:playSoundNear(self, "talents/breath")
      
      return true
   end,
   
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local damage = t.getDamage(self, t)
      local name = "Physical"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[You gain the breath of a dragon, unleashing destructive energy in a cone of radius %d.
		Your foes take %0.2f %s damage and will be %s for 3 turns.
Strength or Willpower: Improves damage
Talent Level: Improves Radius and Cooldown
]]):format(radius, damDesc(self, damtpye, damage), name, nameStatus)
   end, 
}
